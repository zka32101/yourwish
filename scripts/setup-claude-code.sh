#!/bin/bash

# Claude Code Docker セットアップ・最適化スクリプト
#
# 使用方法:
#   ./scripts/setup-claude-code.sh          # 標準セットアップ
#   ./scripts/setup-claude-code.sh clean    # キャッシュクリーンアップ

set -e

# カラー出力
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"
ENV_EXAMPLE="$PROJECT_ROOT/.env.example"

echo -e "${BLUE}===== Claude Code Docker セットアップ =====${NC}"

# .env ファイルが存在しない場合は作成
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}→ .env ファイルを作成中...${NC}"
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    echo -e "${GREEN}✓ .env ファイルを作成しました${NC}"
    echo -e "${YELLOW}  環境に合わせて $ENV_FILE を編集してください${NC}"
fi

# Docker Compose ボリュームの確認
echo -e "\n${BLUE}→ Docker ボリュームをチェック中...${NC}"
DOCKER_COMPOSE="docker-compose"

# docker-compose の存在確認
if ! command -v $DOCKER_COMPOSE &> /dev/null; then
    echo -e "${YELLOW}⚠ docker-compose コマンドが見つかりません${NC}"
    echo -e "  Docker Desktop をインストール、または docker-compose をインストールしてください"
    exit 1
fi

# ボリュームの作成（存在しない場合）
echo -e "${YELLOW}→ npm-cache ボリュームを確保中...${NC}"
if [ "$1" = "clean" ]; then
    echo -e "${YELLOW}→ キャッシュをクリーンアップ中...${NC}"
    $DOCKER_COMPOSE down -v 2>/dev/null || true
    echo -e "${GREEN}✓ キャッシュをクリア${NC}"
fi

# npm キャッシュディレクトリの初期化
echo -e "\n${BLUE}→ npm キャッシュ設定を初期化中...${NC}"
mkdir -p "$PROJECT_ROOT/claude-home" "$PROJECT_ROOT/.npm-cache"
chmod 755 "$PROJECT_ROOT/claude-home" "$PROJECT_ROOT/.npm-cache"
echo -e "${GREEN}✓ キャッシュディレクトリを準備${NC}"

# Docker イメージのプル（最新化）
echo -e "\n${BLUE}→ Docker イメージを更新中...${NC}"
$DOCKER_COMPOSE pull 2>/dev/null || echo -e "${YELLOW}⚠ イメージプル失敗（ネットワーク接続確認）${NC}"

echo -e "\n${BLUE}→ Claude Code CLI をインストール中...${NC}"
echo -e "${YELLOW}  初回実行のため数分かかります...${NC}"

# Claude Code のインストール（初回のみ）
if ! $DOCKER_COMPOSE exec -T claude npm list -g @anthropic-ai/claude-code &>/dev/null 2>&1; then
    $DOCKER_COMPOSE run --rm claude npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}✓ Claude Code CLI をインストール${NC}"
else
    echo -e "${GREEN}✓ Claude Code CLI は既にインストール済み${NC}"
fi

# npm グローバル設定の最適化
echo -e "\n${BLUE}→ npm 設定を最適化中...${NC}"
$DOCKER_COMPOSE run --rm claude npm config set prefer-offline true
$DOCKER_COMPOSE run --rm claude npm config set audit false
echo -e "${GREEN}✓ npm キャッシュ・オフラインモードを有効化${NC}"

# セッション情報の確認
echo -e "\n${BLUE}→ Claude Code セッション情報を確認中...${NC}"
CLAUDE_SESSION_DIR="$PROJECT_ROOT/claude-home"
if [ -d "$CLAUDE_SESSION_DIR" ]; then
    SESSION_COUNT=$(find "$CLAUDE_SESSION_DIR" -name "*.json" 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ セッション情報: $SESSION_COUNT 個のファイル${NC}"
else
    echo -e "${YELLOW}⚠ セッション情報はまだ保存されていません${NC}"
fi

# 最終確認
echo -e "\n${GREEN}===== セットアップ完了 =====${NC}"
echo ""
echo -e "${BLUE}次のステップ:${NC}"
echo -e "  1. Docker コンテナを起動:"
echo -e "     ${YELLOW}docker-compose up -d claude${NC}"
echo ""
echo -e "  2. コンテナに接続:"
echo -e "     ${YELLOW}docker-compose exec claude bash${NC}"
echo ""
echo -e "  3. Claude Code セッション確認:"
echo -e "     ${YELLOW}claude-code auth status${NC}"
echo ""
echo -e "${BLUE}クリーンアップ:${NC}"
echo -e "  キャッシュをリセットする場合:"
echo -e "     ${YELLOW}./scripts/setup-claude-code.sh clean${NC}"
echo ""
echo -e "${BLUE}リソース設定:${NC}"
echo -e "  環境に合わせて ${YELLOW}.env${NC} ファイルを編集してください"
echo ""
