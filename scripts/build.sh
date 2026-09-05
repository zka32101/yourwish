#!/bin/bash

# Unified Build Script - ローカル環境不要でビルド完結
#
# 使用例:
#   ./scripts/build.sh flutter      # Flutterアプリ全体
#   ./scripts/build.sh flutter:vote_survivor  # 特定アプリ
#   ./scripts/build.sh flutter:android        # Android APK生成
#   ./scripts/build.sh flutter:aab            # Android App Bundle生成
#   ./scripts/build.sh flutter:ios            # iOS IPA生成
#   ./scripts/build.sh flutter:web            # Web版ビルド
#   ./scripts/build.sh packages               # 全パッケージ
#   ./scripts/build.sh analyze                # 静的解析のみ
#   ./scripts/build.sh test                   # テストのみ

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_CACHE_DIR="${PROJECT_ROOT}/.build-cache"
BUILD_LOG="${BUILD_CACHE_DIR}/build.log"

# デフォルト設定
TARGET="${1:-flutter}"
BUILD_MODE="${BUILD_MODE:-release}"
USE_DOCKER="${USE_DOCKER:-true}"
DOCKER_IMAGE="${DOCKER_IMAGE:-node:20-alpine}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.x}"
DART_VERSION="${DART_VERSION:-3.12.0}"

# ヘルパー関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_usage() {
    cat << EOF
${BLUE}=== Unified Build Script ===${NC}

使用方法:
  $0 <target> [options]

ターゲット:
  ${YELLOW}flutter${NC}                # Flutterアプリ全体 (analyze + test)
  ${YELLOW}flutter:android${NC}        # Android APK ビルド
  ${YELLOW}flutter:aab${NC}            # Android App Bundle ビルド
  ${YELLOW}flutter:ios${NC}            # iOS ビルド (Xcode 必須)
  ${YELLOW}flutter:web${NC}            # Web ビルド
  ${YELLOW}flutter:<app-name>${NC}     # 特定アプリのビルド
  ${YELLOW}packages${NC}               # 全パッケージのテスト
  ${YELLOW}analyze${NC}                # 静的解析のみ
  ${YELLOW}test${NC}                   # テストのみ
  ${YELLOW}clean${NC}                  # キャッシュクリア

オプション:
  BUILD_MODE=debug              # ビルドモード (debug/release)
  USE_DOCKER=false              # Dockerを使わない
  FLUTTER_VERSION=<version>     # Flutterバージョン

環境変数:
  PROJECT_ROOT                  プロジェクトルート
  BUILD_CACHE_DIR              ビルドキャッシュディレクトリ

例:
  # Flutterアプリ全体のテスト
  $0 flutter

  # 特定アプリのAndroidビルド (APK)
  $0 flutter:android:vote_survivor BUILD_MODE=release

  # 特定アプリのAndroidビルド (AAB)
  $0 flutter:aab:vote_survivor BUILD_MODE=release

  # パッケージのみテスト
  $0 packages

EOF
    exit 1
}

# キャッシュディレクトリ作成
setup_cache() {
    mkdir -p "$BUILD_CACHE_DIR"
    touch "$BUILD_LOG"
}

# Dockerが使用可能か確認
check_docker() {
    if [ "$USE_DOCKER" = "true" ]; then
        if ! command -v docker &> /dev/null; then
            log_warn "Docker が見つかりません。ローカル環境を使用します"
            USE_DOCKER=false
            return 1
        fi
        if ! docker ps &>/dev/null; then
            log_warn "Docker デーモンが起動していません。ローカル環境を使用します"
            USE_DOCKER=false
            return 1
        fi
        log_success "Docker 利用可能"
        return 0
    fi
}

# Flutter環境チェック
check_flutter() {
    if [ "$USE_DOCKER" = "true" ]; then
        # Docker内でチェック
        docker run --rm -v "$PROJECT_ROOT:/workspace" \
            cirrusci/flutter:$FLUTTER_VERSION \
            flutter --version 2>&1 | head -1
    else
        if ! command -v flutter &> /dev/null; then
            log_error "Flutter がインストールされていません"
            log_info "以下でインストール: https://flutter.dev/docs/get-started/install"
            exit 1
        fi
        flutter --version | head -1
    fi
}

