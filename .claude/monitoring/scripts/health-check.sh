#!/bin/bash
# =============================================================================
# Monitoring Agent - Health Check Script
# オーケストレーターと開発環境の健全性を監視
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../" && pwd)"
MONITORING_DIR="${REPO_ROOT}/.claude/monitoring"
REPORT_FILE="${MONITORING_DIR}/reports/latest-check.json"
LOG_FILE="${MONITORING_DIR}/logs/health-check.log"

# 初期化
mkdir -p "$(dirname "$REPORT_FILE")" "$(dirname "$LOG_FILE")"

# ==================== ヘルパー関数 ====================
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" >> "$LOG_FILE"
}

# JSON形式でレポート出力
generate_report() {
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    local status=$1
    local checks=$2

    cat > "$REPORT_FILE" << EOF
{
  "timestamp": "$timestamp",
  "status": "$status",
  "checks": $checks
}
EOF

    cat "$REPORT_FILE"
}

# ==================== 健全性チェック ====================

# Git状態確認
check_git_status() {
    local output="{}"

    if cd "$REPO_ROOT" 2>/dev/null; then
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
        local remote_branch="origin/$(echo $branch | sed 's/^origin\///')"
        local local_hash=$(git rev-parse HEAD 2>/dev/null || echo "")
        local remote_hash=$(git rev-parse "$remote_branch" 2>/dev/null || echo "")

        local behind=0
        local ahead=0
        if [[ -n "$local_hash" && -n "$remote_hash" ]]; then
            behind=$(git rev-list --count "$remote_hash"..."$local_hash" 2>/dev/null || echo "0")
            ahead=$(git rev-list --count "$local_hash"..."$remote_hash" 2>/dev/null || echo "0")
        fi

        output="{\"branch\": \"$branch\", \"ahead\": $ahead, \"behind\": $behind}"
    fi

    echo "$output"
}

# Docker環境確認
check_docker_status() {
    local output="{\"docker_running\": false, \"services\": {}}"

    if command -v docker-compose &>/dev/null && cd "$REPO_ROOT" 2>/dev/null; then
        if docker-compose ps >/dev/null 2>&1; then
            local services=$(docker-compose ps --services 2>/dev/null | tr '\n' ',')
            services="${services%,}"
            output="{\"docker_running\": true, \"services\": \"$services\"}"
        fi
    fi

    echo "$output"
}

# プロジェクト構成確認
check_project_structure() {
    local checks=0
    local found=0

    for dir in apps packages scripts docs; do
        if [[ -d "$REPO_ROOT/$dir" ]]; then
            ((found++))
        fi
        ((checks++))
    done

    for file in CLAUDE.md README.md docker-compose.yml; do
        if [[ -f "$REPO_ROOT/$file" ]]; then
            ((found++))
        fi
        ((checks++))
    done

    echo "{\"total_checks\": $checks, \"passed\": $found}"
}

# ルーティン・スケジュール確認（ローカル内容確認）
check_routines() {
    local routine_count=0

    if [[ -f "${MONITORING_DIR}/config.json" ]]; then
        routine_count=$(jq '.routines | length' "${MONITORING_DIR}/config.json" 2>/dev/null || echo "0")
    fi

    echo "{\"configured_routines\": $routine_count}"
}

# ==================== レポート生成 ====================
main() {
    log "=== Health Check Started ==="

    local git_status=$(check_git_status)
    local docker_status=$(check_docker_status)
    local project_status=$(check_project_structure)
    local routine_status=$(check_routines)

    # 合成レポート（コンテキスト効率化）
    local checks_json=$(jq -n \
        --argjson git "$git_status" \
        --argjson docker "$docker_status" \
        --argjson project "$project_status" \
        --argjson routines "$routine_status" \
        '{
            "git": $git,
            "docker": $docker,
            "project_structure": $project,
            "routines": $routines
        }' 2>/dev/null || echo '{}')

    # 全体ステータス判定（簡易判定）
    local overall_status="healthy"

    # チェック結果出力
    local report=$(generate_report "$overall_status" "$checks_json")

    log "=== Health Check Completed ==="
    log "Report: $report"

    # 標準出力にも出力（パイプ用）
    echo "$report"
}

main "$@"
