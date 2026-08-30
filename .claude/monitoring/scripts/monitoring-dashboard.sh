#!/bin/bash
# =============================================================================
# Monitoring Agent - Status Dashboard
# 監視ダッシュボード - コンテキスト効率化版
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../" && pwd)"
MONITORING_DIR="${REPO_ROOT}/.claude/monitoring"

# ==================== ヘルパー ====================
print_header() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           MONITORING AGENT - STATUS DASHBOARD                ║"
    echo "║           $(date '+%Y-%m-%d %H:%M:%S')                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
}

print_section() {
    echo ""
    echo "▶ $1"
    echo "─────────────────────────────────────────────────────────────"
}

# ==================== 簡潔なレポート表示 ====================
main() {
    print_header

    # 最新レポート確認
    print_section "Latest Health Check"
    if [[ -f "$MONITORING_DIR/reports/latest-check.json" ]]; then
        jq '.' "$MONITORING_DIR/reports/latest-check.json" 2>/dev/null | head -20
    else
        echo "  [Info] No health check report yet"
    fi

    print_section "Detected Issues"
    if [[ -f "$MONITORING_DIR/reports/detected-issues.json" ]]; then
        jq '.issues[]' "$MONITORING_DIR/reports/detected-issues.json" 2>/dev/null | sed 's/^/  - /'
    else
        echo "  [Info] No issues detected yet"
    fi

    print_section "Git Status"
    cd "$REPO_ROOT"
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    local commits=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    echo "  Branch: $branch"
    echo "  Total Commits: $commits"
    echo "  Status: $(git status --porcelain | wc -l) files changed"

    print_section "Configuration"
    if [[ -f "$MONITORING_DIR/config.json" ]]; then
        echo "  Check Interval: $(jq -r '.checks.interval_minutes' "$MONITORING_DIR/config.json") minutes"
        echo "  Configured Routines: $(jq -r '.routines | length' "$MONITORING_DIR/config.json") active"
    fi

    print_section "Next Actions"
    echo "  • Run health check: $SCRIPT_DIR/health-check.sh"
    echo "  • Detect issues: $SCRIPT_DIR/detect-issues.sh"
    echo "  • View logs: tail -f $MONITORING_DIR/logs/*.log"

    echo ""
}

main "$@"