# Dart環境チェック
check_dart() {
    if [ "$USE_DOCKER" = "true" ]; then
        docker run --rm google/dart:$DART_VERSION dart --version 2>&1
    else
        if ! command -v dart &> /dev/null; then
            log_error "Dart がインストールされていません"
            exit 1
        fi
        dart --version
    fi
}

# Flutter analyze
run_flutter_analyze() {
    local app_path="${1:-.}"
    log_info "Flutter analyze を実行中: $app_path"

    if [ "$USE_DOCKER" = "true" ]; then
        docker run --rm -v "$PROJECT_ROOT:/workspace" \
            -w "/workspace/$app_path" \
            cirrusci/flutter:$FLUTTER_VERSION \
            sh -c "flutter pub get && flutter analyze --no-fatal-infos --no-fatal-warnings"
    else
        cd "$app_path"
        flutter pub get
        flutter analyze --no-fatal-infos --no-fatal-warnings
        cd - > /dev/null
    fi

    log_success "Analyze 完了: $app_path"
}

# Flutter test
run_flutter_test() {
    local app_path="${1:-.}"
    log_info "Flutter テストを実行中: $app_path"

    if [ "$USE_DOCKER" = "true" ]; then
        docker run --rm -v "$PROJECT_ROOT:/workspace" \
            -w "/workspace/$app_path" \
            cirrusci/flutter:$FLUTTER_VERSION \
            sh -c "flutter pub get && flutter test"
    else
        cd "$app_path"
        flutter pub get
        flutter test
        cd - > /dev/null
    fi

    log_success "テスト 完了: $app_path"
}

# Android ビルド
run_flutter_android() {
    local app_name="${1:-vote_survivor}"
    local app_path="$PROJECT_ROOT/apps/$app_name"

    if [ ! -d "$app_path" ]; then
        log_error "アプリが見つかりません: $app_path"
        exit 1
    fi

    log_info "Android APK ビルド: $app_name ($BUILD_MODE)"

    if [ "$USE_DOCKER" = "true" ]; then
        docker run --rm -v "$PROJECT_ROOT:/workspace" \
            -w "/workspace/$app_path" \
            cirrusci/flutter:$FLUTTER_VERSION \
            sh -c "flutter pub get && flutter build apk --$BUILD_MODE"
    else
        cd "$app_path"
        flutter pub get
        flutter build apk --$BUILD_MODE
        cd - > /dev/null
    fi

    log_success "Android APK ビルド 完了: $app_name"
    if [ "$USE_DOCKER" = "true" ]; then
        echo ""
        log_info "出力: $app_path/build/app/outputs/apk/$BUILD_MODE/*.apk"
    fi
}

# Android App Bundle ビルド
run_flutter_aab() {
    local app_name="${1:-vote_survivor}"
    local app_path="$PROJECT_ROOT/apps/$app_name"

    if [ ! -d "$app_path" ]; then
        log_error "アプリが見つかりません: $app_path"
        exit 1
    fi

    log_info "Android App Bundle ビルド: $app_name ($BUILD_MODE)"

    if [ "$USE_DOCKER" = "true" ]; then
        docker run --rm -v "$PROJECT_ROOT:/workspace" \
            -w "/workspace/$app_path" \
            cirrusci/flutter:$FLUTTER_VERSION \
            sh -c "flutter pub get && flutter build appbundle --$BUILD_MODE"
    else
        cd "$app_path"
        flutter pub get
        flutter build appbundle --$BUILD_MODE
        cd - > /dev/null
    fi

    log_success "Android App Bundle ビルド 完了: $app_name"
    if [ "$USE_DOCKER" = "true" ]; then
        echo ""
        log_info "出力: $app_path/build/app/outputs/bundle/$BUILD_MODE/*.aab"
    fi
}

# iOS ビルド
run_flutter_ios() {
    local app_name="${1:-vote_survivor}"
    local app_path="$PROJECT_ROOT/apps/$app_name"

    if [ ! -d "$app_path" ]; then
        log_error "アプリが見つかりません: $app_path"
        exit 1
    fi

    if [ "$USE_DOCKER" = "true" ]; then
        log_error "iOS ビルドは macOS のみサポートです (Docker内では実行不可)"
        exit 1
    fi

    log_info "iOS ビルド: $app_name ($BUILD_MODE)"
    log_warn "注意: macOS with Xcode が必須です"

    cd "$app_path"
    flutter pub get
    flutter build ios --$BUILD_MODE
    cd - > /dev/null

    log_success "iOS ビルド 完了: $app_name"
}

