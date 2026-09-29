#!/usr/bin/env bash
# Stage 1: 静的プリフライト（Flutter 不要・数秒）
# 過去の CI/ビルド失敗の根本原因を grep/find だけで検出する。
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; . "$HERE/lib.sh"
ROOT="${1:-.}"; cd "$ROOT" || exit 1
REPO_TOP=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "== Stage 1: preflight ($(pwd))"
PKGS=$(target_packages .)
[ -z "$PKGS" ] && { ok "対象パッケージなし"; }

for P in $PKGS; do
  echo "-- package: $P"
  PUB="$P/pubspec.yaml"
  DARTS=$(find "$P/lib" -name '*.dart' -not -name '*.g.dart' -not -name '*.freezed.dart' 2>/dev/null)

  # P1: part 生成物欠落
  for f in $(grep -l "^part '.*\.\(freezed\|g\)\.dart';" $DARTS 2>/dev/null); do
    for part in $(grep -o "^part '[^']*'" "$f" | sed "s/part '//;s/'//"); do
      [ -f "$(dirname "$f")/$part" ] || err P1 "$f → $part が存在しない（build_runner 実行・生成物コミット漏れ）"
    done
  done

  # P2: アノテーション依存漏れ
  if grep -lq "@freezed\|@Freezed(" $DARTS 2>/dev/null; then
    grep -q "freezed_annotation:" "$PUB" || err P2 "$PUB に freezed_annotation 依存がない"
    grep -q "^\s*freezed:" "$PUB" || warn P2 "$PUB に freezed (dev) がない"
  fi
  if grep -lq "@JsonSerializable\|fromJson(Map<String, dynamic> json) *=> *_\$" $DARTS 2>/dev/null; then
    grep -q "json_annotation:" "$PUB" || err P2 "$PUB に json_annotation 依存がない"
  fi
  if grep -lq "^part '.*\.\(freezed\|g\)\.dart';" $DARTS 2>/dev/null; then
    grep -q "build_runner:" "$PUB" || err P2 "$PUB に build_runner (dev) がない（CI で codegen 不能）"
  fi

  # P3: Firebase インスタンスの早期参照（トップレベル変数・クラスフィールド初期化子のみ。
  #     メソッド内ローカル変数や late final は遅延評価なので対象外）
  FB='(FirebaseFirestore|FirebaseAuth|FirebaseStorage|FirebaseMessaging|FirebaseRemoteConfig|FirebaseAnalytics|FirebaseFunctions)\.instance'
  grep -nE "^(final|var|const|[A-Z][A-Za-z<>]*) +[A-Za-z_]+ *= *$FB|^  (static )?final +[A-Z][A-Za-z<>]* +_?[A-Za-z]+ *= *$FB" $DARTS 2>/dev/null \
    | while IFS= read -r l; do warn P3 "$l （Firebase.initializeApp 前に評価されると起動クラッシュ。getter か late final に）"; done

  # P4: ハードコード UID
  grep -nE "['\"](current_user|test_user|dummy_user|user123)['\"]" $DARTS 2>/dev/null \
    | while IFS= read -r l; do err P4 "$l （FirebaseAuth の uid を使う）"; done

  # P5: assets 宣言先の存在
  awk '/^flutter:/{f=1} f&&/^  assets:/{a=1;next} a&&/^    - /{print $2;next} a&&!/^    /{a=0}' "$PUB" 2>/dev/null \
    | while read -r asset; do
        [ -e "$P/$asset" ] || err P5 "$PUB の asset '$asset' が存在しない"
      done
  grep -rnoE "['\"](assets/[^'\"]+\.(png|jpg|webp|json))['\"]" $DARTS 2>/dev/null | head -200 \
    | while IFS=: read -r file line m; do
        a=$(echo "$m" | tr -d "'\""); [ -e "$P/$a" ] || [ -e "$P/lib/$a" ] || warn P5 "$file:$line $a が見つからない"
      done

  # P6: applicationId と google-services.json
  GS="$P/android/app/google-services.json"
  GRADLE=$(ls "$P"/android/app/build.gradle* 2>/dev/null | head -1)
  if [ -f "$GS" ] && [ -n "$GRADLE" ]; then
    AID=$(grep -oE "applicationId\s*=?\s*['\"][^'\"]+" "$GRADLE" | head -1 | grep -oE "[a-zA-Z0-9_.]+$")
    if [ -n "$AID" ] && ! grep -q "\"package_name\": *\"$AID\"" "$GS"; then
      err P6 "applicationId=$AID が google-services.json の package_name に無い"
    fi
  fi

  # P7: テスト
  if [ ! -d "$P/test" ] || [ -z "$(find "$P/test" -name '*_test.dart' 2>/dev/null)" ]; then
    warn P7 "$P/test に *_test.dart が無い"
  elif grep -lq "Counter increments smoke test" "$P"/test/*.dart 2>/dev/null; then
    err P7 "$P/test にテンプレのままの widget_test（カウンタ）が残っている"
  fi

  # P11: ダミーアイコン（100 byte 未満の launcher PNG）
  find "$P/android/app/src/main/res" -name 'ic_launcher*.png' -size -100c 2>/dev/null \
    | while read -r f; do warn P11 "$f がダミー画像の可能性（<100B）"; done
done

# ---- リポジトリ全体 ----
WF="$REPO_TOP/.github/workflows"
if [ -d "$WF" ]; then
  # P8: SHA 未固定のサードパーティ Action
  grep -nE "uses:\s*[^./][^@]+@v?[0-9][^ ]*\s*$" "$WF"/*.y*ml 2>/dev/null | grep -v "actions/\|github/" \
    | while IFS= read -r l; do warn P8 "$l （commit SHA 固定推奨）"; done
  # P9: macOS ランナーが push で走る
  for f in $(grep -l "runs-on:.*macos" "$WF"/*.y*ml 2>/dev/null); do
    grep -qE "^\s*push:" "$f" && ! grep -q "github.event_name" "$f" && err P9 "$f: macOS ランナーが push トリガー（workflow_dispatch/PR のみに）"
  done
fi

# P10: 秘密情報
git -C "$REPO_TOP" ls-files -z 2>/dev/null | xargs -0 -r grep -nIE \
  "(goog_[A-Za-z0-9]{20,}|appl_[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9-]{20,}|ghp_[A-Za-z0-9]{30,}|-----BEGIN (RSA |EC )?PRIVATE KEY-----)" 2>/dev/null \
  | cut -c1-160 | while IFS= read -r l; do err P10 "$l"; done
git -C "$REPO_TOP" ls-files 2>/dev/null | grep -E "\.(jks|keystore|p12|p8)$|key\.properties$" \
  | while read -r f; do err P10 "署名鍵/鍵設定がコミットされている: $f"; done

# P12: 旧組織 URL
git -C "$REPO_TOP" grep -n "org-zka32101" -- ":!*.md" 2>/dev/null | cut -c1-160 \
  | while IFS= read -r l; do err P12 "$l"; done

summary "preflight"
