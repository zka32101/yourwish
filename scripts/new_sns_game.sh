#!/usr/bin/env bash
# apps/_template_sns_game/ をコピーして、新しいSNS配信用ゲーム環境を
# 作成するスキャフォールドスクリプト。
#
# 使い方:
#   scripts/new_sns_game.sh <ゲーム名(snake_case)> ["説明文"]
#
# 例:
#   scripts/new_sns_game.sh quiz_battle_live "視聴者投票で答えを決めるクイズ配信ゲーム"
#
# 実行すると以下を自動でやる:
#   - apps/_template_sns_game/ を apps/<ゲーム名>/ にコピー
#   - pubspec.yaml の name / description を書き換え
#   - README.md を新しいゲーム用の雛形に差し替え
#   - .github/workflows/<ゲーム名>-ci.yml をテンプレートCIから生成
#
# これらは「たたき台」であり、実装(lib/main.dart)や
# ルートREADMEへの追記は手動で行う必要がある。
set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "使い方: $0 <ゲーム名(snake_case)> [\"説明文\"]" >&2
  exit 1
fi

GAME_NAME="$1"
DESCRIPTION="${2:-SNS配信向けゲーム}"

if ! [[ "$GAME_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "エラー: ゲーム名は snake_case（例: quiz_battle_live）で指定してください" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/apps/_template_sns_game"
TARGET_DIR="$ROOT_DIR/apps/$GAME_NAME"
TEMPLATE_CI="$ROOT_DIR/.github/workflows/_template_sns_game-ci.yml"
TARGET_CI="$ROOT_DIR/.github/workflows/${GAME_NAME}-ci.yml"

if [ -d "$TARGET_DIR" ]; then
  echo "エラー: $TARGET_DIR は既に存在します" >&2
  exit 1
fi

if [ -f "$TARGET_CI" ]; then
  echo "エラー: $TARGET_CI は既に存在します" >&2
  exit 1
fi

echo "==> apps/_template_sns_game を apps/$GAME_NAME にコピーしています"
cp -r "$TEMPLATE_DIR" "$TARGET_DIR"

echo "==> pubspec.yaml を書き換えています"
sed -i.bak \
  -e "s/^name: .*/name: $GAME_NAME/" \
  -e "s/^description: .*/description: \"$DESCRIPTION\"/" \
  "$TARGET_DIR/pubspec.yaml"
rm -f "$TARGET_DIR/pubspec.yaml.bak"

echo "==> README.md を新しいゲーム用に差し替えています"
cat > "$TARGET_DIR/README.md" <<EOF
# $GAME_NAME

$DESCRIPTION

apps/_template_sns_game/ から scripts/new_sns_game.sh で生成した環境です。

## 配信先SNS

- (例: TikTok Live)

## 操作方法

- (配信者操作型 / 視聴者参加型のどちらか、操作方法を記載してください)

## ローカルでの実行

\`\`\`bash
cd apps/$GAME_NAME
flutter pub get
flutter run
\`\`\`

## テスト

\`\`\`bash
cd apps/$GAME_NAME
flutter analyze
flutter test
\`\`\`
EOF

echo "==> CIワークフローを生成しています"
sed \
  -e "s/_template_sns_game/$GAME_NAME/g" \
  "$TEMPLATE_CI" > "$TARGET_CI"

cat <<EOF

作成しました: apps/$GAME_NAME/, .github/workflows/${GAME_NAME}-ci.yml

次にやること:
  1. apps/$GAME_NAME/lib/main.dart を実装する
     （sns_live_game_kit の LiveCommentService / LivesRow / VoteBarList /
       CommentTicker を活用できます）
  2. apps/$GAME_NAME/README.md の配信先SNS・操作方法を埋める
  3. ルート README.md の環境一覧に apps/$GAME_NAME/ を追記する
EOF
