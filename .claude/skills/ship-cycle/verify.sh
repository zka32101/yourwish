#!/usr/bin/env bash
# Stage 2: pub get → (必要時のみ) codegen → analyze → test。差分パッケージのみ。
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; . "$HERE/lib.sh"
ROOT="${1:-.}"; cd "$ROOT" || exit 1

if ! command -v flutter >/dev/null; then
  [ -x "$HOME/flutter/bin/flutter" ] && export PATH="$HOME/flutter/bin:$PATH"
fi
if ! command -v flutter >/dev/null; then
  warn ENV "Flutter SDK なし → Stage 2 はスキップ（CI に委ねる。SDK は新規インストールしない）"
  summary "verify"; exit 0
fi
export PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}" CI=true FLUTTER_SUPPRESS_ANALYTICS=true

echo "== Stage 2: verify"
for P in $(target_packages .); do
  echo "-- package: $P"
  pushd "$P" >/dev/null || continue
  # P13: stale lock / tool cache（CLEAN=1 のときのみ）
  [ "${CLEAN:-0}" = 1 ] && { rm -rf .dart_tool build; git ls-files --error-unmatch pubspec.lock >/dev/null 2>&1 || rm -f pubspec.lock; }

  if ! { [ "${OFFLINE:-0}" = 1 ] && flutter pub get --offline >/dev/null 2>&1; } && ! flutter pub get >/tmp/sc_pubget.log 2>&1; then
    err P13 "$P: pub get 失敗 → $(tail -3 /tmp/sc_pubget.log | tr '\n' ' ')（CLEAN=1 で再試行）"; popd >/dev/null; continue
  fi

  # P14: codegen は生成物が欠落 or ソースより古い時だけ
  if grep -q "build_runner:" pubspec.yaml; then
    need=0
    for f in $(grep -rl "^part '.*\.\(freezed\|g\)\.dart';" lib 2>/dev/null); do
      for part in $(grep -o "^part '[^']*'" "$f" | sed "s/part '//;s/'//"); do
        g="$(dirname "$f")/$part"; { [ ! -f "$g" ] || [ "$f" -nt "$g" ]; } && need=1
      done
    done
    if [ "$need" = 1 ] || [ "${FORCE_CODEGEN:-0}" = 1 ]; then
      dart run build_runner build --delete-conflicting-outputs >/tmp/sc_br.log 2>&1 \
        || err P14 "$P: build_runner 失敗 → $(grep -m3 -i error /tmp/sc_br.log | tr '\n' ' ')"
      git diff --quiet -- '*.freezed.dart' '*.g.dart' 2>/dev/null \
        || warn P14 "$P: 生成物に差分あり → コミットに含めること"
    else ok "codegen 不要（生成物は最新）"; fi
  fi

  # analyze: error のみブロッカー
  flutter analyze --no-fatal-infos --no-fatal-warnings >/tmp/sc_an.log 2>&1
  ne=$(grep -c "^\s*error •" /tmp/sc_an.log); nw=$(grep -c "^\s*warning •" /tmp/sc_an.log)
  [ "$ne" -gt 0 ] && { err ANALYZE "$P: error $ne 件"; grep "^\s*error •" /tmp/sc_an.log | head -10; }
  [ "$nw" -gt 0 ] && warn ANALYZE "$P: warning $nw 件"
  [ "$ne" -eq 0 ] && ok "analyze"

  # test
  if [ "${SKIP_TEST:-0}" != 1 ] && [ -n "$(find test -name '*_test.dart' 2>/dev/null)" ]; then
    if flutter test --reporter=compact -j "${TEST_JOBS:-2}" >/tmp/sc_test.log 2>&1; then ok "test"
    else err TEST "$P: テスト失敗"; grep -E "\[E\]|Expected|Actual|Error" /tmp/sc_test.log | head -15; fi
  fi
  popd >/dev/null
done
summary "verify"
