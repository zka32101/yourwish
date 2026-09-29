#!/usr/bin/env bash
# Stage 1→2→3 を順に実行。最初に失敗した Stage で停止（高コスト処理を無駄に走らせない）。
# 初回: 10観点デバイステストが未導入のアプリには自動で導入する（NO_BOOTSTRAP=1 で抑止）。
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="${1:-.}"
start=$(date +%s)
if [ "${NO_BOOTSTRAP:-0}" != 1 ]; then
  . "$HERE/lib.sh"
  # 変更のあったアプリだけ（保留中のアプリには触れない）
  for P in $(cd "$ROOT" && target_packages .); do bash "$HERE/bootstrap-tests.sh" "$ROOT/$P"; done
fi
for s in preflight verify release-prep; do
  bash "$HERE/$s.sh" "$ROOT" || { echo "🛑 $s で停止（修正して再実行）"; exit 1; }
done
echo "🚀 ship-cycle 完了 ($(( $(date +%s) - start ))s)"
