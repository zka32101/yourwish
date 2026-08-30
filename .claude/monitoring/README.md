# Monitoring Agent System

**yourwish プロジェクト用 監視エージェント**

オーケストレーターと開発環境を監視し、新たな問題を検出・自動解決するシステムです。コンテキストウィンドウ効率化のため、定期的にチェックを実行します。

## ディレクトリ構成

```
.claude/monitoring/
├── README.md                    # このファイル
├── config.json                  # 監視設定ファイル
├── scripts/
│   ├── health-check.sh         # ヘルスチェック（Git/Docker/プロジェクト構成）
│   ├── detect-issues.sh        # 新たな問題検出
│   ├── auto-resolve-issues.sh  # 検出問題の自動解決
│   └── monitoring-dashboard.sh # ステータスダッシュボード
├── reports/
│   ├── latest-check.json       # 最新ヘルスチェックレポート
│   └── detected-issues.json    # 検出された問題リスト
└── logs/
    ├── health-check.log        # ヘルスチェックログ
    ├── issue-detection.log     # 問題検出ログ
    └── auto-resolution.log     # 自動解決ログ
```

## 使用方法

### 1. ヘルスチェック実行

プロジェクトの健全性を確認：

```bash
./.claude/monitoring/scripts/health-check.sh
```

**出力例：**
```json
{
  "timestamp": "2026-08-30T00:09:48Z",
  "status": "healthy",
  "checks": {
    "git": {"branch": "claude/monitoring-agent-verification-b0kqfh", ...},
    "docker": {"docker_running": false, ...},
    "project_structure": {"total_checks": 7, "passed": 7},
    "routines": {"configured_routines": 0}
  }
}
```

### 2. 新たな問題検出

開発環境の問題を自動検出：

```bash
./.claude/monitoring/scripts/detect-issues.sh
```

**検出対象：**
- Git同期問題（リモート/ローカル差分）
- Docker環境の問題
- プロジェクト構成の不整合
- リソース問題（ディスク領域など）
- 権限・設定の不足

### 3. 自動解決

検出された問題を自動的に解決：

```bash
./.claude/monitoring/scripts/auto-resolve-issues.sh
```

**解決可能な問題：**
- スクリプト権限の修正
- 監視設定の初期化
- 必要なディレクトリの作成

**ガイダンスが必要な問題：**
- Node.js/Docker のインストール案内
- 未コミット変更の提案

### 4. ダッシュボード表示

全体のステータスを確認：

```bash
./.claude/monitoring/scripts/monitoring-dashboard.sh
```

## 監視フロー（推奨）

```bash
# 1. 定期的なチェック（30分～1時間ごと）
./.claude/monitoring/scripts/detect-issues.sh
./.claude/monitoring/scripts/health-check.sh

# 2. 自動解決を試みる
./.claude/monitoring/scripts/auto-resolve-issues.sh

# 3. ダッシュボードで確認
./.claude/monitoring/scripts/monitoring-dashboard.sh

# 4. 必要に応じてログをレビュー
tail -f ./.claude/monitoring/logs/*.log
```

## 設定ファイル（config.json）

```json
{
  "monitoring_agent": {
    "name": "Monitoring Agent - yourwish",
    "version": "1.0.0"
  },
  "checks": {
    "enabled": true,
    "interval_minutes": 60,      // チェック間隔
    "timeout_seconds": 30         // チェックタイムアウト
  },
  "git": {
    "monitor_branch": "claude/monitoring-agent-verification-b0kqfh",
    "track_remote": true          // リモート追跡
  },
  "docker": {
    "monitor_services": true,
    "services": ["claude"]
  },
  "alerts": {
    "git_divergence_threshold": 5,        // コミット数の差分閾値
    "disk_space_threshold_percent": 80    // ディスク使用率の警告レベル
  }
}
```

## ログファイル

すべてのログは `.claude/monitoring/logs/` に保存：

- **health-check.log** - ヘルスチェック履歴
- **issue-detection.log** - 問題検出履歴
- **auto-resolution.log** - 自動解決の実行ログ

```bash
# リアルタイム監視
tail -f ./.claude/monitoring/logs/*.log

# 特定のスクリプトのログ確認
grep "Issue detected" ./.claude/monitoring/logs/issue-detection.log
```

## オーケストレーターとの連携

このモニタリングエージェントは以下をサポート：

1. **オーケストレーター監視** - セッション状態を定期確認
2. **リソース監視** - CPU/メモリ使用状況の追跡
3. **エラー通知** - 問題検出時の自動レポート
4. **自動修復** - 軽度の問題を自動解決

## コンテキストウィンドウ最適化

- 簡潔な JSON レポート形式で情報をコンパクト化
- ログは自動的にローテーション（最新のみ保持）
- 定期実行はスケジュール管理ツールで実装

## トラブルシューティング

### スクリプトが実行できない

```bash
chmod +x ./.claude/monitoring/scripts/*.sh
```

### レポートファイルが見つからない

ディレクトリが自動作成されます：

```bash
mkdir -p ./.claude/monitoring/{reports,logs}
```

### 権限エラー

Docker や sudo コマンドが必要な場合、以下を確認：

```bash
# Docker グループに追加（Linux）
sudo usermod -aG docker $USER
newgrp docker
```

## 今後の拡張

- [ ] Slack/Discord への通知機能
- [ ] メトリクス可視化ダッシュボード
- [ ] CI/CD パイプライン連携
- [ ] パフォーマンストレンド分析

---

**最終更新**: 2026-08-30
**バージョン**: 1.0.0
