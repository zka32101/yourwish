#!/usr/bin/env bash
# 10観点デバイステストの初回導入（冪等）。アプリに無いものだけ生成する。
#   - integration_test/perspectives_test.dart, screen_catalog.dart
#   - test_driver/integration_test.dart
#   - .github/workflows/device-test.yml（shared_core の共通ワークフロー呼び出し）
#   - pubspec.yaml の dev_dependencies に integration_test
# 生成物をコミットして PR にすると、CI で初回テストが自動実行される。
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; T="$HERE/templates"
P="${1:-.}"; cd "$P" || exit 1
[ -f pubspec.yaml ] && [ -f lib/main.dart ] && { [ -d android ] || [ -d ios ]; } \
  || { echo "ℹ️  アプリではない（pubspec / lib/main.dart / android|ios なし）→ スキップ"; exit 0; }
PKG=$(grep -m1 "^name:" pubspec.yaml | awk '{print $2}')
TOP=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
made=()

put() {  # put <template> <dest>
  [ -e "$2" ] && return
  mkdir -p "$(dirname "$2")"; sed "s/__PKG__/$PKG/g" "$T/$1" > "$2"; made+=("$2")
}
put perspectives_test.dart integration_test/perspectives_test.dart
put screen_catalog.dart integration_test/screen_catalog.dart
put test_driver/integration_test.dart test_driver/integration_test.dart
# ワークフローはリポジトリ直下のアプリのみ（モノレポのサブアプリは親の CI 設計に従う）
if [ "$(realpath "$TOP")" = "$(realpath .)" ]; then put device-test-caller.yml .github/workflows/device-test.yml; fi

# 旧「6観点」エミュレータテスト（emulator-6check.sh）は 10観点に置き換え（二重実行で CI 課金が増えるため）
for old in $(grep -lsE "emulator-6check\.sh" .github/workflows/*.y*ml 2>/dev/null); do
  git rm -q "$old" 2>/dev/null || rm -f "$old"; made+=("削除: $old（6観点 → 10観点）")
done
[ -f .github/scripts/emulator-6check.sh ] && { git rm -q .github/scripts/emulator-6check.sh 2>/dev/null || rm -f .github/scripts/emulator-6check.sh; made+=("削除: .github/scripts/emulator-6check.sh"); }

if ! grep -qE "^\s+integration_test:" pubspec.yaml; then
  awk '{print} /^dev_dependencies:/ && !d {print "  integration_test:\n    sdk: flutter"; d=1}' pubspec.yaml > pubspec.yaml.tmp \
    && mv pubspec.yaml.tmp pubspec.yaml
  grep -q "^dev_dependencies:" pubspec.yaml || printf '\ndev_dependencies:\n  integration_test:\n    sdk: flutter\n' >> pubspec.yaml
  made+=("pubspec.yaml (integration_test)")
fi
grep -q "^screenshots/" .gitignore 2>/dev/null || { echo "screenshots/" >> .gitignore; }

if [ ${#made[@]} -eq 0 ]; then echo "✅ 10観点テストは導入済み"; exit 0; fi
echo "🆕 10観点テストを導入: ${made[*]}"
echo "→ コミットして PR を作成すると Android の初回テストが自動実行されます。iOS も初回実行するには PR に 'ios-test' ラベルを付ける。"
