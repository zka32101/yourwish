#!/bin/bash
set -euo pipefail

# Claude Code セッション開始フック
# Flutter SDK をローカルインストールし、テスト/リンターがそのまま使える状態にする
#
# リモート環境（Claude Code on the web）でのみ実行されます
# 同期モードで実行（依存関係インストール完了を待ってからセッション開始）

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

echo -e "${BLUE}🚀 Flutter environment setup (local, no Docker)${NC}"

FLUTTER_DIR="${FLUTTER_ROOT:-$HOME/flutter}"

# 1. Flutter SDK インストール（未インストールの場合のみ）
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo -e "${YELLOW}→ Installing Flutter SDK (stable)...${NC}"
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR" 2>&1 | tail -5
else
  echo -e "${GREEN}✅ Flutter SDK already present${NC}"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# 次回以降のシェル/コマンドでも Flutter を使えるように永続化
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# 2. Flutter 初期設定（analytics無効化・高速化）
flutter config --no-analytics --no-cli-animations > /dev/null 2>&1 || true
flutter precache --no-input > /dev/null 2>&1 || true

echo -e "${GREEN}✅ Flutter SDK ready: $(flutter --version | head -1)${NC}"

# 3. 各アプリ/パッケージの依存関係を取得（analyze/testがすぐ動くように）
echo -e "${BLUE}📦 Fetching dependencies for packages/apps...${NC}"
for dir in packages/*/ apps/*/; do
  if [ -f "${dir}pubspec.yaml" ]; then
    name="${dir%/}"
    if (cd "$dir" && flutter pub get > /dev/null 2>&1); then
      echo -e "${GREEN}  ✅ ${name}${NC}"
    else
      echo -e "${YELLOW}  ⚠ ${name}: pub get failed (may need manual fix)${NC}"
    fi
  fi
done

echo -e "${BLUE}📌 Quick commands:${NC}"
echo "  cd apps/<app_name> && flutter analyze"
echo "  cd apps/<app_name> && flutter test"
echo "  cd apps/<app_name> && flutter build apk --release"
