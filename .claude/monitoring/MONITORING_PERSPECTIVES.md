# 監視エージェント - 拡張監視観点ガイド

**作成日**: 2026-08-30  
**監視頻度**: 週1回（日曜 00:00 UTC）  
**対象**: yourwish モノレポプロジェクト  

---

## 📋 現在の監視観点

### 現在実装済み（基本監視）

| 観点 | スクリプト | チェック項目 |
|------|-----------|-----------|
| **Git** | health-check.sh | ブランチ同期、コミット差分 |
| **Docker** | health-check.sh | デーモン起動、サービス稼働 |
| **構成** | health-check.sh | ディレクトリ/ファイル完全性 |
| **リソース** | detect-issues.sh | ディスク使用率 |
| **権限** | detect-issues.sh | スクリプト実行可能性 |

---

## 🎯 拡張監視観点の提案

### Phase A: 依存関係とコード品質（優先度: 高）

#### A1. 依存パッケージの脆弱性チェック

**監視頻度**: 週1回

```bash
# npm audit / yarn audit
npm audit --json | jq '.vulnerabilities[] | select(.severity == "critical")'

# Dart pub outdated
cd apps/geography_puzzle_king && flutter pub outdated --json

# Python pip (将来対応用)
pip audit --json
```

**チェック対象**:
- Critical/High 脆弱性の有無
- パッケージ更新可能性
- 依存関係の循環参照

**実装例**:
```bash
./.claude/monitoring/scripts/security-audit.sh
```

---

#### A2. コード品質・カバレッジ

**監視対象ファイル**:
- Dart コード (Flutter アプリ)
- TypeScript/JavaScript
- Bash スクリプト

**チェック項目**:
- テストカバレッジ率（目標: 80%+）
- Lint エラー数（目標: 0）
- 型チェック違反（目標: 0）
- TODO/FIXME コメント数

```bash
# Dart/Flutter
flutter analyze
dart analyze

# TypeScript
npm run lint
npm run typecheck

# Coverage
flutter test --coverage
```

---

#### A3. ドキュメント整備度

**チェック項目**:
- README ファイルの有無と鮮度
- API ドキュメントの完全性
- CHANGELOG の更新状況
- セットアップガイドの正確性

**評価スコア**:
```yaml
Documentation Score:
  README exists: 20%
  README is recent (< 30 days): 20%
  API docs complete: 20%
  CHANGELOG updated: 20%
  Setup guide tested: 20%
  Total: X / 100
```

---

### Phase B: パフォーマンスと効率性（優先度: 中）

#### B1. ビルドパフォーマンス

**監視対象**:
- Flutter build 時間（目標: < 2分）
- npm build 時間（目標: < 30秒）
- Docker イメージサイズ（目標: < 500MB）

**チェックスクリプト**:
```bash
./.claude/monitoring/scripts/build-performance.sh
```

**レポート例**:
```json
{
  "flutter_build": {
    "duration_seconds": 95,
    "status": "healthy",
    "trend": "stable"
  },
  "npm_build": {
    "duration_seconds": 18,
    "status": "healthy",
    "trend": "improving"
  },
  "docker_image": {
    "size_mb": 380,
    "status": "healthy",
    "warning": "size increased by 15MB"
  }
}
```

---

#### B2. リソース使用量トレンド

**監視対象**:
- メモリ使用量（アプリケーション）
- ディスク使用量（段階的なトレンド）
- npm キャッシュサイズ
- Docker イメージ数

**トレンド分析**:
```bash
# 週ごとのリソース使用量記録
./.claude/monitoring/scripts/resource-trend.sh
```

---

### Phase C: デプロイメントと CI/CD（優先度: 中）

#### C1. GitHub Actions ワークフロー監視

**監視項目**:
- 最後の実行日時
- 成功率（目標: 95%+）
- 平均実行時間
- 失敗したワークフロー

```bash
# GitHub API
gh workflow list --json name,state,updatedAt
gh run list --json conclusion,createdAt,durationMinutes
```

**レポート例**:
```json
{
  "workflows": {
    "total": 5,
    "enabled": 5,
    "recent_failures": 0,
    "success_rate": 98.5,
    "last_run": "2026-08-29T12:34:56Z"
  }
}
```

---

#### C2. リリース頻度の監視

**監視対象**:
- タグ作成頻度
- リリースノート更新
- セマンティックバージョニング準拠

