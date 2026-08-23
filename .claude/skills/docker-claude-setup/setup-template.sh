#!/bin/bash

# Docker Claude Code セットアップ - プロジェクトテンプレート生成スクリプト
#
# 新規プロジェクトで Docker + Claude Code セットアップを使用する場合
# このスクリプトでテンプレートファイルを自動生成できます。
#
# 使用方法:
#   bash setup-template.sh /path/to/new-project

set -e

if [ -z "$1" ]; then
    echo "使用方法: $0 <プロジェクトディレクトリ>"
    echo ""
    echo "例:"
    echo "  $0 ~/my-new-project"
    exit 1
fi

PROJECT_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ディレクトリ作成
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "🚀 Docker Claude Code テンプレートを生成中..."
echo "📁 プロジェクト: $PROJECT_DIR"

# コピーするファイル一覧
declare -a FILES=(
    "docker-compose.yml"
    ".dockerignore"
    ".env.example"
    "scripts/setup-claude-code.sh"
)

# ファイルコピー
echo "→ テンプレートファイルをコピー中..."
for file in "${FILES[@]}"; do
    dir=$(dirname "$file")
    mkdir -p "$dir"
    if [ -f "$SOURCE_REPO/$file" ]; then
        cp "$SOURCE_REPO/$file" "$file"
        echo "  ✓ $file"
    else
        echo "  ⚠ $file (スキップ - ファイルなし)"
    fi
done

# .gitignore 更新
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# Docker & Claude Code
claude-home/
npm-cache/
.env
.env.local
node_modules/
EOF
    echo "  ✓ .gitignore (新規作成)"
else
    # 既存の .gitignore に Docker セクションを追加
    if ! grep -q "claude-home" .gitignore; then
        cat >> .gitignore << 'EOF'

# Docker & Claude Code
claude-home/
npm-cache/
.env
EOF
        echo "  ✓ .gitignore (更新)"
    else
        echo "  ✓ .gitignore (既に設定済み)"
    fi
fi

# CLAUDE.md テンプレート作成（存在しない場合）
if [ ! -f "CLAUDE.md" ]; then
    cat > CLAUDE.md << 'EOF'
# CLAUDE.md - プロジェクト説明

このファイルは Claude Code のプロジェクトコンテキストです。

## プロジェクト概要

<!-- プロジェクトの説明をここに記入 -->

## セットアップ

### Docker を使用する場合（推奨）

```bash
# 初回セットアップ
./scripts/setup-claude-code.sh

# Docker コンテナ起動
docker-compose up -d claude

# コンテナに接続
docker-compose exec claude bash
```

### ローカル（直接）セットアップ

```bash
# Node.js 20+ が必要
npm install -g @anthropic-ai/claude-code
```

## リソース設定

`.env` ファイルで環境に応じてカスタマイズ：

```bash
# 低スペック環境（2GB RAM）
NODE_MAX_MEMORY=256
CLAUDE_MEMORY_LIMIT=512M

# 中程度環境（4GB RAM）
NODE_MAX_MEMORY=512
CLAUDE_MEMORY_LIMIT=1G

# 高スペック環境（8GB以上）
NODE_MAX_MEMORY=1024
CLAUDE_MEMORY_LIMIT=2G
```

詳細は `.env.example` を参照してください。

## その他

<!-- 必要に応じて追加情報 -->
EOF
    echo "  ✓ CLAUDE.md (新規作成)"
else
    echo "  ✓ CLAUDE.md (既に存在)"
fi

# .claude/settings.json テンプレート
echo "→ Claude Code 設定を作成中..."
mkdir -p .claude/hooks

cat > .claude/settings.json << 'EOF'
{
  "hooks": {
    "on_session_start": {
      "description": "セッション開始時に Docker セットアップを自動実行",
      "script": ".claude/hooks/on-session-start.sh",
      "runImmediately": true
    }
  }
}
EOF
echo "  ✓ .claude/settings.json"

# セッション開始フック
cat > .claude/hooks/on-session-start.sh << 'EOF'
#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETUP_SCRIPT="$PROJECT_ROOT/scripts/setup-claude-code.sh"

echo "🚀 Claude Code セッション初期化中..."

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
EOF

chmod +x .claude/hooks/on-session-start.sh
echo "  ✓ .claude/hooks/on-session-start.sh"

# 完了メッセージ
echo ""
echo "✅ セットアップテンプレートの生成が完了しました！"
echo ""
echo "📋 次のステップ:"
echo "   1. cd $PROJECT_DIR"
echo "   2. CLAUDE.md を編集してプロジェクト情報を追加"
echo "   3. ./scripts/setup-claude-code.sh でセットアップ開始"
echo "   4. docker-compose up -d claude で Docker 起動"
echo ""
echo "💡 詳細は CLAUDE.md と .env.example を参照してください"
