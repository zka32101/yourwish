#!/bin/bash
# SessionStart フック: 小学コレシリーズ統一セットアップ自動実行
# 新規セッション立ち上げ時に、全7つアプリの環境セットアップを自動実施

set -euo pipefail

# リモートセッション確認
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  echo "ℹ️  ローカルセッションです - セットアップをスキップ"
  exit 0
fi

# プロジェクトディレクトリ確認
if [ -z "${CLAUDE_PROJECT_DIR:-}" ]; then
  echo "❌ CLAUDE_PROJECT_DIR が設定されていません"
  exit 1
fi

cd "$CLAUDE_PROJECT_DIR"

# セットアップスクリプト確認
if [ ! -f "setup-all-shogaku-kore-apps.sh" ]; then
  echo "❌ setup-all-shogaku-kore-apps.sh が見つかりません"
  exit 1
fi

echo "🎓 小学コレシリーズ統一セットアップを実行中..."
echo ""

# セットアップ実行（ユーザー入力を自動化）
if echo "y" | bash setup-all-shogaku-kore-apps.sh 2>&1; then
  echo ""
  echo "✅ SessionStart フック完了"
  exit 0
else
  echo ""
  echo "⚠️  セットアップ完了時にエラーが発生しました"
  echo "   手動で以下を実行してください:"
  echo "   bash setup-all-shogaku-kore-apps.sh"
  exit 1
fi
