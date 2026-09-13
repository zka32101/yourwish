#!/bin/bash

# scripts/detect_regression.sh
# 🔄 リグレッション自動検出 + GitHub PR コメント投稿

set -e

PROJECT_NAME=${1:-"shogi_app"}
BASELINE_FILE="test_results/${PROJECT_NAME}_baseline_metrics.json"
CURRENT_FILE="test_results/${PROJECT_NAME}_current_metrics.json"
REGRESSION_REPORT="test_results/${PROJECT_NAME}_regression_report.md"

echo "════════════════════════════════════════════════════════"
echo "🔄 リグレッション自動検出 開始"
echo "════════════════════════════════════════════════════════"
echo ""
echo "プロジェクト: $PROJECT_NAME"
echo "ベースライン: $BASELINE_FILE"
echo "現在値: $CURRENT_FILE"
echo ""

# ═══════════════════════════════════════════════════════════════
# Step 1: ベースラインが存在しない場合は作成
# ═══════════════════════════════════════════════════════════════

if [ ! -f "$BASELINE_FILE" ]; then
  echo "📝 初回実行: ベースラインを作成"
  cp "$CURRENT_FILE" "$BASELINE_FILE"
  echo "✅ ベースライン作成完了: $BASELINE_FILE"
  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# Step 2: 前回のテスト結果を取得
# ═══════════════════════════════════════════════════════════════

echo "📖 テスト結果の比較:"
echo ""

BASELINE=$(cat "$BASELINE_FILE")
CURRENT=$(cat "$CURRENT_FILE")

# ═══════════════════════════════════════════════════════════════
# Step 3: メトリクスごとに差分を計算
# ═══════════════════════════════════════════════════════════════

> "$REGRESSION_REPORT"
echo "# 📊 リグレッション検出レポート" >> "$REGRESSION_REPORT"
echo "" >> "$REGRESSION_REPORT"
echo "**テスト日時**: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REGRESSION_REPORT"
echo "**プロジェクト**: $PROJECT_NAME" >> "$REGRESSION_REPORT"
echo "" >> "$REGRESSION_REPORT"

REGRESSION_FOUND=false
IMPROVEMENT_FOUND=false

# jq で各メトリクスを抽出
METRICS=$(echo "$BASELINE" | jq 'keys[]' -r)

