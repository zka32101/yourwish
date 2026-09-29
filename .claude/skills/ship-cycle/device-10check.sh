#!/usr/bin/env bash
# 10観点デバイステスト（Android エミュレータ/実機・iOS シミュレータ共通）＋撮影ユーティリティ
#   bash device-10check.sh android|ios [app_dir]       # 10観点テスト → 結果を 1 つの zip にまとめて Google ドライブへ
#   bash device-10check.sh shot <name> [out]           # スクリーンショット 1 枚（+ 直前ログ）
#   bash device-10check.sh record <秒> <name> [out]    # 録画（再現用・最大 180 秒）
#   bash device-10check.sh demo on|off                 # ステータスバー固定（9:41・電池100%・通知なし）
#   bash device-10check.sh sheet [dir]                 # スクショ一覧画像（ImageMagick があれば）
# 環境変数: APK=<path>（ローカル実機で release APK を検証）/ WAIT=20 / OUT=<成果物dir> / DEMO=1
#           DRIVE_DIR=<保存先>（既定: マイドライブ/apk/test-results。無ければ保存しない）
# 観点: 1起動 2クラッシュ 3全画面 4通信 5認証 6課金 7広告・同意 8子ども向け 9ライフサイクル・権限 10性能
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

# ---------- 撮影ユーティリティ（iOS 実機は CLI 不可 → flutter drive の takeScreenshot を使う） ----------
if [[ "${1:-}" =~ ^(shot|record|demo|sheet)$ ]]; then
  CMD="$1"; OUT_DEFAULT="${OUT:-./device-test-results/screenshots}"
  if command -v adb >/dev/null && adb get-state >/dev/null 2>&1; then P=android
  elif command -v xcrun >/dev/null && xcrun simctl list devices booted | grep -q Booted; then P=ios
  else P=none; fi

  case "$CMD" in
    shot)
      N="${2:?name}"; O="${3:-$OUT_DEFAULT}"; mkdir -p "$O"; F="$O/$(date +%H%M%S)_$N.png"
      # exec-out はバイナリをそのまま転送（Windows で shell screencap すると改行変換で PNG が壊れる）
      case $P in
        android) adb exec-out screencap -p > "$F" ;;
        ios) xcrun simctl io booted screenshot "$F" >/dev/null ;;
        *) echo "端末なし"; exit 1 ;;
      esac
      # 直前 200 行のログを同名で保存（画像だけでは原因が分からないため）
      [ $P = android ] && adb logcat -d -t 200 > "${F%.png}.log" 2>/dev/null
      echo "📸 $F" ;;
    record)
      S="${2:-30}"; N="${3:?name}"; O="${4:-$OUT_DEFAULT}"; mkdir -p "$O"; F="$O/$(date +%H%M%S)_$N.mp4"
      [ "$S" -gt 180 ] && S=180
      case $P in
        android) adb shell screenrecord --time-limit "$S" --bit-rate 4000000 /sdcard/sc_rec.mp4 \
                   && adb pull /sdcard/sc_rec.mp4 "$F" >/dev/null && adb shell rm /sdcard/sc_rec.mp4 ;;
        ios) xcrun simctl io booted recordVideo --codec=h264 "$F" & pid=$!; sleep "$S"; kill -INT $pid; wait $pid 2>/dev/null ;;
        *) echo "端末なし"; exit 1 ;;
      esac
      echo "🎥 $F" ;;
    demo)
      if [ $P = android ]; then
        if [ "${2:-on}" = on ]; then
          adb shell settings put global sysui_demo_allowed 1
          for a in "command enter" "command clock -e hhmm 0941" "command battery -e level 100 -e plugged false" \
                   "command network -e wifi show -e level 4 -e mobile show -e level 4" "command notifications -e visible false"; do
            adb shell am broadcast -a com.android.systemui.demo -e $a >/dev/null
          done
        else adb shell am broadcast -a com.android.systemui.demo -e command exit >/dev/null; fi
      elif [ $P = ios ]; then
        if [ "${2:-on}" = on ]; then xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3
        else xcrun simctl status_bar booted clear; fi
      fi
      echo "demo ${2:-on} ($P)" ;;
    sheet)
      O="${2:-$OUT_DEFAULT}"
      if command -v magick >/dev/null || command -v montage >/dev/null; then
        M=$(command -v magick >/dev/null && echo "magick montage" || echo montage)
        $M "$O"/*.png -resize 270x -tile 6x -geometry +4+4 -label '%t' "$O/../contact_sheet.jpg" && echo "🗂  $O/../contact_sheet.jpg"
      else echo "ImageMagick なし → 一覧画像はスキップ（PNG はそのまま確認）"; fi ;;
  esac
  exit 0
fi
PLAT="${1:?android|ios}"; APP="${2:-.}"; cd "$APP" || exit 1
WAIT="${WAIT:-20}"; OUT="${OUT:-$PWD/device-test-results}"; mkdir -p "$OUT/screenshots"
LOG="$OUT/device.log"; DRIVE="$OUT/drive.log"; : > "$LOG"; : > "$DRIVE"
RES=(); DETAIL=(); FAILED=0  # bash 3.2（macOS 標準）互換のため添字配列
set_r() { RES[$1]="$2"; DETAIL[$1]="${3:-}"; [ "$2" = "❌" ] && FAILED=1; echo "$2 観点$1 ${3:-}"; }
dep() { grep -qE "^\s+$1:" pubspec.yaml; }
has() { grep -qiE "$1" "$LOG" "$DRIVE" 2>/dev/null; }
first() { grep -h -m1 -oiE "$1" "$LOG" "$DRIVE" 2>/dev/null | head -1; }

# ---------- 端末上パート（integration_test: 起動・全画面ツアー） ----------
run_drive() {
  [ -n "${APK:-}" ] && return 0
  [ -f integration_test/perspectives_test.dart ] || { echo "ℹ️  perspectives_test.dart なし（bootstrap-tests.sh で導入）"; return 0; }
  flutter drive --driver=test_driver/integration_test.dart \
    --target=integration_test/perspectives_test.dart -d "$1" > "$DRIVE" 2>&1
  DRIVE_RC=$?
  [ -d screenshots ] && cp -r screenshots/. "$OUT/screenshots/" 2>/dev/null
  return 0
}

if [ "$PLAT" = android ]; then
  command -v adb >/dev/null || { [ -n "${ANDROID_HOME:-}" ] && export PATH="$ANDROID_HOME/platform-tools:$PATH"; }
  DEV=$(adb devices | awk 'NR>1 && $2=="device"{print $1; exit}')
  [ -n "$DEV" ] || { echo "❌ Android 端末/エミュレータなし"; exit 1; }
  EMU=0; [[ "$DEV" == emulator-* ]] && EMU=1
  G=$(ls android/app/build.gradle* | head -1)
  ID=$(grep -m1 -oE "applicationId\s*=?\s*['\"][^'\"]+" "$G" | grep -oE "[a-zA-Z0-9_.]+$")
  DRIVE_RC=0; run_drive "$DEV"
  if [ -z "${APK:-}" ]; then
    APK=$(ls -t build/app/outputs/flutter-apk/app-debug.apk 2>/dev/null | head -1)
    [ -f "$APK" ] || { flutter build apk --debug >>"$DRIVE" 2>&1; APK=build/app/outputs/flutter-apk/app-debug.apk; }
  fi
  adb -s "$DEV" install -r -g "$APK" >/dev/null 2>&1 || { set_r 1 ❌ "インストール失敗"; }
  launch() { adb -s "$DEV" shell monkey -p "$ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1; }
  alive() { adb -s "$DEV" shell pidof "$ID" >/dev/null 2>&1; }
  [ "${DEMO:-1}" = 1 ] && bash "$HERE/device-10check.sh" demo on >/dev/null 2>&1
  adb -s "$DEV" logcat -c; launch; sleep "$WAIT"
  ALIVE1=0; alive && ALIVE1=1
  adb -s "$DEV" exec-out screencap -p > "$OUT/screenshots/zz_launch_native.png" 2>/dev/null
  # 観点9: 背面→復帰、強制終了→コールド起動
  adb -s "$DEV" shell input keyevent KEYCODE_HOME; sleep 3; launch; sleep 4; ALIVE_BG=0; alive && ALIVE_BG=1
  adb -s "$DEV" shell am force-stop "$ID"; sleep 1; launch; sleep 8; ALIVE_COLD=0; alive && ALIVE_COLD=1
  adb -s "$DEV" logcat -d > "$LOG"
  MEM=$(adb -s "$DEV" shell dumpsys meminfo "$ID" 2>/dev/null | awk '/TOTAL PSS:|TOTAL:/{print $3; exit}')
  START=$(grep -m1 -oE "Displayed $ID/[^ ]+: \+[0-9]+s?[0-9]*ms" "$LOG" | grep -oE "\+[0-9]+s?[0-9]*ms")
  CRASH_PAT="FATAL EXCEPTION|ANR in $ID|signal (6|11) \(SIG|Fatal signal"
else
  command -v xcrun >/dev/null || { echo "❌ iOS は macOS でのみ実行可能"; exit 1; }
  EMU=1
  DEV=$(xcrun simctl list devices available -j | python3 -c '
import json,sys; d=json.load(sys.stdin)["devices"]
c=[x for k,v in d.items() if "iOS" in k for x in v if x["name"].startswith("iPhone")]
b=[x for x in c if x["state"]=="Booted"]; print((b or c)[-1]["udid"] if c else "")')
  [ -n "$DEV" ] || { echo "❌ iPhone シミュレータなし"; exit 1; }
  xcrun simctl boot "$DEV" 2>/dev/null; xcrun simctl bootstatus "$DEV" -b >/dev/null 2>&1
  T0=$(date +%s)
  [ "${DEMO:-1}" = 1 ] && xcrun simctl status_bar "$DEV" override --time "9:41" --batteryState charged --batteryLevel 100 >/dev/null 2>&1
  DRIVE_RC=0; run_drive "$DEV"
  APPB=$(ls -d build/ios/iphonesimulator/Runner.app 2>/dev/null)
  [ -n "$APPB" ] || { flutter build ios --simulator --debug >>"$DRIVE" 2>&1; APPB=build/ios/iphonesimulator/Runner.app; }
  ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APPB/Info.plist")
  xcrun simctl install "$DEV" "$APPB" || set_r 1 ❌ "インストール失敗"
  launch() { xcrun simctl launch "$DEV" "$ID" >/dev/null 2>&1; }
  alive() { xcrun simctl spawn "$DEV" launchctl list 2>/dev/null | grep -q "UIKitApplication:$ID"; }
  launch; sleep "$WAIT"; ALIVE1=0; alive && ALIVE1=1
  xcrun simctl io "$DEV" screenshot "$OUT/screenshots/zz_launch_native.png" >/dev/null 2>&1
  xcrun simctl launch "$DEV" com.apple.Preferences >/dev/null 2>&1; sleep 3; launch; sleep 4; ALIVE_BG=0; alive && ALIVE_BG=1
  xcrun simctl terminate "$DEV" "$ID" >/dev/null 2>&1; sleep 1; launch; sleep 8; ALIVE_COLD=0; alive && ALIVE_COLD=1
  xcrun simctl spawn "$DEV" log show --last "$(( $(date +%s) - T0 + 30 ))s" --style compact \
    --predicate 'process == "Runner"' > "$LOG" 2>/dev/null
  ls "$HOME"/Library/Logs/DiagnosticReports/Runner*.ips 2>/dev/null | while read -r f; do
    [ "$(stat -f %m "$f")" -ge "$T0" ] && { echo "CRASH_REPORT $f"; head -40 "$f"; } >> "$LOG"
  done
  MEM=""; START=""
  CRASH_PAT="CRASH_REPORT|Terminating app due to uncaught exception|EXC_BAD_ACCESS|EXC_CRASH|Fatal error:"
fi

# ---------- 判定 ----------
echo "== 10観点 ($PLAT / $ID / $DEV)"
# 1 起動
if [ "$ALIVE1" = 1 ] && [ "${DRIVE_RC:-0}" = 0 ]; then set_r 1 ✅ "起動 OK${START:+ ($START)}"
elif [ "$ALIVE1" = 1 ]; then set_r 1 ❌ "ネイティブ起動は OK だが integration_test 失敗 → drive.log"
else set_r 1 ❌ "起動 ${WAIT}s 以内に終了"; fi
# 2 クラッシュ
if has "$CRASH_PAT"; then set_r 2 ❌ "$(first "$CRASH_PAT")"; else set_r 2 ✅ "クラッシュ/ANR なし"; fi
# 3 全画面
if [ -f integration_test/perspectives_test.dart ] && [ -z "${APK_GIVEN:-}" ] && [ -s "$DRIVE" ]; then
  n=$(grep -m1 -oE "SHIP_CYCLE_ROUTES [0-9]+" "$DRIVE" | awk '{print $2}'); w=$(grep -c "SHIP_CYCLE_WARN" "$DRIVE")
  if grep -qE "観点3|overflowed" "$DRIVE" && [ "${DRIVE_RC:-0}" != 0 ]; then set_r 3 ❌ "表示崩れ/例外 → drive.log"
  elif [ "$w" -gt 0 ]; then set_r 3 ⚠️ "${n:-0} 画面 / 要確認 $w 件（引数必須なら screen_catalog.dart の skipRoutes へ）"
  else set_r 3 ✅ "${n:-0} 画面 + 起動画面を巡回、SS ${OUT##*/}/screenshots"; fi