---

### Phase D: セキュリティと監査（優先度: 高）

#### D1. 秘密情報スキャン

**監視項目**:
- API キー、トークンのハードコード
- 認証情報の露出
- .env ファイルのチェック

```bash
./.claude/monitoring/scripts/secret-scan.sh
```

**検出方法**:
```bash
# git-secrets, truffleHog など
truffleHog filesystem .

# 正規表現パターン
grep -r "api[_-]?key\|password\|token" \
  --include="*.dart" --include="*.ts" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=.git
```

---

#### D2. ライセンス準拠

**監視対象**:
- 依存パッケージのライセンスタイプ
- ライセンス互換性（GPL, MIT など）

```bash
# npm
npm ls --depth=0

# Dart
flutter pub deps
```

---

#### D3. データ保護・プライバシー

**チェック項目**:
- ユーザーデータの保護状況
- プライバシーポリシーとコード実装の一致
- GDPR/個人情報保護法への準拠

---

### Phase E: ユーザーエクスペリエンス（優先度: 低）

#### E1. アプリケーション起動テスト

**監視内容**:
- アプリが正常に起動するか
- 基本機能が動作するか
- クラッシュログの有無

```bash
./.claude/monitoring/scripts/smoke-test.sh
```

---

#### E2. ローカライゼーション

**チェック項目**:
- 多言語対応の整備度
- 翻訳の完全性
- 文字エンコーディング対応

---

### Phase F: 運用・保守性（優先度: 中）

#### F1. 技術負債の追跡

**監視対象**:
- TODO/FIXME コメント数
- 大きなメソッド/関数の検出
- 重複コードの検出

```bash
# TODO/FIXME カウント
find . -name "*.dart" -o -name "*.ts" -o -name "*.js" | \
  xargs grep -h "TODO\|FIXME" | wc -l

# 複雑度分析
dart analyze --threshold=high
```

---

#### F2. 過去のエラー・課題の再発防止

**実装方法**:
- `.claude/monitoring/logs/known-issues.json` に過去の問題を記録
- 定期的に同じパターンが再発していないかチェック

```json
{
  "known_issues": [
    {
      "id": "issue_001",
      "title": "Flutter build timeout",
      "occurred_at": "2026-08-20",
      "root_cause": "Node.js version mismatch",
      "solution": "Use Node.js 20+",
      "prevention": "Check node --version in CI",
      "status": "resolved"
    }
  ]
}
```

---

## 📊 週単位での監視スケジュール

### 日曜 00:00 UTC（毎週）

```bash
# 基本監視（Phase A〜F 全体）
1. detect-issues.sh              # 基本問題検出
2. health-check.sh               # 構成とリソース確認
3. security-audit.sh             # 脆弱性スキャン (新規)
4. build-performance.sh          # ビルドパフォーマンス (新規)
5. resource-trend.sh             # リソーストレンド記録 (新規)
6. smoke-test.sh                 # アプリケーション起動テスト (新規)
7. technical-debt-report.sh      # 技術負債追跡 (新規)
8. monitoring-dashboard.sh       # 統合レポート生成
```

**実行時間目安**: 5-10 分  
**レポート生成**: `reports/weekly-monitoring-{date}.json`

---

## 🎨 拡張スクリプト実装例

### security-audit.sh

```bash
#!/bin/bash
# 脆弱性監視

npm audit --json > /tmp/npm-audit.json
CRITICAL=$(jq '.vulnerabilities[] | select(.severity == "critical")' /tmp/npm-audit.json | wc -l)

if [[ $CRITICAL -gt 0 ]]; then
  echo "⚠️ Critical vulnerabilities detected: $CRITICAL"
  jq '.vulnerabilities[] | select(.severity == "critical")' /tmp/npm-audit.json
else
  echo "✅ No critical vulnerabilities"
fi
```

### build-performance.sh

```bash
#!/bin/bash
# ビルドパフォーマンス測定

START=$(date +%s)
flutter build apk --release > /dev/null 2>&1
END=$(date +%s)
DURATION=$((END - START))

echo "{
  \"flutter_build\": {
    \"duration_seconds\": $DURATION,
    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
  }
}"
```

---

## 📈 監視レポートの統合

### 週単位レポート構造

