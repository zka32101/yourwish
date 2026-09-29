#!/usr/bin/env bash
# ストア登録・アップロード時に弾かれる設定を静的検出（Flutter/ビルド不要）。
# バージョン番号・SDK要件・ID不一致・申告漏れなど「登録したのにエラー」系。
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; . "$HERE/lib.sh"; . "$HERE/store-rules.env"
ROOT="${1:-.}"; cd "$ROOT" || exit 1
REPO_TOP=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
vge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }  # $1 >= $2
has_dep() { grep -qE "^\s+$1:" "$PUB"; }

echo "== store-check (rules: $RULES_CHECKED)"
age=$(( ( $(date +%s) - $(date -d "$RULES_CHECKED" +%s) ) / 86400 ))
[ "$age" -gt 90 ] && warn RULES "store-rules.env が ${age} 日前の情報。公式ページで要件を再確認して更新すること"

# ---- CI のツールバージョン（リポジトリ全体）----
WF="$REPO_TOP/.github/workflows"
if [ -d "$WF" ]; then
  grep -nE "flutter-version:\s*['\"]?[0-9]+\.[0-9]+" "$WF"/*.y*ml 2>/dev/null | while IFS= read -r l; do
    v=$(echo "$l" | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?" | tail -1)
    vge "$v" "$MIN_FLUTTER_16KB" || err S5 "${l##*/} → Flutter $v は 16KB ページ非対応（Play が更新を拒否）。$MIN_FLUTTER_16KB+ に"
  done
  grep -nE "xcode-version:\s*['\"]?[0-9]+" "$WF"/*.y*ml 2>/dev/null | while IFS= read -r l; do
    v=$(echo "$l" | grep -oE "[0-9]+(\.[0-9]+)?" | tail -1)
    vge "$v" "$APPLE_MIN_XCODE" || err I7 "${l##*/} → Xcode $v は App Store にアップロード不可（Xcode $APPLE_MIN_XCODE+ 必須）"
  done
  grep -nE "FLUTTER_VERSION:\s*['\"]?[0-9]" "$WF"/*.y*ml 2>/dev/null | while IFS= read -r l; do
    v=$(echo "$l" | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?" | tail -1)
    vge "$v" "$MIN_FLUTTER_16KB" || err S5 "${l##*/} → FLUTTER_VERSION $v は 16KB ページ非対応"
  done
fi