else set_r 3 ⚠️ "全画面ツアー未実施（bootstrap-tests.sh で導入）"; fi
# 4 通信
NET="SocketException|Failed host lookup|UnknownHostException|NSURLErrorDomain|HandshakeException|Connection refused"
if has "$NET"; then set_r 4 ⚠️ "$(first "$NET")（CI 回線起因の可能性。実機で再確認）"; else set_r 4 ✅ "通信エラーなし"; fi
# 5 認証
if dep firebase_auth || dep google_sign_in || dep sign_in_with_apple; then
  AUTH="FirebaseAuthException|firebase_auth/[a-z-]+|DEVELOPER_ERROR|ApiException: 10|CONFIGURATION_NOT_FOUND|keychain error"
  if has "$AUTH"; then set_r 5 ❌ "$(first "$AUTH")"; else set_r 5 ✅ "認証エラーなし"; fi
else set_r 5 ➖ "認証なし"; fi
# 6 課金
if dep purchases_flutter || dep in_app_purchase; then
  IAP="BILLING_UNAVAILABLE|ITEM_UNAVAILABLE|DEVELOPER_ERROR|PurchasesError[^ ]*|SKErrorDomain|ConfigurationError|Invalid API key"
  if has "$IAP"; then
    if [ "$EMU" = 1 ] && has "BILLING_UNAVAILABLE|ConfigurationError"; then set_r 6 ⚠️ "$(first "$IAP")（エミュレータ/シミュレータは課金不可が正常。実機・Sandbox で確認）"
    else set_r 6 ❌ "$(first "$IAP")"; fi
  else set_r 6 ✅ "課金 SDK エラーなし（購入・復元は実機で）"; fi
