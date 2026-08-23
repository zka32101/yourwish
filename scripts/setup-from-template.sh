#!/bin/bash

# GitHub Template から新規プロジェクト作成時のセットアップスクリプト
#
# 使用方法:
#   bash scripts/setup-from-template.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 GitHub Template セットアップを開始します..."
echo ""

# テンプレート用ファイルの削除
echo "→ テンプレート用ファイルをクリーンアップ中..."

rm -f "$PROJECT_ROOT/TEMPLATE_README.md"
rm -f "$PROJECT_ROOT/.github/template-properties.json"
rm -f "$PROJECT_ROOT/scripts/setup-from-template.sh"

echo "✅ クリーンアップ完了"
echo ""

# README 確認
echo "→ プロジェクト情報を確認してください:"
echo "  1. CLAUDE.md を編集してプロジェクト説明を追加"
echo "  2. README.md を編集"
echo "  3. .env.example で環境設定を確認"
echo ""

# Git 初期化確認
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "→ Git リポジトリを初期化中..."
    cd "$PROJECT_ROOT"
    git init
    git add .
    git commit -m "Initial commit from Claude Code Docker Template"
    echo "✅ Git リポジトリを初期化しました"
else
    echo "✅ Git リポジトリは既に初期化されています"
fi

echo ""
echo "🎉 セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "  1. CLAUDE.md を編集:"
echo "     vi CLAUDE.md"
echo ""
echo "  2. Docker セットアップを実行:"
echo "     ./scripts/setup-claude-code.sh"
echo ""
echo "  3. Docker コンテナを起動:"
echo "     docker-compose up -d claude"
echo "     docker-compose exec claude bash"
echo ""
echo "Happy coding! 🚀"
