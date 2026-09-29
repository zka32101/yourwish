#!/usr/bin/env bash
# Stage 3: リリース準備チェック → RELEASE_REPORT.md を生成
# ビルドはしない（APK/AAB は CI の release-readiness-check / deploy に任せる）。
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; . "$HERE/lib.sh"
ROOT="${1:-.}"; cd "$ROOT" || exit 1
OUT="${REPORT:-RELEASE_REPORT.md}"
BASE=$(default_base)
USER_TODO=()

echo "== Stage 3: release-prep"
for P in $(target_packages .); do
  PUB="$P/pubspec.yaml"
  grep -q "^publish_to: *['\"]\?none" "$PUB" && [ ! -d "$P/android" ] && continue  # 非アプリのパッケージは対象外
  echo "-- app: $P"
  VER=$(grep -m1 "^version:" "$PUB" | awk '{print $2}')
  [ -z "$VER" ] && { err P15 "$PUB に version がない"; continue; }
  BASE_VER=$(git show "$BASE:$(realpath --relative-to="$(git rev-parse --show-toplevel)" "$PUB")" 2>/dev/null | grep -m1 "^version:" | awk '{print $2}')
  if [ -n "$BASE_VER" ] && [ "$BASE_VER" = "$VER" ]; then
    warn P15 "$P: version $VER が $BASE から未更新（build 番号 +N を上げる）"
  elif [ -n "$BASE_VER" ]; then
    b0=${BASE_VER#*+}; b1=${VER#*+}
    [ "$b1" -le "$b0" ] 2>/dev/null && err P15 "$P: build 番号 $b1 ≤ $b0（ストアが拒否）"
  fi
  CL=$(ls "$P"/CHANGELOG.md 2>/dev/null)
  if [ -n "$CL" ]; then grep -q "${VER%%+*}" "$CL" || warn P15 "$CL に ${VER%%+*} の記載がない"; fi

  if [ -d "$P/android" ]; then
    G=$(ls "$P"/android/app/build.gradle* 2>/dev/null | head -1)
    grep -q "signingConfigs" "$G" 2>/dev/null || warn P15 "$G に signingConfigs がない（release 署名）"
    grep -qE "signingConfig\s*=?\s*signingConfigs\.debug" "$G" 2>/dev/null && grep -A3 "release" "$G" | grep -q "signingConfigs.debug" \
      && err P15 "$G: release が debug 署名のまま"
    [ -f "$P/android/key.properties" ] || USER_TODO+=("$P: 署名鍵（key.properties / GitHub Secrets）を用意")
    grep -q 'android.permission.INTERNET' "$P/android/app/src/main/AndroidManifest.xml" 2>/dev/null \
      || warn P15 "$P: AndroidManifest に INTERNET 権限なし（Firebase/広告が release で動かない）"
    grep -q "ca-app-pub-3940256099942544" -r "$P/lib" "$P/android/app/src/main/AndroidManifest.xml" 2>/dev/null \
      && warn P15 "$P: AdMob テスト ID が残っている（本番前に差し替え）"
  fi
  grep -rqn "kDebugMode\s*=\s*true\|debugShowCheckedModeBanner:\s*true" "$P/lib" 2>/dev/null \
    && warn P15 "$P: デバッグフラグが true"
  grep -rn "print(" "$P/lib" --include=*.dart 2>/dev/null | grep -v "debugPrint\|//" | head -1 | grep -q . \
    && warn P15 "$P: print() が残存（debugPrint か削除）"
  [ -f "$P/ios/Runner/Info.plist" ] && ! grep -q "ITSAppUsesNonExemptEncryption" "$P/ios/Runner/Info.plist" \
    && warn P15 "$P: Info.plist に ITSAppUsesNonExemptEncryption なし（審査で毎回質問される）"
  echo "$P $VER" >> "$SC_LOG.apps"
done

# レポート生成
{
  echo "# Release Report"
  echo; echo "- 生成: $(date '+%Y-%m-%d %H:%M')  / base: \`$BASE\` / HEAD: \`$(git rev-parse --short HEAD 2>/dev/null)\`"
  echo; echo "## 対象アプリ"; echo
  if [ -f "$SC_LOG.apps" ]; then sed 's/^/- /' "$SC_LOG.apps"; else echo "- なし"; fi
  echo; echo "## チェック結果"; echo
  if [ -s "$SC_LOG" ]; then sed -e 's/^E /- ❌ /' -e 's/^W /- ⚠️ /' "$SC_LOG"; else echo "- ✅ 指摘なし"; fi
  echo; echo "## 変更点（$BASE 以降）"; echo
  git log --no-merges --pretty='- %s' "$BASE"..HEAD 2>/dev/null | head -30
  echo; echo "## ユーザー作業（Claude は実施しない）"; echo
  for t in "${USER_TODO[@]}"; do echo "- [ ] $t"; done
  echo "- [ ] ストア掲載情報・スクリーンショット確認"
  echo "- [ ] ストアでの公開 / 審査提出"
} > "$OUT"
rm -f "$SC_LOG.apps"
echo "📝 $OUT を生成"
summary "release-prep"