else set_r 6 ➖ "課金なし"; fi
# 7 広告・同意（UMP / ATT）
if dep google_mobile_ads; then
  if has "Missing application ID|initialized incorrectly|GADApplicationIdentifier"; then set_r 7 ❌ "AdMob アプリ ID 未設定（起動クラッシュ要因）"
  elif AE=$(grep -oE "Ad failed to load ?: ?[0-9]+|GADErrorDomain Code=[0-9]+" "$LOG" | grep -vE ": ?3$|Code=1$" | head -1) && [ -n "$AE" ]; then
    set_r 7 ❌ "広告エラー: $AE（No fill 以外）"
  else set_r 7 ✅ "広告 SDK エラーなし（No fill は許容）"; fi
else set_r 7 ➖ "広告なし"; fi
# 8 子ども向け（静的: 保護者ゲート・子ども向けタグ・ATT）
K=$(ALL=1 bash "$HERE/store-check.sh" . 2>/dev/null | grep -E "\[(M1|M6|M7|I11)\]" | head -3)
if echo "$K" | grep -q "❌"; then set_r 8 ❌ "$(echo "$K" | head -1 | sed 's/^[^]]*] //')"
elif [ -n "$K" ]; then set_r 8 ⚠️ "$(echo "$K" | head -1 | sed 's/^[^]]*] //')"
else set_r 8 ✅ "子ども向けポリシーの静的チェック OK（保護者ゲートの操作は目視）"; fi
# 9 ライフサイクル・権限
if [ "$ALIVE_BG" = 1 ] && [ "$ALIVE_COLD" = 1 ]; then
  if has "PlatformException\(.*[Pp]ermission|permission denied"; then set_r 9 ⚠️ "$(first "PlatformException\(.*[Pp]ermission[^)]*|permission denied")"
  else set_r 9 ✅ "背面→復帰・強制終了→再起動 OK"; fi