# Web ビルド
run_flutter_web() {
    local app_name="${1:-vote_survivor}"
    local app_path="$PROJECT_ROOT/apps/$app_name"

    if [ ! -d "$app_path" ]; then
        log_error "アプリが見つかりません: $app_path"
        exit 1
    fi

    log_info "Web ビルド: $app_name"

    if [ "$USE_DOCKER" = "true" ]; then
        docker run --rm -v "$PROJECT_ROOT:/workspace" \
            -w "/workspace/$app_path" \
            cirrusci/flutter:$FLUTTER_VERSION \
            sh -c "flutter pub get && flutter build web"
    else
        cd "$app_path"
        flutter pub get
        flutter build web
        cd - > /dev/null
    fi

    log_success "Web ビルド 完了: $app_name"
    if [ "$USE_DOCKER" = "true" ]; then
        echo ""
        log_info "出力: $app_path/build/web/"
    fi
}

# パッケージテスト
run_packages_test() {
    log_info "全パッケージをテスト中"

    for package in "$PROJECT_ROOT/packages"/*; do
        if [ -f "$package/pubspec.yaml" ]; then
            local pkg_name=$(basename "$package")
            log_info "テスト: $pkg_name"

            if [ "$USE_DOCKER" = "true" ]; then
                docker run --rm -v "$PROJECT_ROOT:/workspace" \
                    -w "/workspace/packages/$pkg_name" \
                    google/dart:$DART_VERSION \
                    sh -c "pub get && pub run test"
            else
                cd "$package"
                pub get
                pub run test
                cd - > /dev/null
            fi
        fi
    done

    log_success "パッケージテスト 完了"
}

# クリーンアップ
run_clean() {
    log_info "キャッシュをクリア中..."

    rm -rf "$BUILD_CACHE_DIR"
    find "$PROJECT_ROOT" -name ".dart_tool" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$PROJECT_ROOT" -name "build" -type d -exec rm -rf {} + 2>/dev/null || true

    log_success "クリーンアップ 完了"
}

# メイン処理
main() {
    case "$TARGET" in
        flutter)
            setup_cache
            check_docker
            log_info "Flutter プロジェクト全体のビルド"
            run_flutter_analyze "apps/vote_survivor"
            run_flutter_test "apps/vote_survivor"
            log_success "全ビルド 完了"
            ;;
        flutter:android)
            setup_cache
            check_docker
            run_flutter_android "${2:-vote_survivor}"
            ;;
        flutter:android:*)
            setup_cache
            check_docker
            app_name="${TARGET#flutter:android:}"
            run_flutter_android "$app_name"
            ;;
        flutter:aab)
            setup_cache
            check_docker
            run_flutter_aab "${2:-vote_survivor}"
            ;;
        flutter:aab:*)
            setup_cache
            check_docker
            app_name="${TARGET#flutter:aab:}"
            run_flutter_aab "$app_name"
            ;;
        flutter:ios)
            run_flutter_ios "${2:-vote_survivor}"
            ;;
        flutter:ios:*)
            app_name="${TARGET#flutter:ios:}"
            run_flutter_ios "$app_name"
            ;;
        flutter:web)
            setup_cache
            check_docker
            run_flutter_web "${2:-vote_survivor}"
            ;;
        flutter:web:*)
            setup_cache
            check_docker
            app_name="${TARGET#flutter:web:}"
            run_flutter_web "$app_name"
            ;;
        flutter:*)
            setup_cache
            check_docker
            app_name="${TARGET#flutter:}"
            log_info "アプリをビルド: $app_name"
            run_flutter_analyze "apps/$app_name"
            run_flutter_test "apps/$app_name"
            ;;
        packages)
            setup_cache
            check_docker
            run_packages_test
            ;;
        analyze)
            setup_cache
            check_docker
            run_flutter_analyze "apps/vote_survivor"
            ;;
        test)
            setup_cache
            check_docker
            run_flutter_test "apps/vote_survivor"
            ;;
        clean)
            run_clean
            ;;
        *)
            log_error "不正なターゲット: $TARGET"
            print_usage
            ;;
    esac
}

# 引数チェック
if [ -z "$TARGET" ] || [ "$TARGET" = "-h" ] || [ "$TARGET" = "--help" ]; then
    print_usage
fi

main
