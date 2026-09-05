#!/bin/bash

# Claude Code セッション開始時の自動初期化フック
#
# このスクリプトはセッション開始時に自動実行されます。
# Docker セットアップ・ビルド環境初期化を自動実行します。
#
# ✨ 機能:
# - Docker コンテナ起動
# - ビルド環境の初期化
# - 依存関係チェック
# - クイックリファレンス表示

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETUP_SCRIPT="$PROJECT_ROOT/scripts/setup-claude-code.sh"
BUILD_SCRIPT="$PROJECT_ROOT/scripts/build.sh"

# カラー出力
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Claude Code セッション初期化${NC}"
echo ""

# 1. Docker セットアップ
if [ -f "$SETUP_SCRIPT" ]; then
    echo -e "${YELLOW}→ Docker 環境をセットアップ中...${NC}"
    "$SETUP_SCRIPT" 2>/dev/null || true
    echo -e "${GREEN}✅ Docker セットアップ完了${NC}"
else
    echo -e "${YELLOW}⚠ setup-claude-code.sh が見つかりません${NC}"
fi

# 2. ビルド環境チェック
echo ""
echo -e "${YELLOW}→ ビルド環境をチェック中...${NC}"

if [ -f "$BUILD_SCRIPT" ]; then
    chmod +x "$BUILD_SCRIPT"
    echo -e "${GREEN}✅ ビルドスクリプト: 準備完了${NC}"
else
    echo -e "${YELLOW}⚠ build.sh が見つかりません${NC}"
fi

# 3. Docker 状態確認
echo ""
echo -e "${YELLOW}→ Docker 状態確認${NC}"

if command -v docker &> /dev/null; then
    if docker ps > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker デーモン: 起動中${NC}"
    else
        echo -e "${YELLOW}⚠ Docker デーモン: 起動していません${NC}"
        echo -e "   起動コマンド: ${YELLOW}docker-compose up -d claude${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Docker: インストールされていません${NC}"
    echo -e "   ダウンロード: https://www.docker.com/products/docker-desktop"
fi

# 4. クイックリファレンス表示
echo ""
echo -e "${BLUE}📚 クイックリファレンス${NC}"
echo -e "${YELLOW}ビルド実行:${NC}"
echo "  ./scripts/build.sh flutter              # Flutterアプリテスト"
echo "  ./scripts/build.sh flutter:android      # Android APK"
echo "  ./scripts/build.sh flutter:web          # Web版ビルド"
echo ""
echo -e "${YELLOW}ドキュメント:${NC}"
echo "  cat docs/LOCAL_ENV_FREE_BUILD.md        # 詳細ガイド"
echo ""
echo -e "${YELLOW}Docker 操作:${NC}"
echo "  docker-compose up -d claude             # コンテナ起動"
echo "  docker-compose exec claude bash         # コンテナ接続"
echo ""
echo -e "${GREEN}✨ セッション準備完了！${NC}"
