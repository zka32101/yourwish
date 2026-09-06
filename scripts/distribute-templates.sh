#!/bin/bash

# テンプレート配布スクリプト
# 用途：Android emulator テストテンプレートを 9つのアプリセッションに自動配布
#
# 対象アプリ（9個）：
#  - 新規4個：eigo, shinshin, social_quiz_app, newrepo
#  - 既存5個：kokugo-kore, shogaku-kore-programming, sansu-kore, chikaba_kore, seiza_kore

set -e

# 対象リポジトリ
REPOS=(
  "eigo"
  "shinshin"
  "social_quiz_app"
  "newrepo"
  "kokugo-kore"
  "shogaku-kore-programming"
  "sansu-kore"
  "chikaba_kore"
  "seiza_kore"
)

# ディレクトリ確認
if [ ! -d ".github/workflows" ]; then
  echo "❌ This script must be run from the project root"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "📦 Android Emulator Template Distribution"
echo "Target repositories: ${#REPOS[@]}"
echo ""

# 一時ディレクトリ作成
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "📂 Preparing templates..."

# テンプレートをコピー
cp "$PROJECT_ROOT/.github/workflows/android-emulator-test.yml" "$TEMP_DIR/"
cp "$PROJECT_ROOT/scripts/setup-android-emulator.sh" "$TEMP_DIR/"

# 配布処理
SUCCESS_COUNT=0
FAIL_COUNT=0

for repo in "${REPOS[@]}"; do
  echo ""
  echo "📤 Distributing to: zka32101/$repo"

  # クローンディレクトリ
  CLONE_DIR="$TEMP_DIR/$repo"

  # リポジトリ確認
  if ! gh repo view "zka32101/$repo" > /dev/null 2>&1; then
    echo "  ❌ Repository not found"
    ((FAIL_COUNT++))
    continue
  fi

  # クローン
  if ! git clone "https://github.com/zka32101/$repo.git" "$CLONE_DIR" 2>/dev/null; then
    echo "  ❌ Failed to clone"
    ((FAIL_COUNT++))
    continue
  fi

  cd "$CLONE_DIR"

  # デフォルトブランチ取得
  DEFAULT_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD | sed 's/^origin\///')
  echo "  → Default branch: $DEFAULT_BRANCH"

  # 配布用ブランチ作成
  DIST_BRANCH="claude/android-emulator-setup-$(date +%s)"
  git checkout -b "$DIST_BRANCH" "origin/$DEFAULT_BRANCH" 2>/dev/null || {
    git fetch origin "$DEFAULT_BRANCH"
    git checkout -b "$DIST_BRANCH" "origin/$DEFAULT_BRANCH"
  }

  # テンプレートをコピー
  mkdir -p .github/workflows
  mkdir -p scripts

  cp "$TEMP_DIR/android-emulator-test.yml" ".github/workflows/"
  cp "$TEMP_DIR/setup-android-emulator.sh" "scripts/"

  # パーミッション設定
  chmod +x "scripts/setup-android-emulator.sh"

  # Git に追加
  git add ".github/workflows/android-emulator-test.yml"
  git add "scripts/setup-android-emulator.sh"

  # ステータス確認
  if git diff --cached --quiet; then
    echo "  ℹ️  No changes (templates already exist)"
    cd "$PROJECT_ROOT"
    ((SUCCESS_COUNT++))
    continue
  fi

  # Commit
  git config user.name "Claude Code Bot"
  git config user.email "noreply@anthropic.com"

  git commit -m "chore: add Android emulator test templates

- Add android-emulator-test.yml workflow
- Add setup-android-emulator.sh script
- Enable independent emulator testing per app

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>" || {
    echo "  ❌ Failed to commit"
    cd "$PROJECT_ROOT"
    ((FAIL_COUNT++))
    continue
  }

  # Push
  if git push -u origin "$DIST_BRANCH" 2>/dev/null; then
    echo "  ✅ Pushed to: $DIST_BRANCH"

    # PR 作成
    if gh pr create \
      --repo "zka32101/$repo" \
      --base "$DEFAULT_BRANCH" \
      --head "$DIST_BRANCH" \
      --title "Add Android emulator test support" \
      --body "✅ Add Android emulator testing templates

## Changes
- Added \`.github/workflows/android-emulator-test.yml\` - Callable workflow for running emulator tests
- Added \`scripts/setup-android-emulator.sh\` - Setup script for Android AVD initialization

## Benefits
- Independent emulator testing per app session
- Parallel test execution across 9 app repositories
- Automatic SDK/AVD initialization
- Integrated with CI/CD pipeline

## Testing
1. Run locally: \`bash scripts/setup-android-emulator.sh\`
2. Or via CI: GitHub Actions workflow integration

## Notes
- Each app session maintains its own emulator instance
- CI tests run in isolation with cleanup
- Compatible with existing build pipelines

---
🤖 Generated with [Claude Code](https://claude.ai/code)" \
      --draft 2>/dev/null; then
      echo "  ✅ PR created (draft)"
    else
      echo "  ⚠️  PR already exists or creation failed"
    fi

    ((SUCCESS_COUNT++))
  else
    echo "  ❌ Failed to push"
    ((FAIL_COUNT++))
  fi

  cd "$PROJECT_ROOT"
done

echo ""
echo "========================================="
echo "📊 Distribution Summary"
echo "========================================="
echo "✅ Successful: $SUCCESS_COUNT"
echo "❌ Failed: $FAIL_COUNT"
echo "Total: $((SUCCESS_COUNT + FAIL_COUNT))"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
  echo "🎉 All templates distributed successfully!"
  echo ""
  echo "📌 Next steps:"
  echo "1. Review PRs at:"
  for repo in "${REPOS[@]}"; do
    echo "   https://github.com/zka32101/$repo/pulls"
  done
  echo ""
  echo "2. Merge PRs to activate emulator testing in CI"
  echo "3. Each app session will run Android tests independently"
else
  echo "⚠️  Some distributions failed. Review above."
fi
