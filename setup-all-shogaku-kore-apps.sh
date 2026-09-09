#!/bin/bash
# 小学コレシリーズ全7つ対応の統一セットアップスクリプト
# 新規セッション用：改修→エミュレータテスト一気通貫環境構築

set -e

echo "=================================================="
echo "🎓 小学コレシリーズ 統一セットアップスクリプト"
echo "=================================================="
echo ""

# 1. 環境確認
echo "📋 環境確認..."
echo "   セッション: $(whoami)@$(hostname)"
echo "   ディレクトリ: $(pwd)"
echo ""

# 2. アプリ一覧定義
declare -a APPS=(
  "kokugo-kore:国語"
  "sansu-kore:算数"
  "chikaba_kore:社会"
  "seiza_kore:理科"
  "shogaku-kore-programming:プログラミング"
)

declare -a APPS_IN_YOURWISH=(
  "shoukoku_eigo:英語"
  "shoukoku_shinshin:心身"
)

echo "🎯 対象アプリ（独立リポジトリ）:"
for app_info in "${APPS[@]}"; do
  IFS=':' read -r app_name app_label <<< "$app_info"
  echo "   ✓ $app_label ($app_name)"
done
echo ""
echo "🎯 対象アプリ（yourwish/apps/ 配下）:"
for app_info in "${APPS_IN_YOURWISH[@]}"; do
  IFS=':' read -r app_name app_label <<< "$app_info"
  echo "   ✓ $app_label ($app_name)"
done
echo ""

# 3. ネットワーク確認
echo "🌐 ネットワーク接続確認..."
if [ -n "$HTTPS_PROXY" ]; then
  echo "⚠️  プロキシ検出: $HTTPS_PROXY"
  echo "💡 ヒント: 新規セッション起動時に 'allow-outbound-https' ポリシーを選択してください"
  echo ""
fi

# 4. ビルド依存関係確認
echo "🔍 ビルド環境確認..."
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter がインストールされていません"
  echo "   Docker で実行する場合:"
  echo "   docker-compose up -d claude"
  echo "   docker-compose exec claude bash"
  exit 1
fi

if ! command -v adb &> /dev/null; then
  echo "⚠️  adb (Android Debug Bridge) がインストールされていません"
  echo "   エミュレータテストには必要です"
  echo ""
fi

echo "✅ Flutter: $(flutter --version | head -1)"
echo "✅ Dart: $(dart --version)"
echo ""

# 5. セットアップ内容を表示
echo "📦 セットアップ内容:"
echo ""
echo "【各アプリに追加】"
echo "  1. .claude/skills/build-and-test/ - エミュレータテスト自動化"
echo "  2. .claude/environments/network-enabled.md - ネットワーク設定ガイド"
echo "  3. docker-compose.network-enabled.yml - Docker ネットワーク設定"
echo "  4. .claude/settings.json - 自動テスト実行設定"
echo "  5. .claude/hooks/on-build-complete.sh - ビルド後フック"
echo ""

echo "【ワークフロー統合】"
echo "  1. 改修（git commit/push）"
echo "  2. ビルド（flutter build apk）"
echo "  3. 自動テスト実行（build-and-test スキル）"
echo ""

# 6. セットアップ実行確認
read -p "セットアップを開始しますか？ (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "🚫 セットアップをキャンセルしました"
  exit 1
fi

# 7. 各アプリのセットアップ
echo ""
echo "🔧 セットアップ開始..."
echo ""

