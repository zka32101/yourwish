#!/bin/bash
set -euo pipefail

# =====================================================
# Flutter Build Workflow Setup Script
#
# 新規 Flutter プロジェクトへの自動セットアップ
#
# 用法: ./setup-build-workflow.sh <project-path> [project-name]
# 例: ./setup-build-workflow.sh ../kokugo-kore kokugo-kore
# =====================================================

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =====================================================
# 関数定義
# =====================================================

print_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===============================================${NC}"
}

print_step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# =====================================================
# 引数チェック
# =====================================================

if [ $# -lt 1 ]; then
    print_error "引数が足りません"
    echo "用法: $0 <project-path> [project-name]"
    echo "例: $0 ../kokugo-kore kokugo-kore"
    exit 1
fi

PROJECT_PATH="$1"
PROJECT_NAME="${2:-$(basename "$PROJECT_PATH")}"

# プロジェクトパスの確認
if [ ! -d "$PROJECT_PATH" ]; then
    print_error "プロジェクトパスが見つかりません: $PROJECT_PATH"
    exit 1
fi

if [ ! -f "$PROJECT_PATH/pubspec.yaml" ]; then
    print_error "Flutter プロジェクトが見つかりません (pubspec.yaml がありません)"
    exit 1
fi

cd "$PROJECT_PATH"

print_header "Flutter Build Workflow セットアップ開始"
echo "プロジェクト: $PROJECT_NAME"
echo "パス: $(pwd)"
echo ""

# =====================================================
# 1. GitHub ディレクトリ構造作成
# =====================================================

print_step "GitHub Actions ディレクトリを作成中..."

mkdir -p .github/workflows

if [ -d .github/workflows ]; then
    print_success ".github/workflows ディレクトリを作成しました"
else
    print_error ".github/workflows ディレクトリの作成に失敗しました"
    exit 1
fi

# =====================================================
# 2. ビルドワークフローをコピー
# =====================================================

print_step "ビルドワークフロー テンプレートをコピー中..."

# テンプレートファイルを探す
TEMPLATE_PATH="../yourwish/.github/workflows/build-template.yml"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_PATH2="${SCRIPT_DIR}/../.github/workflows/build-template.yml"

if [ -f "$TEMPLATE_PATH" ]; then
    TEMPLATE="$TEMPLATE_PATH"
elif [ -f "$TEMPLATE_PATH2" ]; then
    TEMPLATE="$TEMPLATE_PATH2"
else
    print_error "テンプレートファイル (build-template.yml) が見つかりません"
    echo "想定パス: $TEMPLATE_PATH または $TEMPLATE_PATH2"
    exit 1
fi

cp "$TEMPLATE" ".github/workflows/build-apk.yml"
print_success "build-apk.yml を作成しました"

# =====================================================
# 3. SessionStart Hook を作成
# =====================================================

print_step "SessionStart Hook を設定中..."

mkdir -p .claude/hooks

cat > .claude/hooks/session-start.sh << EOF
#!/bin/bash
set -euo pipefail

# SessionStart Hook for ${PROJECT_NAME}
# Automatically runs when a new Claude Code session starts
# Sets up Flutter dependencies and runs linting/tests

echo "🚀 ${PROJECT_NAME} セッション初期化開始..."

# 1. Flutter 依存関係をインストール
echo "📦 Flutter 依存関係をインストール中..."
flutter pub get

# 2. コード分析を実行
echo "🔍 コード分析を実行中..."
flutter analyze --no-fatal-infos --no-fatal-warnings || true

# 3. ビルド・テストスキルの準備確認
if [ -f ".claude/skills/build-and-test/SKILL.md" ]; then
    echo "✅ build-and-test スキルが利用可能です"
fi

echo "✅ セッション初期化完了！"
echo ""
echo "📝 次のステップ:"
echo "  1. コードを修正"
echo "  2. /build-and-test ${PROJECT_NAME} でエミュレータテストを実行"
echo ""
EOF

chmod +x .claude/hooks/session-start.sh
print_success "SessionStart Hook を作成しました"

# =====================================================
# 4. Claude settings.json を作成または更新
# =====================================================

print_step "Claude Code 設定を準備中..."

mkdir -p .claude

if [ ! -f .claude/settings.json ]; then
    cat > .claude/settings.json << SETTINGS_EOF
{
  "name": "${PROJECT_NAME}",
  "description": "Flutter 教科学習アプリ - テスト自動化環境",
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Read",
      "Write",
      "Edit",
      "Bash",
      "Glob",
      "Grep",
      "Artifact",
      "Agent",
      "Workflow",
      "SendMessage",
      "mcp__Claude_Code_Remote__*",
      "mcp__github__*",
      "mcp__Gmail__*",
      "mcp__Google_Drive__*",
      "*"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": ".claude/hooks/session-start.sh"
      }
    ],
    "on_build_complete": {
      "description": "ビルド完了後の自動テスト実行",
      "script": ".claude/hooks/on-build-complete.sh",
      "trigger": "post-build"
    }
  },
  "docs": {
    "primary": "README.md",
    "additional": [
      "../yourwish/docs/build-ci-cd-guide.md"
    ]
  },
  "recommendations": {
    "tools": [
      {
        "name": "build-and-test",
        "path": ".claude/skills/build-and-test",
        "description": "エミュレータ自動テスト",
        "usage": "/build-and-test ${PROJECT_NAME}"
      }
    ],
    "skills": [
      {
        "name": "build-and-test",
        "description": "エミュレータテスト自動化（6つのテスト観点）",
        "location": ".claude/skills/build-and-test/SKILL.md"
      }
    ]
  },
  "environment": {
    "NODE_VERSION": "20",
    "SUPPORTS_DOCKER": false,
    "AUTO_SETUP": true
  }
}
SETTINGS_EOF

    print_success ".claude/settings.json を作成しました"
else
    print_success ".claude/settings.json は既に存在します"
fi

# =====================================================
# 5. .gitignore に Claude ファイルを追加
# =====================================================

print_step ".gitignore を更新中..."

if [ ! -f .gitignore ]; then
    touch .gitignore
fi

# Claude ファイルを .gitignore に追加（重複をチェック）
if ! grep -q "^\.claude/" .gitignore; then
    echo "" >> .gitignore
    echo "# Claude Code" >> .gitignore
    echo ".claude/sessions/" >> .gitignore
    echo ".claude/logs/" >> .gitignore
    print_success ".gitignore を更新しました"
else
    print_success ".gitignore は既に .claude/ を含みます"
fi

# =====================================================
# 6. 確認と次ステップ
# =====================================================

echo ""
print_header "セットアップ完了！"
echo ""
echo "✅ 作成されたファイル:"
echo "   - .github/workflows/build-apk.yml"
echo "   - .claude/hooks/session-start.sh"
echo "   - .claude/settings.json"
echo ""
echo "📝 次のステップ:"
echo ""
echo "1. ファイルをレビュー・カスタマイズ:"
echo "   - .github/workflows/build-apk.yml - トリガー条件を確認"
echo "   - .claude/settings.json - プロジェクト名を確認"
echo ""
echo "2. 変更をコミット・プッシュ:"
echo "   git add .github/workflows/ .claude/"
echo "   git commit -m 'ci: Add standard build workflow and Claude setup'"
echo "   git push origin <branch-name>"
echo ""
echo "3. 新規セッションを起動:"
echo "   Claude Code セッションを起動すると、SessionStart Hook が自動実行されます"
echo ""
echo "4. エミュレータテストを実行:"
echo "   /build-and-test $PROJECT_NAME"
echo ""
print_success "セットアップ完了しました！"
