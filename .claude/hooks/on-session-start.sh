#!/bin/bash

# Claude Code セッション開始時の自動初期化フック
#
# このスクリプトはセッション開始時に自動実行されます。
# Docker セットアップ・リソース最適化を自動実行します。

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETUP_SCRIPT="$PROJECT_ROOT/scripts/setup-claude-code.sh"

echo "🚀 Claude Code セッション初期化中..."

# セットアップスクリプトが存在する場合のみ実行
if [ -f "$SETUP_SCRIPT" ]; then
    echo "→ Docker セットアップを開始します..."
    "$SETUP_SCRIPT"
    echo "✅ セットアップ完了"
else
    echo "⚠ setup-claude-code.sh が見つかりません"
    echo "  手動セットアップ: ./scripts/setup-claude-code.sh"
fi

echo ""
echo "💡 Docker コンテナ接続コマンド:"
echo "   docker-compose up -d claude"
echo "   docker-compose exec claude bash"
