#!/bin/bash
set -euo pipefail

# Claude Code セッション開始フック
# Docker Flask ビルド環境を自動初期化
#
# リモート環境でのみ実行されます
# 非同期モードで実行（セッション開始を遅延させない）

# 非同期モード有効化（タイムアウト: 5分）
echo '{"async": true, "asyncTimeout": 300000}'

# リモート環境のみ実行
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_ROOT"

# カラー出力
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Flask Build Environment Setup${NC}"

# 1. Docker daemon 確認
if ! command -v docker &> /dev/null; then
  echo -e "${YELLOW}⚠ Docker not found${NC}"
  exit 0
fi

if ! docker ps > /dev/null 2>&1; then
  echo -e "${YELLOW}⚠ Docker daemon not running${NC}"
  exit 0
fi

echo -e "${GREEN}✅ Docker daemon${NC}"

# 2. Docker compose 確認
if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
  echo -e "${YELLOW}⚠ Docker Compose not found${NC}"
  exit 0
fi

echo -e "${GREEN}✅ Docker Compose${NC}"

# 3. Flutter コンテナ起動（既に起動していればスキップ）
if ! docker compose ps flutter 2>/dev/null | grep -q "flutter"; then
  echo -e "${YELLOW}→ Starting Flutter container...${NC}"
  docker compose up -d flutter 2>/dev/null || true
fi

echo -e "${GREEN}✅ Flutter environment ready${NC}"
echo -e "${BLUE}📦 Build commands:${NC}"
echo "  docker compose exec flutter bash"
echo "  cd apps/shoukoku_kokugo"
echo "  flutter pub get && flutter build apk --release"
