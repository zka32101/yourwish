#!/bin/bash
# =============================================================================
# Monitoring Agent - Issue Detection Script
# 新たな問題を検出し、解決するための仕組み
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../" && pwd)"
MONITORING_DIR="${REPO_ROOT}/.claude/monitoring"
ISSUES_FILE="${MONITORING_DIR}/reports/detected-issues.json"
LOG_FILE="${MONITORING_DIR}/logs/issue-detection.log"

mkdir -p "$(dirname "$ISSUES_FILE")" "$(dirname "$LOG_FILE")"

# ==================== ロギング ====================
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" >> "$LOG_FILE"
}

# ==================== 問題検出関数 ====================

# 1. Git同期の問題
check_git_sync_issues() {
    local issues=()

    if cd "$REPO_ROOT" 2>/dev/null; then
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
        if [[ -z "$branch" ]]; then
            issues+=("Git branch not found")
            log "Issue detected: Git branch missing"
        fi

        # リモートとの同期確認
        if git fetch origin --dry-run 2>/dev/null | grep -q "error"; then
            issues+=("Git fetch failed - network or auth issue")
            log "Issue detected: Git fetch failure"
        fi

        # 未コミット変更確認
        if ! git diff --quiet 2>/dev/null; then
            issues+=("Uncommitted changes detected in repository")
            log "Issue detected: Uncommitted changes"
        fi
    fi

    echo "${issues[@]:-}"
}

# 2. Docker環境の問題
check_docker_issues() {
    local issues=()

    if ! command -v docker-compose &>/dev/null; then
        issues+=("docker-compose not installed")
        log "Issue detected: docker-compose missing"
    elif cd "$REPO_ROOT" 2>/dev/null; then
        # Docker デーモン確認
        if ! docker info >/dev/null 2>&1; then
            issues+=("Docker daemon is not running")
            log "Issue detected: Docker daemon not running"
        fi

        # 必須サービス確認
        local claude_running=$(docker-compose ps -q claude 2>/dev/null || echo "")
        if [[ -z "$claude_running" ]]; then
            issues+=("Claude container is not running")
            log "Issue detected: Claude container not running"
        fi
    fi

    echo "${issues[@]:-}"
}

# 3. プロジェクト構成の問題
check_structure_issues() {
    local issues=()

    local required_dirs=("apps" "packages" "scripts" "docs")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$REPO_ROOT/$dir" ]]; then
            issues+=("Missing directory: $dir")
            log "Issue detected: Missing directory $dir"
        fi
    done

    local required_files=("CLAUDE.md" "README.md" "docker-compose.yml")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$REPO_ROOT/$file" ]]; then
            issues+=("Missing file: $file")
            log "Issue detected: Missing file $file"
        fi
    done

    echo "${issues[@]:-}"
}

# 4. リソース問題
check_resource_issues() {
    local issues=()

    # ディスク領域確認
    local disk_usage=$(df "$REPO_ROOT" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 80 ]]; then
        issues+=("Disk usage high: ${disk_usage}%")
        log "Issue detected: High disk usage (${disk_usage}%)"
    fi

    # Node.js確認
    if ! command -v node &>/dev/null; then
        issues+=("Node.js is not installed")
        log "Issue detected: Node.js missing"
    fi

    echo "${issues[@]:-}"
}

# 5. 権限・設定の問題
check_config_issues() {
    local issues=()

    # .claude/settings.json 確認
    if [[ ! -f "$REPO_ROOT/.claude/settings.json" ]]; then
        issues+=("Missing .claude/settings.json configuration")
        log "Issue detected: Missing settings.json"
    fi

    # 実行権限確認
    if [[ ! -x "$SCRIPT_DIR/health-check.sh" ]]; then
        chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
        issues+=("Fixed: Script permissions updated")
        log "Fixed: Script permissions"
    fi

    echo "${issues[@]:-}"
}

# ==================== 問題レポート生成 ====================
generate_issue_report() {
    local all_issues=()
    local issue_count=0

    mapfile -t git_issues < <(check_git_sync_issues)
    mapfile -t -O "${#all_issues[@]}" all_issues < <(check_docker_issues)
    mapfile -t -O "${#all_issues[@]}" all_issues < <(check_structure_issues)
    mapfile -t -O "${#all_issues[@]}" all_issues < <(check_resource_issues)
    mapfile -t -O "${#all_issues[@]}" all_issues < <(check_config_issues)

    issue_count=${#all_issues[@]}

    # JSON形式で出力
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    local issues_json="["
    local first=true

    for issue in "${all_issues[@]}"; do
        if [[ -n "$issue" ]]; then
            if ! $first; then
                issues_json+=","
            fi
            issues_json+="\"$(echo "$issue" | sed 's/"/\\"/g')\""
            first=false
        fi
    done
    issues_json+="]"

    cat > "$ISSUES_FILE" << EOF
{
  "timestamp": "$timestamp",
  "total_issues": $issue_count,
  "issues": $issues_json,
  "status": $([ $issue_count -eq 0 ] && echo '"healthy"' || echo '"needs_attention"')
}
EOF

    cat "$ISSUES_FILE"
}

# ==================== メイン ====================
main() {
    log "=== Issue Detection Started ==="
    generate_issue_report
    log "=== Issue Detection Completed ==="
}

main "$@"
