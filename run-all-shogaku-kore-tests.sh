#!/bin/bash
# 小学コレシリーズ全7つの一括ビルド・テスト実行スクリプト
# 改修→ビルド→エミュレータテスト一気通貫

set -e

echo "=================================================="
echo "🎓 小学コレシリーズ 一括ビルド・テストスクリプト"
echo "=================================================="
echo ""

# アプリ定義
declare -a APPS=(
  "kokugo-kore:/home/user/kokugo-kore:国語"
  "sansu-kore:/home/user/sansu-kore:算数"
  "chikaba_kore:/home/user/chikaba_kore:社会"
  "seiza_kore:/home/user/seiza_kore:理科"
  "shogaku-kore-programming:/home/user/shogaku-kore-programming:プログラミング"
  "shoukoku_eigo:/home/user/yourwish/apps/shoukoku_eigo:英語"
  "shoukoku_shinshin:/home/user/yourwish/apps/shoukoku_shinshin:心身"
)

# テスト結果追跡
declare -A TEST_RESULTS
declare -a APP_NAMES

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# 1. 実行モード確認
echo "🔧 実行モード："
echo "  1. ビルド + テスト（推奨）"
echo "  2. テストのみ（既にビルド済み）"
echo "  3. 特定アプリのみ"
echo ""
read -p "モードを選択 (1-3) [1]: " -r mode
mode=${mode:-1}

echo ""

case $mode in
  1)
    BUILD_MODE="build_and_test"
    echo "✅ ビルド + テストモード"
    ;;
  2)
    BUILD_MODE="test_only"
    echo "✅ テストオンリーモード"
    ;;
  3)
    BUILD_MODE="custom"
    echo "特定アプリをカンマ区切りで入力 (例: kokugo-kore,sansu-kore):"
    read -r CUSTOM_APPS
    echo ""
    ;;
  *)
    echo "❌ 無効な選択"
    exit 1
    ;;
esac

# 2. ネットワーク確認
echo ""
echo "🌐 ネットワーク接続確認..."
if ! curl -s -m 3 https://pub.dev > /dev/null 2>&1; then
  echo "⚠️  pub.dev への接続確認できません"
  echo "    ネットワーク有効化環境の使用を推奨します"
  echo ""
fi

# 3. ビルド実行
if [ "$BUILD_MODE" = "build_and_test" ] || [ "$BUILD_MODE" = "build_only" ]; then
  echo ""
  echo "📦 ビルド実行中..."
  echo ""

  for app_info in "${APPS[@]}"; do
    IFS=':' read -r app_name app_path app_label <<< "$app_info"

    if [ "$BUILD_MODE" = "custom" ]; then
      if [[ ! "$CUSTOM_APPS" =~ "$app_name" ]]; then
        continue
      fi
    fi

    APP_NAMES+=("$app_name")

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📱 $app_label ($app_name) をビルド中...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ ! -d "$app_path" ]; then
      echo -e "${RED}❌ ディレクトリが見つかりません: $app_path${NC}"
      TEST_RESULTS["$app_name"]="SKIP_NOT_FOUND"
      continue
    fi

    cd "$app_path"

    # pubspec.lock 削除（キャッシュクリア）
    rm -f pubspec.lock

    # ビルド実行
    if flutter pub get && flutter build apk --release 2>&1 | tail -20; then
      echo -e "${GREEN}✅ $app_label ビルド成功${NC}"
      TEST_RESULTS["$app_name"]="BUILD_SUCCESS"
    else
      echo -e "${RED}❌ $app_label ビルド失敗${NC}"
      TEST_RESULTS["$app_name"]="BUILD_FAILED"
      continue
    fi

    cd - > /dev/null
    echo ""
  done
fi

# 4. テスト実行
if [ "$BUILD_MODE" = "build_and_test" ] || [ "$BUILD_MODE" = "test_only" ]; then
  echo ""
  echo "🧪 エミュレータテスト実行中..."
  echo ""

  for app_name in "${APP_NAMES[@]}"; do
    # カスタムモードでフィルタリング
    if [ "$BUILD_MODE" = "custom" ]; then
      if [[ ! "$CUSTOM_APPS" =~ "$app_name" ]]; then
        continue
      fi
    fi

    # ビルド失敗したアプリはスキップ
    if [ "$BUILD_MODE" = "build_and_test" ]; then
      if [ "${TEST_RESULTS[$app_name]}" = "BUILD_FAILED" ]; then
        continue
      fi
    fi

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🧪 $app_name をテスト中...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # テスト実行
    if /build-and-test "$app_name" 2>&1; then
      TEST_RESULTS["$app_name"]="TEST_SUCCESS"
      echo -e "${GREEN}✅ $app_name テスト成功${NC}"
    else
      TEST_RESULTS["$app_name"]="TEST_FAILED"
      echo -e "${YELLOW}⚠️  $app_name テスト完了（詳細を確認）${NC}"
    fi

    echo ""
  done
fi

# 5. 結果レポート
echo ""
echo "=================================================="
echo "📋 テスト結果レポート"
echo "=================================================="
echo ""

BUILD_COUNT=0
TEST_COUNT=0
SUCCESS_COUNT=0
FAIL_COUNT=0

for app_name in "${!TEST_RESULTS[@]}"; do
  result="${TEST_RESULTS[$app_name]}"

  case $result in
    BUILD_SUCCESS|TEST_SUCCESS)
      echo -e "${GREEN}✅${NC} $app_name: $result"
      SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
      ;;
    BUILD_FAILED|TEST_FAILED)
      echo -e "${RED}❌${NC} $app_name: $result"
      FAIL_COUNT=$((FAIL_COUNT + 1))
      ;;
    SKIP_NOT_FOUND)
      echo -e "${YELLOW}⊘${NC} $app_name: スキップ（ディレクトリなし）"
      ;;
  esac
done

echo ""
echo "📊 サマリー:"
echo "  成功: $SUCCESS_COUNT"
echo "  失敗: $FAIL_COUNT"
echo ""

# 6. 完了メッセージ
if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}✅ すべてのテストが成功しました！${NC}"
  exit 0
else
  echo -e "${RED}❌ $FAIL_COUNT 個のテストが失敗しました${NC}"
  exit 1
fi