```json
{
  "week": "2026-09-06",
  "timestamp": "2026-09-06T00:00:00Z",
  "summary": {
    "status": "healthy",
    "issues_detected": 2,
    "issues_resolved": 1,
    "critical_alerts": 0
  },
  "phases": {
    "phase_a": {
      "dependencies": { "status": "ok", "vulnerabilities": 0 },
      "code_quality": { "coverage": 85, "lint_errors": 0 },
      "documentation": { "score": 92 }
    },
    "phase_b": {
      "build_performance": { "duration_seconds": 95, "trend": "stable" },
      "resources": { "disk_usage": 45, "memory_peak": 2100 }
    },
    "phase_c": {
      "ci_cd": { "success_rate": 98.5, "last_run": "2026-09-05" }
    },
    "phase_d": {
      "security": { "secrets_exposed": 0, "license_violations": 0 }
    }
  },
  "recommendations": [
    "Update TypeScript to 5.2+"
  ]
}
```

---

## 🔧 導入優先順序

### 今週実装
- [ ] security-audit.sh
- [ ] build-performance.sh

### 来週実装
- [ ] resource-trend.sh
- [ ] smoke-test.sh
- [ ] technical-debt-report.sh

### 将来実装
- [ ] ci-cd-audit.sh
- [ ] localization-check.sh
- [ ] privacy-compliance.sh

---

## 💡 カスタマイズポイント

各プロジェクトに応じて、以下をカスタマイズ可能：

### 1. チェック項目の重み付け

```yaml
weights:
  security: 0.3       # セキュリティ 30%
  performance: 0.25   # パフォーマンス 25%
  quality: 0.25       # コード品質 25%
  documentation: 0.2  # ドキュメント 20%
```

### 2. アラート閾値

```yaml
thresholds:
  test_coverage: 80      # テストカバレッジ 80% 以上
  build_time: 120        # ビルド時間 2分以内
  vulnerability_critical: 0  # 重大脆弱性 0 個
  disk_usage: 80         # ディスク使用率 80% 以下
```

### 3. 通知設定

```yaml
notifications:
  critical_issues: true     # 重大問題は即通知
  weekly_summary: true      # 週単位レポート
  performance_trends: false # トレンド報告は不要
```

---

## 📊 ダッシュボード表示案

### 週単位ダッシュボード

```
╔════════════════════════════════════════════════════════════╗
║         WEEKLY MONITORING REPORT - 2026-09-06             ║
║                    Overall: ✅ HEALTHY                    ║
╚════════════════════════════════════════════════════════════╝

📊 Overview
  Issues Detected: 2 | Resolved: 1 | Pending: 1
  Critical Alerts: 0 | Warnings: 2

🔐 Security
  Vulnerabilities: 0 Critical, 2 Medium
  Secrets Exposed: ❌ None
  License Violations: ✅ None

📈 Performance
  Build Time: 95s (↑ 5% vs last week)
  Disk Usage: 45% (→ stable)
  Test Coverage: 85% (↑ 2% vs last week)

💻 Code Quality
  Lint Errors: 0
  Tech Debt Score: 92/100
  TODO Comments: 8 (→ stable)

🚀 CI/CD
  Success Rate: 98.5%
  Last Workflow: 2026-09-05 12:34:56Z
  Avg Duration: 8m 45s

📋 Recommendations
  1. Update TypeScript to 5.2+
  2. Reduce build time (currently 95s → target: 60s)
```

---

## 🔗 関連ファイル

- `.claude/monitoring/config.json` - 監視設定
- `.claude/monitoring/scripts/` - 監視スクリプト群
- `.claude/monitoring/reports/` - 週単位レポート
- `.claude/monitoring/logs/` - 監視ログ

---

## 📌 まとめ

| 観点 | 実装済み | 推奨 | 実装時期 |
|------|--------|------|--------|
| **Phase A: 品質** | 部分 | 高 | 今週 |
| **Phase B: パフォーマンス** | × | 高 | 今週 |
| **Phase C: CI/CD** | × | 中 | 来週 |
| **Phase D: セキュリティ** | × | 高 | 今週 |
| **Phase E: UX** | × | 低 | 将来 |
| **Phase F: 運用** | × | 中 | 来週 |

---

**監視頻度**: 週1回（日曜 00:00 UTC）  
**実装期間**: 2-3 週間で全観点カバー  
**効果**: プロジェクト品質の可視化と継続的改善

---

**作成者**: Claude Haiku 4.5  
**最終更新**: 2026-08-30
