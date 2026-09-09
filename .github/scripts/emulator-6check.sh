#!/usr/bin/env bash
set -uo pipefail

# =====================================================
# エミュレータ 6観点チェック（GitHub Actions 上で実行）
#
# build-and-test スキルの6観点を、ローカル環境・実機なしで検証する。
#   1. 起動テスト   2. 接続テスト   3. 課金画面
#   4. 認証フロー   5. 広告表示     6. クラッシュ検出
#
# integration_test/ があればそれを優先実行し、
# なければ APK 起動 + logcat 解析にフォールバックする。
# =====================================================

FAIL=0
LOG=emulator-run.log
mkdir -p screenshots

note()  { echo -e "\n=== $1 ==="; }
pass()  { echo "✅ $1"; }
warn()  { echo "⚠️  $1"; }
fail()  { echo "❌ $1"; FAIL=1; }

# ---------- integration_test があれば優先 ----------
if [ -d integration_test ] && compgen -G "integration_test/*.dart" > /dev/null; then
  note "integration_test を実行"
  if flutter test integration_test --reporter expanded 2>&1 | tee -a "$LOG"; then
    pass "integration_test 合格"
  else
    fail "integration_test 失敗"
  fi
fi

# ---------- APK ビルド ----------
note "1. 起動テスト — APK ビルド"
if ! flutter build apk --debug 2>&1 | tee -a "$LOG"; then
  fail "APK ビルド失敗（以降の観点は検証不能）"
  exit 1
fi
pass "APK ビルド成功"

APK=$(find build/app/outputs -name "*.apk" | head -1)
[ -n "$APK" ] || { fail "APK が見つかりません"; exit 1; }

# パッケージ名を取得（aapt が無い環境では pubspec 由来の推定にフォールバック）
PKG=$(grep -rhoP 'applicationId\s*=?\s*"\K[^"]+' android/app/build.gradle* 2>/dev/null | head -1)
if [ -z "$PKG" ]; then
  PKG=$(grep -rhoP 'package="\K[^"]+' android/app/src/main/AndroidManifest.xml 2>/dev/null | head -1)
fi
[ -n "$PKG" ] || { fail "パッケージ名を特定できません"; exit 1; }
echo "パッケージ: $PKG"

# ---------- インストール・起動 ----------
adb install -r -g "$APK" 2>&1 | tee -a "$LOG"
adb logcat -c
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 2>&1 | tee -a "$LOG"
sleep 20

adb logcat -d > logcat.txt 2>/dev/null || true
adb exec-out screencap -p > screenshots/startup.png 2>/dev/null || true

# プロセスが生きているか＝起動テスト
if adb shell pidof "$PKG" > /dev/null 2>&1; then
  pass "1. 起動テスト — アプリが起動し継続動作している"
else
  fail "1. 起動テスト — アプリが起動直後に終了した"
fi

# ---------- 6. クラッシュ検出（最重要なので先に判定） ----------
note "6. クラッシュ検出"
if grep -qE "FATAL EXCEPTION|ANR in |signal 11 \(SIGSEGV\)" logcat.txt; then
  fail "6. クラッシュ検出 — 致命的エラーを検出"
  grep -A 15 -E "FATAL EXCEPTION|ANR in " logcat.txt | head -60
else
  pass "6. クラッシュ検出 — 致命的エラーなし"
fi

# ---------- 観点2〜5：実装有無 × 実行時ログの両面で確認 ----------
# 実装が無い機能は「未実装」として扱い、失敗にはしない（誤検知を避ける）。
check_aspect() {
  local num="$1" name="$2" src_pattern="$3" log_pattern="$4"
  note "$num. $name"
  if ! grep -rqiE "$src_pattern" lib/ pubspec.yaml 2>/dev/null; then
    warn "$num. $name — 未実装（このアプリでは対象外）"
    return
  fi
  if grep -qiE "$log_pattern" logcat.txt 2>/dev/null; then
    if grep -iE "$log_pattern" logcat.txt | grep -qiE "error|exception|fail"; then
      fail "$num. $name — 実行時エラーを検出"
      grep -iE "$log_pattern" logcat.txt | grep -iE "error|exception|fail" | head -10
    else
      pass "$num. $name — 正常に初期化"
    fi
  else
    warn "$num. $name — 実装はあるが起動直後のログに現れず（画面遷移が必要な可能性）"
  fi
}

check_aspect 2 "接続テスト"  "firebase|http|dio|supabase|cloud_firestore" "firebase|okhttp|cronet|network|firestore"
check_aspect 3 "課金画面"    "in_app_purchase|purchases_flutter|billing"  "billing|purchase|revenuecat"
check_aspect 4 "認証フロー"  "firebase_auth|google_sign_in|sign_in"       "auth|signin|sign-in"
check_aspect 5 "広告表示"    "google_mobile_ads|admob|applovin|unity_ads" "ads|admob|gma_sdk"

# ---------- 結果 ----------
note "結果"
if [ "$FAIL" -eq 0 ]; then
  echo "✅ 6観点チェック合格"
else
  echo "❌ 6観点チェックで問題を検出"
fi
exit "$FAIL"