setup_app() {
  local repo_name=$1
  local app_label=$2
  local repo_path=$3

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📱 $app_label ($repo_name) をセットアップ中..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # ディレクトリ確認
  if [ ! -d "$repo_path" ]; then
    echo "❌ $repo_path が見つかりません"
    return 1
  fi

  cd "$repo_path"

  # git 設定
  git config user.email "zkaz83@gmail.com" 2>/dev/null || true
  git config user.name "Claude Haiku 4.5" 2>/dev/null || true

  # .claude ディレクトリ作成
  mkdir -p .claude/skills/build-and-test
  mkdir -p .claude/environments
  mkdir -p .claude/hooks
  mkdir -p scripts

  # 最新の build-and-test スキルをコピー
  if [ -f "../../yourwish/.claude/skills/build-and-test/SKILL.md" ]; then
    cp ../../yourwish/.claude/skills/build-and-test/SKILL.md .claude/skills/build-and-test/
    cp ../../yourwish/.claude/skills/build-and-test/run.sh .claude/skills/build-and-test/
    chmod +x .claude/skills/build-and-test/run.sh
    echo "✅ build-and-test スキルをコピー"
  fi

  # ネットワーク設定をコピー
  if [ -f "../../yourwish/.claude/environments/network-enabled.md" ]; then
    cp ../../yourwish/.claude/environments/network-enabled.md .claude/environments/
    echo "✅ ネットワーク設定をコピー"
  fi

  if [ -f "../../yourwish/docker-compose.network-enabled.yml" ]; then
    cp ../../yourwish/docker-compose.network-enabled.yml .
    echo "✅ Docker ネットワーク設定をコピー"
  fi

  # スクリプトをコピー
  if [ -f "../../yourwish/scripts/setup-network-enabled-session.sh" ]; then
    cp ../../yourwish/scripts/setup-network-enabled-session.sh scripts/
    chmod +x scripts/setup-network-enabled-session.sh
    echo "✅ ネットワーク有効化スクリプトをコピー"
  fi

  # settings.json を作成
  python3 << PYTHON_EOF
import json
settings = {
  "name": "$repo_name",
  "description": "$app_label - テスト自動化環境",
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Read", "Write", "Edit", "Bash", "Glob", "Grep", "Artifact", "Agent", "Workflow",
      "SendMessage", "mcp__Claude_Code_Remote__*", "mcp__github__*", "*"
    ]
  },
  "hooks": {
    "on_build_complete": {
      "description": "ビルド完了後の自動テスト実行",
      "script": ".claude/hooks/on-build-complete.sh",
      "trigger": "post-build"
    }
  },
  "recommendations": {
    "skills": [
      {
        "name": "build-and-test",
        "description": "エミュレータテスト自動化（6つのテスト観点）",
        "location": ".claude/skills/build-and-test/SKILL.md"
      }
    ]
  }
}
with open('.claude/settings.json', 'w') as f:
  json.dump(settings, f, indent=2, ensure_ascii=False)
print("✅ settings.json を作成")
PYTHON_EOF

  # フックをコピー
  if [ -f "../../yourwish/.claude/hooks/on-build-complete.sh" ]; then
    cp ../../yourwish/.claude/hooks/on-build-complete.sh .claude/hooks/
    chmod +x .claude/hooks/on-build-complete.sh
    echo "✅ on-build-complete フックをコピー"
  fi

  echo "✅ $app_label セットアップ完了"
  echo ""

  cd - > /dev/null
}

# 独立リポジトリのセットアップ
for app_info in "${APPS[@]}"; do
  IFS=':' read -r app_name app_label <<< "$app_info"
  setup_app "$app_name" "$app_label" "/home/user/$app_name"
done

# yourwish 配下のアプリのセットアップ
for app_info in "${APPS_IN_YOURWISH[@]}"; do
  IFS=':' read -r app_name app_label <<< "$app_info"
  setup_app "$app_name" "$app_label" "/home/user/yourwish/apps/$app_name"
done

# 8. 完了メッセージ
echo ""
echo "=================================================="
echo "✅ セットアップ完了！"
echo "=================================================="
echo ""
echo "📝 次のステップ："
echo ""
echo "1️⃣  改修作業を実施"
echo "   cd <app_directory>"
echo "   # コードを修正"
echo "   git add -A"
echo "   git commit -m '改修内容'"
echo "   git push origin <branch>"
echo ""
echo "2️⃣  ビルド実行"
echo "   flutter pub get"
echo "   flutter build apk --release"
echo ""
echo "3️⃣  自動テスト実行（on-build-complete フックが自動実行）"
echo "   /build-and-test <app_name>"
echo ""
echo "📚 詳細ガイド："
echo "   - ネットワーク設定: .claude/environments/network-enabled.md"
echo "   - テストスキル: .claude/skills/build-and-test/SKILL.md"
echo ""
echo "🔗 一括テスト実行："
echo "   ./run-all-shogaku-kore-tests.sh"
echo ""
