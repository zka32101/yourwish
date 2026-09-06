#!/bin/bash

# 新規アプリセッション作成スクリプト
# 用途：新規 Flutter アプリ用に Claude Code セッションを作成・初期化
#
# 使用方法：
#   bash scripts/create-app-session.sh <app_name> [parent_session_id]

set -e

# 引数確認
if [ $# -lt 1 ]; then
  echo "❌ Usage: $0 <app_name> [parent_session_id]"
  echo ""
  echo "Examples:"
  echo "  bash scripts/create-app-session.sh eigo"
  echo "  bash scripts/create-app-session.sh social_quiz_app abc123def456"
  exit 1
fi

APP_NAME="$1"
PARENT_SESSION="${2:-}"

echo "📱 Creating Claude Code session for: $APP_NAME"
echo ""

# GitHub リポジトリ確認
GITHUB_REPO="zka32101/$APP_NAME"
echo "🔍 Verifying repository: $GITHUB_REPO"

# gh CLI で リポジトリ確認
if ! gh repo view "$GITHUB_REPO" > /dev/null 2>&1; then
  echo "❌ Repository not found: $GITHUB_REPO"
  exit 1
fi

echo "✅ Repository verified"
echo ""

# セッション環境情報
ENVIRONMENT_TYPE="${ENVIRONMENT_TYPE:-remote}"
NETWORK_POLICY="${NETWORK_POLICY:-public}"

# セッション作成コマンド（MCP を使用）
echo "🚀 Creating session..."
echo ""
echo "📌 Session Configuration:"
echo "  Repository: $GITHUB_REPO"
echo "  Environment: $ENVIRONMENT_TYPE"
echo "  Network: $NETWORK_POLICY"
echo ""

# MCP で セッション作成（手動実行時の参考情報）
SESSION_ID_FILE="/tmp/${APP_NAME}_session_id.txt"

cat > "$SESSION_ID_FILE" << 'INSTRUCTIONS'
🔧 Manual Session Creation Instructions:

1. Clone the repository:
   git clone https://github.com/YOUR_GITHUB_REPO.git
   cd YOUR_APP_NAME

2. Verify directory structure:
   - apps/YOUR_APP_NAME/ (main app)
   - packages/game_kit/ (shared)
   - .github/workflows/ (CI/CD)

3. Run environment setup:
   bash scripts/setup-android-emulator.sh

4. Verify configuration:
   - .claude/hooks/session-start.sh (exists)
   - GOOGLE_DRIVE_FOLDER_ID secret (registered)
   - GOOGLE_DRIVE_SERVICE_ACCOUNT secret (registered)

5. Build & Test:
   flutter pub get
   flutter build apk --release
   flutter test (with emulator running)

6. Automatic workflows:
   - CI triggers on push: github-actions-build.yml
   - Upload to Google Drive: google-drive-upload.yml
   - Android Emulator test: android-emulator-test.yml
INSTRUCTIONS

echo "📋 Session initialization checklist created:"
cat "$SESSION_ID_FILE"
echo ""

# 必須テンプレートファイルのコピー（既存セッションへの準備）
echo "📦 Preparing templates for distribution..."

# チェックリスト生成
cat > "/tmp/${APP_NAME}_setup_checklist.txt" << EOF
✅ Setup Checklist for: $APP_NAME

Environment Setup:
☐ Android SDK installed (ANDROID_HOME set)
☐ Flutter SDK installed (stable channel)
☐ Java 17+ installed

Repository Configuration:
☐ Repository cloned: ~/yourwish-sessions/$APP_NAME
☐ .flutter-settings configured
☐ pubspec.lock exists

GitHub Secrets (verify at https://github.com/$GITHUB_REPO/settings/secrets/actions):
☐ GOOGLE_DRIVE_FOLDER_ID = 1iXxOO750AyuIwXNwGF-qTJLmElIldgwD
☐ GOOGLE_DRIVE_SERVICE_ACCOUNT = (JSON content)

CI/CD Workflows:
☐ .github/workflows/google-drive-upload.yml (callable)
☐ .github/workflows/android-emulator-test.yml (callable)
☐ Main build workflow includes emulator test

Local Testing:
☐ Android AVD created: $APP_NAME
☐ flutter pub get (completed)
☐ flutter build apk --release (tested)
☐ flutter test (with emulator)

First Run:
1. cd ~/yourwish-sessions/$APP_NAME
2. bash scripts/setup-android-emulator.sh
3. emulator -avd $APP_NAME -no-audio -no-boot-anim &
4. flutter test
5. git push origin main (triggers CI)
6. Monitor: https://github.com/$GITHUB_REPO/actions

Notes:
- Each session runs independently
- Emulator test results uploaded as artifacts
- APK/AAB auto-uploaded to Google Drive on successful build
- Use orchestrator session for monitoring all builds
EOF

echo "✅ Checklist saved: /tmp/${APP_NAME}_setup_checklist.txt"
echo ""

# 最後に、distribution スクリプトの実行指示
echo "📤 Next Steps for Distribution:"
echo ""
echo "1️⃣  To distribute these templates to all 9 app sessions:"
echo "   bash scripts/distribute-templates.sh"
echo ""
echo "2️⃣  Or manually for each app:"
echo "   - Copy .github/workflows/android-emulator-test.yml"
echo "   - Copy scripts/setup-android-emulator.sh"
echo "   - Verify .claude/hooks/session-start.sh"
echo "   - Push to app repository"
echo ""
echo "3️⃣  Verify in each session:"
echo "   cat /tmp/${APP_NAME}_setup_checklist.txt"
echo ""