else set_r 9 ❌ "復帰(${ALIVE_BG})/再起動(${ALIVE_COLD}) で落ちた"; fi
# 10 性能
P10="✅"; M10=""
if [ -n "$START" ]; then  # "+1s234ms" / "+876ms" → ms（bc 不要）
  sec=$(echo "$START" | grep -oE "[0-9]+s" | tr -d s); msp=$(echo "$START" | grep -oE "[0-9]+ms" | tr -d ms)
  ms=$(( ${sec:-0} * 1000 + ${msp:-0} ))
  [ -n "$ms" ] && [ "$ms" -gt $([ "$EMU" = 1 ] && echo 8000 || echo 3000) ] && P10="⚠️"; M10="起動 $START"; fi
[ -n "$MEM" ] && { M10="$M10 / PSS $((MEM/1024))MB"; [ "$MEM" -gt 400000 ] && P10="⚠️"; }
has "Skipped [0-9]{2,} frames|Davey!" && { P10="⚠️"; M10="$M10 / $(first "Skipped [0-9]+ frames|Davey! duration=[0-9]+ms")"; }
set_r 10 "$P10" "${M10:-計測値なし（実機で DevTools）}"

[ "$PLAT" = android ] && [ "${DEMO:-1}" = 1 ] && bash "$HERE/device-10check.sh" demo off >/dev/null 2>&1
OUT="$OUT/screenshots" bash "$HERE/device-10check.sh" sheet "$OUT/screenshots" >/dev/null 2>&1

