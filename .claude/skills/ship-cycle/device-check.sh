#!/usr/bin/env bash
# 実機テスト（Windows ローカルの Git Bash / Linux + USB 実機）。
# release APK をインストール・起動し、logcat から課金・広告・Firebase・クラッシュを自動判定する。
# 使い方: bash device-check.sh <app_dir> [apk_path] [秒数=25]
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; . "$HERE/lib.sh"
P="${1:-.}"; APK="${2:-}"; SECS="${3:-25}"
command -v adb >/dev/null || { [ -n "${ANDROID_HOME:-}" ] && export PATH="$ANDROID_HOME/platform-tools:$PATH"; }
command -v adb >/dev/null || { warn ENV "adb なし → 実機テストはローカル（Windows）セッションで実行"; summary device-check; exit 0; }
[ "$(adb devices | grep -c 'device$')" -ge 1 ] || { err DEV "実機が接続されていない（USB デバッグを ON）"; summary device-check; exit 1; }

[ -z "$APK" ] && APK=$(ls -t "$P"/build/app/outputs/flutter-apk/app-release.apk "$P"/build/app/outputs/flutter-apk/*.apk 2>/dev/null | head -1)
[ -f "$APK" ] || { err DEV "APK がない（flutter build apk --release を先に）"; summary device-check; exit 1; }
G=$(ls "$P"/android/app/build.gradle* | head -1)
PKG=$(grep -m1 -oE "applicationId\s*=?\s*['\"][^'\"]+" "$G" | grep -oE "[a-zA-Z0-9_.]+$")
echo "== device-check: $PKG ($(adb shell getprop ro.product.model | tr -d '\r') / Android $(adb shell getprop ro.build.version.release | tr -d '\r'))"

adb install -r "$APK" >/dev/null || { err DEV "インストール失敗（署名が既存版と違う場合は adb uninstall $PKG）"; summary device-check; exit 1; }
adb logcat -c
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
T0=$(date +%s); sleep "$SECS"
OUT="${ARTIFACTS:-$P/build}/device-check"; mkdir -p "$OUT"
adb logcat -d > "$OUT/logcat.txt"
adb exec-out screencap -p > "$OUT/screen.png" 2>/dev/null
L="$OUT/logcat.txt"

adb shell pidof "$PKG" >/dev/null || err CRASH "起動 ${SECS}s 以内にプロセス終了"
grep -q "FATAL EXCEPTION" "$L" && { err CRASH "FATAL EXCEPTION"; grep -A8 "FATAL EXCEPTION" "$L" | head -12; }
grep -qE "No Firebase App '\[DEFAULT\]'|FirebaseApp is not initialized" "$L" && err FB "Firebase 初期化前アクセス（P3 参照）"
grep -qE "DEVELOPER_ERROR|ApiException: 10" "$L" && err FB "Google サインイン DEVELOPER_ERROR（Firebase に SHA-1 未登録）"
grep -qE "Missing application ID|The Google Mobile Ads SDK was initialized incorrectly" "$L" && err AD "AdMob APPLICATION_ID 未設定"
grep -oE "Ad failed to load : [0-9]+" "$L" | sort | uniq -c | while read -r n _ _ _ _ _ code; do
  case "$code" in 3) warn AD "No fill ×$n（テスト広告なら通常。本番IDは審査前は出ないことがある）";;
                  *) err AD "広告読み込みエラー code=$code ×$n（0:内部 1:不正リクエスト 2:通信）";; esac
done
grep -qE "Use RequestConfiguration.Builder\(\).setTestDeviceIds" "$L" && warn AD "この端末がテストデバイス未登録（本番広告を自分でタップしない）"
grep -qE "BillingClient.*(BILLING_UNAVAILABLE|DEVELOPER_ERROR|ITEM_UNAVAILABLE)|PurchasesError" "$L" \
  && err IAP "課金エラー: $(grep -m1 -oE "(BILLING_UNAVAILABLE|DEVELOPER_ERROR|ITEM_UNAVAILABLE|PurchasesError[^,]*)" "$L")（Play で内部テスト配信済み・ライセンステスター登録を確認）"
grep -qE "Choreographer.*Skipped [0-9]{2,} frames" "$L" && warn PERF "起動時にフレーム落ち: $(grep -m1 -oE 'Skipped [0-9]+ frames' "$L")"
ST=$(grep -m1 -oE "Displayed $PKG/[^ ]+: \+[0-9]+s?[0-9]*ms" "$L" | grep -oE "\+.*"); [ -n "$ST" ] && echo "⏱  初回表示 $ST"

cat <<TXT
📸 $OUT/screen.png / 📄 $OUT/logcat.txt
目視チェック（docs/DEV_PLAYBOOK.md §6）: 保護者ゲート / 購入・復元 / オフライン / 文字サイズ最大 / 通知権限
TXT
summary device-check