for P in $(target_packages .); do
  PUB="$P/pubspec.yaml"
  [ -d "$P/android" ] || [ -d "$P/ios" ] || continue
  echo "-- app: $P"

  # ---- バージョン番号 ----
  VER=$(grep -m1 "^version:" "$PUB" | awk '{print $2}' | tr -d "'\"")
  if ! echo "$VER" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$'; then
    err S4 "$PUB version '$VER' が X.Y.Z+N 形式でない（build 番号なしだと versionCode/CFBundleVersion が 1 固定で重複エラー）"
  else
    BN=${VER#*+}
    [ "$BN" -gt "$PLAY_MAX_VERSION_CODE" ] && err S4 "build 番号 $BN が Play 上限超過"
    # 過去タグ（v1.2.3+45 / app-v... 形式）より大きいか
    last=$(git tag -l 2>/dev/null | grep -oE '\+[0-9]+$' | tr -d + | sort -n | tail -1)
    [ -n "$last" ] && [ "$BN" -le "$last" ] && err S4 "build 番号 $BN ≤ 既存タグの $last（「このバージョンコードは使用済み」で拒否）"
  fi

  # ---- マネタイズ・広告 ----
  KIDS=0; { [ "${KIDS_APP:-0}" = 1 ] || grep -qE "^\s+shared_core:" "$PUB" || grep -q "^name: shared_core" "$PUB"; } && KIDS=1
  LIBS=$(find "$P/lib" -name '*.dart' 2>/dev/null)
  if has_dep google_mobile_ads; then
    if [ "$KIDS" = 1 ]; then
      grep -qlE "tagForChildDirectedTreatment|tagForAgeTreatment|TagForAgeTreatment" $LIBS 2>/dev/null \
        || err M1 "子ども向けアプリで AdMob 使用 → RequestConfiguration に子ども向けタグ(TFCD/TFAT)なし（Families ポリシー違反）"
      grep -qlE "maxAdContentRating" $LIBS 2>/dev/null \
        || err M1 "子ども向けアプリ → maxAdContentRating: MaxAdContentRating.g を設定"
      has_dep firebase_analytics && [ -d "$P/ios" ] && warn M4 "Apple Kids カテゴリで出す場合、第三者広告/分析（AdMob・Firebase Analytics）は原則不可"
    fi
    grep -qlE "ConsentInformation|ConsentForm" $LIBS 2>/dev/null \
      || warn M2 "UMP 同意フローなし（EEA/UK 配信で広告が出ない・ポリシー違反）"
    grep -nE "ca-app-pub-[0-9]{16}/[0-9]{10}" $LIBS 2>/dev/null | grep -v "3940256099942544" | while IFS=: read -r f l _; do
      grep -qE "kReleaseMode|String.fromEnvironment" "$f" || warn M3 "$f:$l 本番広告ユニットIDを直書き（--dart-define + debug はテストIDに）"
    done
  fi
  if has_dep purchases_flutter; then
    if ! grep -rqs "restorePurchases" "$P/lib"; then
      # shared_core の共通 Paywall 経由で提供されている可能性があるため警告に留める
      if [ "$KIDS" = 1 ]; then warn M5 "アプリ側に購入の復元導線が見当たらない（共通 Paywall 使用なら可。無ければ審査 3.1.1 リジェクト）"
      else err M5 "購入の復元導線なし（App Store 審査 3.1.1 でリジェクト）"; fi
    fi
    [ "$KIDS" = 1 ] && ! grep -rqsE "ParentalGate|requireParentalGate" "$P/lib" \
      && warn M6 "子ども向けアプリの購入導線に保護者ゲートがない可能性"
  fi

  # M7: 子ども向けアプリの外部リンクに保護者ゲート
  if [ "$KIDS" = 1 ]; then
    grep -rlE "CrossPromoSection\(" "$P/lib" 2>/dev/null | while read -r f; do
      grep -q "beforeOpenStore" "$f" || warn M7 "$f: CrossPromoSection に beforeOpenStore（requireParentalGate）未指定（Apple 1.3 / Families）"
    done
    grep -rlE "launchUrl\(|launch\(" "$P/lib" 2>/dev/null | while read -r f; do
      grep -qE "ParentalGate|requireParentalGate|beforeOpen" "$f" || warn M7 "$f: 外部リンクの前に保護者ゲートがない可能性"
    done
  fi

  # ---- Android ----
  G=$(ls "$P"/android/app/build.gradle* 2>/dev/null | head -1)
  if [ -n "$G" ]; then
    gv() { grep -m1 -E "^\s*$1\s*=?\s*" "$G" | sed -E "s/^\s*$1\s*=?\s*//; s/[\"' ]//g"; }
    TGT=$(gv 'targetSdk(Version)?'); MIN=$(gv 'minSdk(Version)?'); CMP=$(gv 'compileSdk(Version)?')
    AID=$(gv 'applicationId'); VC=$(gv 'versionCode')
    if [[ "$TGT" =~ ^[0-9]+$ ]]; then
      [ "$TGT" -lt "$PLAY_MIN_TARGET_SDK" ] && err S1 "$G targetSdk=$TGT → Play は $PLAY_MIN_TARGET_SDK 以上必須（アップロード拒否）"
    else
      warn S1 "$G targetSdk=$TGT（Flutter 既定値）→ 使用 Flutter の既定が $PLAY_MIN_TARGET_SDK 以上か確認。不明なら明示指定"
    fi
    [[ "$CMP" =~ ^[0-9]+$ && "$TGT" =~ ^[0-9]+$ ]] && [ "$CMP" -lt "$TGT" ] && err S1 "compileSdk=$CMP < targetSdk=$TGT"
    if [[ "$MIN" =~ ^[0-9]+$ ]] && grep -qE "^\s+firebase_" "$PUB" && [ "$MIN" -lt "$FIREBASE_MIN_SDK" ]; then
      err S2 "$G minSdk=$MIN → Firebase は $FIREBASE_MIN_SDK 以上必須（ビルド失敗 / Manifest merger エラー）"
    fi
    [[ "$VC" =~ ^[0-9]+$ ]] && err S3 "$G versionCode=$VC がハードコード → pubspec の build 番号が反映されず重複エラー。flutter.versionCode に"
    [[ "$AID" == com.example* ]] && err S6 "applicationId=$AID → Play は com.example を拒否"
    grep -q "ndkVersion\s*=\?\s*\"2[0-7]\." "$G" && err S5 "$G ndkVersion が r28 未満（16KB 非対応）"

    MF="$P/android/app/src/main/AndroidManifest.xml"
    if has_dep google_mobile_ads; then
      grep -q "com.google.android.gms.ads.APPLICATION_ID" "$MF" 2>/dev/null \
        || err S7 "$MF に AdMob APPLICATION_ID meta-data なし（起動直後にクラッシュ）"
      warn S8 "広告SDK使用 → Play Console の「広告ID」申告を『使用する』に（不一致だと審査リジェクト）"
    fi
    grep -q "com.google.android.gms.permission.AD_ID" "$MF" 2>/dev/null && ! has_dep google_mobile_ads \
      && warn S8 "AD_ID 権限宣言あり → Play Console の広告ID申告と一致させる"
    if has_dep google_sign_in || grep -q "GoogleAuthProvider\|signInWithGoogle" -r "$P/lib" 2>/dev/null; then
      warn S9 "Google サインイン使用 → Firebase に『アップロード鍵』と『Play アプリ署名鍵』両方の SHA-1 を登録（未登録だと本番のみ DEVELOPER_ERROR 10）"
    fi
    has_dep purchases_flutter && warn S10 "RevenueCat 使用 → Play で課金アイテム有効化・サービスアカウント連携済みか、entitlement ID がダッシュボードと一致するか確認（shared_core #58）"
  fi

  # ---- iOS ----
  if [ -d "$P/ios/Runner" ]; then
    PL="$P/ios/Runner/Info.plist"; PBX="$P/ios/Runner.xcodeproj/project.pbxproj"
    [ -f "$PBX" ] || err I4 "$P/ios/Runner.xcodeproj がない（iOS プロジェクト不完全。flutter create --platforms=ios . で再生成）"
    [ -f "$P/ios/Runner/PrivacyInfo.xcprivacy" ] || err I1 "$P/ios/Runner/PrivacyInfo.xcprivacy なし（ITMS-91053 で警告/拒否）"
    grep -A1 "CFBundleVersion" "$PL" 2>/dev/null | grep -q "FLUTTER_BUILD_NUMBER\|CURRENT_PROJECT_VERSION" \
      || err I3 "$PL CFBundleVersion がハードコード → build 番号重複でアップロード拒否"
    BID=$(grep -m1 "PRODUCT_BUNDLE_IDENTIFIER" "$PBX" 2>/dev/null | sed -E 's/.*= *"?([^";]+)"?;.*/\1/')
    [[ "$BID" == com.example* ]] && err I4 "Bundle ID=$BID → App Store Connect に登録不可"
    GSI="$P/ios/Runner/GoogleService-Info.plist"
    if [ -f "$GSI" ] && [ -n "$BID" ]; then
      grep -A1 "BUNDLE_ID" "$GSI" | grep -q "<string>$BID</string>" || err I8 "GoogleService-Info.plist の BUNDLE_ID が $BID と不一致（Firebase 初期化失敗）"
    fi
    # 権限の目的文言（ITMS-90683）
    need() { has_dep "$1" && for k in "${@:2}"; do grep -q "$k" "$PL" || err I2 "$1 使用 → Info.plist に $k なし（ITMS-90683 で拒否）"; done; }
    need image_picker NSPhotoLibraryUsageDescription NSCameraUsageDescription
    need camera NSCameraUsageDescription
    need geolocator NSLocationWhenInUseUsageDescription
    need location NSLocationWhenInUseUsageDescription
    need speech_to_text NSSpeechRecognitionUsageDescription NSMicrophoneUsageDescription
    need record NSMicrophoneUsageDescription
    need app_tracking_transparency NSUserTrackingUsageDescription
    need google_mobile_ads GADApplicationIdentifier
    # アイコン 1024 にアルファがあると ITMS-90717
    ICON=$(ls "$P"/ios/Runner/Assets.xcassets/AppIcon.appiconset/*1024*.png 2>/dev/null | head -1)
    if [ -n "$ICON" ]; then
      ct=$(od -An -tu1 -j25 -N1 "$ICON" | tr -d ' ')
      { [ "$ct" = 4 ] || [ "$ct" = 6 ]; } && err I5 "$ICON にアルファチャンネル（ITMS-90717 で拒否）"
    fi
    grep -q "ITSAppUsesNonExemptEncryption" "$PL" 2>/dev/null || warn I6 "Info.plist に ITSAppUsesNonExemptEncryption=false なし（毎回輸出コンプラ質問で提出が止まる）"
  fi
done
summary "store-check"
