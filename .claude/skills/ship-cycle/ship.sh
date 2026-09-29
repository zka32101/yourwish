#!/usr/bin/env bash
# Stage 1→2→3 を順に実行。最初に失敗した Stage で停止（高コスト処理を無駄に走らせない）。
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="${1:-.}"
start=$(date +%s)
for s in preflight verify release-prep; do
  bash "$HERE/$s.sh" "$ROOT" || { echo "🛑 $s で停止（修正して再実行）"; exit 1; }
done
echo "🚀 ship-cycle 完了 ($(( $(date +%s) - start ))s)"