for METRIC in $METRICS; do
  BASELINE_VAL=$(echo "$BASELINE" | jq ".${METRIC}" 2>/dev/null || echo "null")
  CURRENT_VAL=$(echo "$CURRENT" | jq ".${METRIC}" 2>/dev/null || echo "null")

  # null チェック
  if [ "$BASELINE_VAL" = "null" ] || [ "$CURRENT_VAL" = "null" ]; then
    echo "⚠️  $METRIC: データ不完全（スキップ）"
    continue
  fi

  # 数値チェック
  if ! [[ "$BASELINE_VAL" =~ ^[0-9]+\.?[0-9]*$ ]] || ! [[ "$CURRENT_VAL" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    echo "⚠️  $METRIC: 数値でない（スキップ）"
    continue
  fi

  # 差分計算 (Bash で計算)
  if (( $(echo "$BASELINE_VAL != 0" | bc -l) )); then
    CHANGE=$(echo "scale=1; ($CURRENT_VAL - $BASELINE_VAL) / $BASELINE_VAL * 100" | bc)
  else
    CHANGE=0
  fi

  # リグレッション判定（10% 以上の悪化）
  if (( $(echo "$CHANGE > 10" | bc -l) )); then
    echo "❌ リグレッション検出: $METRIC"
    echo "   基準値: $BASELINE_VAL"
    echo "   現在値: $CURRENT_VAL"
    echo "   悪化度: +${CHANGE}%"
    echo ""

    echo "## ❌ リグレッション: \`$METRIC\`" >> "$REGRESSION_REPORT"
    echo "| 項目 | 値 |" >> "$REGRESSION_REPORT"
    echo "|---|---|" >> "$REGRESSION_REPORT"
    echo "| 基準値 | $BASELINE_VAL |" >> "$REGRESSION_REPORT"
    echo "| 現在値 | $CURRENT_VAL |" >> "$REGRESSION_REPORT"
    echo "| 悪化度 | +${CHANGE}% |" >> "$REGRESSION_REPORT"
    echo "" >> "$REGRESSION_REPORT"

    REGRESSION_FOUND=true

  # 改善判定（5% 以上の改善）
  elif (( $(echo "$CHANGE < -5" | bc -l) )); then
    echo "✅ 改善検出: $METRIC"
    echo "   改善度: ${CHANGE}%"
    echo ""

    echo "## ✅ 改善: \`$METRIC\`" >> "$REGRESSION_REPORT"
    echo "- 改善度: ${CHANGE}%" >> "$REGRESSION_REPORT"
    echo "" >> "$REGRESSION_REPORT"

    IMPROVEMENT_FOUND=true

  else
    echo "✅ $METRIC: 安定（変化: ${CHANGE}%）"
  fi
done

# ═══════════════════════════════════════════════════════════════
# Step 4: レポートをファイルに保存
# ═══════════════════════════════════════════════════════════════

echo "" >> "$REGRESSION_REPORT"
echo "---" >> "$REGRESSION_REPORT"

if [ "$REGRESSION_FOUND" = true ]; then
  echo "" >> "$REGRESSION_REPORT"
  echo "⚠️ **推奨アクション**" >> "$REGRESSION_REPORT"
  echo "" >> "$REGRESSION_REPORT"
  echo "- [ ] コードの性能悪化原因を調査" >> "$REGRESSION_REPORT"
  echo "- [ ] ボトルネックを特定" >> "$REGRESSION_REPORT"
  echo "- [ ] 最適化を実施" >> "$REGRESSION_REPORT"
  echo "- [ ] テストを再実行して改善を確認" >> "$REGRESSION_REPORT"
fi

if [ "$IMPROVEMENT_FOUND" = true ]; then
  echo "" >> "$REGRESSION_REPORT"
  echo "🎉 **パフォーマンス改善が検出されました！**" >> "$REGRESSION_REPORT"
fi

# ═══════════════════════════════════════════════════════════════
# Step 5: GitHub PR にコメント投稿（CI 環境の場合）
# ═══════════════════════════════════════════════════════════════

if [ -n "$GITHUB_EVENT_PATH" ] && [ -n "$GITHUB_TOKEN" ]; then
  echo ""
  echo "📢 GitHub PR へコメント投稿中..."

  PR_NUMBER=$(jq -r '.pull_request.number' "$GITHUB_EVENT_PATH" 2>/dev/null || echo "")

  if [ -n "$PR_NUMBER" ] && command -v gh &> /dev/null; then
    # レポート内容を PR コメントとして投稿
    gh pr comment "$PR_NUMBER" -F "$REGRESSION_REPORT" || echo "⚠️  PR コメント投稿スキップ（PR 番号なし）"
    echo "✅ PR #$PR_NUMBER にコメント投稿完了"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# Step 6: 結果判定
# ═══════════════════════════════════════════════════════════════

echo ""
echo "════════════════════════════════════════════════════════"

if [ "$REGRESSION_FOUND" = true ]; then
  echo "❌ リグレッション検出: コード変更にて性能悪化が見られます"
  echo "📋 詳細レポート: $REGRESSION_REPORT"
  echo ""
  cat "$REGRESSION_REPORT"
  echo ""
  exit 1
else
  echo "✅ リグレッション検出テスト: PASS"
  echo ""
  cat "$REGRESSION_REPORT"
  echo ""
  # ベースラインを更新（現在値を新しいベースラインに）
  cp "$CURRENT_FILE" "$BASELINE_FILE"
  echo "✅ ベースラインを更新: $BASELINE_FILE"
  exit 0
fi