# ---------- レポート ----------
REPORT="$OUT/report.md"
{
  echo "### 10観点デバイステスト（$PLAT / \`$ID\` / $([ "$EMU" = 1 ] && echo 仮想端末 || echo 実機)）"
  echo; echo "| # | 観点 | 結果 | 詳細 |"; echo "|---|---|---|---|"
  n=(x 起動 クラッシュ/ANR 全画面表示 通信 認証 課金 広告・同意 子ども向け ライフサイクル・権限 性能)
  for i in $(seq 1 10); do echo "| $i | ${n[$i]} | ${RES[$i]} | ${DETAIL[$i]//|/／} |"; done
  echo; echo "成果物: \`${OUT##*/}/\`（screenshots/, device.log, drive.log）。目視項目は DEVICE_TEST_POLICY.md §3・§5・§6。"
} > "$REPORT"
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && cat "$REPORT" >> "$GITHUB_STEP_SUMMARY"
echo "📝 $REPORT"

# ---------- 1 ファイルにまとめる（スクショ・ログ・レポートを分散させない） ----------
APPNAME=$(grep -m1 "^name:" pubspec.yaml | awk '{print $2}')
VER=$(grep -m1 "^version:" pubspec.yaml | awk '{print $2}' | tr '+' '_')
ZIP="${APPNAME}_${VER:-na}_${PLAT}_$(date +%Y%m%d-%H%M).zip"
( cd "$OUT" && rm -f ./*.zip
  if command -v zip >/dev/null; then zip -qr "$ZIP" . -x '*.zip'
  elif command -v powershell.exe >/dev/null; then powershell.exe -NoProfile -Command "Compress-Archive -Path * -DestinationPath '$ZIP'" >/dev/null
  else python3 -c "import shutil,sys;shutil.make_archive(sys.argv[1][:-4],'zip','.')" "$ZIP"; fi )
echo "📦 $OUT/$ZIP"
echo "$OUT/$ZIP" > "$OUT/.zip_path"
# ローカル（Windows の Google ドライブ同期フォルダ）: 決まった場所へコピー。CI はワークフロー側で rclone アップロード
DRIVE_DIR="${DRIVE_DIR:-${USERPROFILE:-$HOME}/マイドライブ/apk/test-results}"
if [ -z "${CI:-}" ] && [ -d "$(dirname "$DRIVE_DIR")" ]; then
  mkdir -p "$DRIVE_DIR/$APPNAME" && cp "$OUT/$ZIP" "$DRIVE_DIR/$APPNAME/" && echo "☁️  $DRIVE_DIR/$APPNAME/$ZIP"
fi
exit "$FAILED"
