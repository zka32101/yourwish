#!/bin/bash
# =============================================================================
# Monitoring Agent - Auto Resolution
# 検出された問題の自動解決スクリプト
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../" && pwd)"
MONITORING_DIR="${REPO_ROOT}/.claude/monitoring"
RESOLUTION_LOG="${MONITORING_DIR}/logs/auto-resolution.log"

mkdir -p "$(dirname "$RESOLUTION_LOG")"

# ==================== ロギング ====================
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" | tee -a "$RESOLUTION_LOG"
}

log_action() {
    echo "  ✓ $*" | tee -a "$RESOLUTION_LOG"
}

log_error() {
    echo "  ✗ $*" | tee -a "$RESOLUTION_LOG"
}

# ==================== 自動解決関数 ====================

# 1. スクリプト権限修正
resolve_script_permissions() {
    log "Resolving: Script permission issues"

    if chmod +x "${SCRIPT_DIR}"/*.sh 2>/dev/null; then
        log_action "Fixed script permissions"
        return 0
    else
        log_error "Failed to fix script permissions"
        return 1
    fi
}

# 2. 未コミット変更の警告と回避
resolve_uncommitted_changes() {
    log "Resolving: Uncommitted changes"

    if cd "$REPO_ROOT" 2>/dev/null; then
        local changes=$(git status --porcelain 2>/dev/null | wc -l || echo 0)
        if [[ $changes -gt 0 ]]; then
            log_action "Found $changes uncommitted changes"
            log_action "Recommend: git add . && git commit -m 'monitoring: auto-save state'"
            return 0  # 警告のみ
        fi
    fi

    return 0
}

# 3. Node.js/npm環境確認・インストールガイド
resolve_missing_nodejs() {
    log "Resolving: Missing Node.js"

    if command -v node &>/dev/null; then
        local node_version=$(node --version)
        log_action "Node.js is installed: $node_version"
        return 0
    else
        log_error "Node.js not found"
        log_error "Install from: https://nodejs.org/"
        return 1
    fi
}

# 4. Docker環境ガイド
resolve_docker_not_running() {
    log "Resolving: Docker daemon not running"

    if command -v docker &>/dev/null; then
        if docker info >/dev/null 2>&1; then
            log_action "Docker daemon is running"
            return 0
        else
            log_error "Docker daemon not running"
            if [[ "$OSTYPE" == "darwin"* ]]; then
                log_action "Try: open /Applications/Docker.app"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                log_action "Try: sudo systemctl start docker"
            fi
            return 1
        fi
    else
        log_error "Docker is not installed"
        return 1
    fi
}

# 5. 監視設定の初期化
resolve_monitoring_config() {
    log "Resolving: Monitoring configuration"

    if [[ ! -f "$MONITORING_DIR/config.json" ]]; then
        log_error "config.json is missing"
        return 1
    fi

    # 最終チェック時刻を更新
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    if command -v jq &>/dev/null; then
        jq ".last_check = \"$timestamp\"" "$MONITORING_DIR/config.json" > /tmp/config.tmp && \
            mv /tmp/config.tmp "$MONITORING_DIR/config.json"
        log_action "Updated last_check timestamp"
    fi

    return 0
}

# 6. ディレクトリ構造修正（軽度）
resolve_missing_directories() {
    log "Resolving: Missing directories"

    local dirs_to_check=("apps" "packages" "scripts" "docs")
    for dir in "${dirs_to_check[@]}"; do
        if [[ ! -d "$REPO_ROOT/$dir" ]]; then
            log_action "Missing directory: $dir"
            # 本当に必要な場合のみ作成
            if [[ "$dir" == "docs" ]]; then
                mkdir -p "$REPO_ROOT/$dir"
                log_action "Created: $dir"
            fi
        fi
    done

    return 0
}

# ==================== メイン解決ループ ====================
main() {
    log "═══════════════════════════════════════════════════════════════"
    log "AUTO RESOLUTION STARTED"
    log "═══════════════════════════════════════════════════════════════"

    local total=0
    local fixed=0

    # 解決可能な問題を順序実行
    if resolve_script_permissions; then ((fixed++)); fi
    ((total++))

    if resolve_monitoring_config; then ((fixed++)); fi
    ((total++))

    if resolve_missing_directories; then ((fixed++)); fi
    ((total++))

    # 警告・ガイダンスが必要な問題
    if resolve_uncommitted_changes; then ((fixed++)); fi
    ((total++))

    if resolve_missing_nodejs; then ((fixed++)); fi
    ((total++))

    if resolve_docker_not_running; then ((fixed++)); fi
    ((total++))

    log ""
    log "───────────────────────────────────────────────────────────────"
    log "AUTO RESOLUTION SUMMARY"
    log "  Total issues checked: $total"
    log "  Auto-fixed: $fixed"
    log "  Requires manual action: $((total - fixed))"
    log "───────────────────────────────────────────────────────────────"
}

main "$@"
