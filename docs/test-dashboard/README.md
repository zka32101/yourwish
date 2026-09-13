# 📊 テスト結果ダッシュボード

## 概要

このダッシュボードは、7観点統合テストのリアルタイム結果を可視化します。

- **URL**: `/docs/test-dashboard/index.html`
- **自動更新**: GitHub Actions の実行時に自動生成
- **リテンション**: 30日間保存
- **アクセス**: GitHub Pages 経由

## 📈 表示内容

### 1. テスト通過率
- 7観点別の通過率を棒グラフで表示
- 目標値: 90%以上
- 警告: 70%未満で黄色表示

### 2. パフォーマンスメトリクス
- 起動時間、画面ロード、メモリ、バッテリー、CPU
- 基準値との比較
- トレンドグラフ表示

### 3. テスト詳細結果
- 各テスト項目の詳細スコア
- 合格/警告/失敗の判定
- 時系列データ

### 4. プロジェクト別メトリクス
- shogi_app / card_rivals の比較
- パフォーマンス差分表示

## 🔄 更新フロー

```
GitHub Actions トリガー
    ↓
テスト実行 & メトリクス収集
    ↓
detect_regression.sh (案C)
    ↓
generate_test_dashboard.sh (案E)
    ↓
ダッシュボード HTML 生成
    ↓
GitHub Pages へデプロイ
    ↓
リアルタイム可視化 ✅
```

## 📊 データフォーマット

```json
{
  "timestamp": "2026-09-13T12:00:00Z",
  "tests": {
    "launch": 100,
    "firebase": 98,
    "auth": 85,
    "billing": 75,
    "ads": 80,
    "crash": 100,
    "performance": 95
  },
  "metrics": {
    "shogi_app": {
      "startup_time_ms": 3200,
      "screen_load_time_ms": 1950,
      "memory_increase_mb": 48,
      "battery_consumption_percent_per_min": 4.8,
      "cpu_usage_percent": 28
    },
    "card_rivals": {
      "startup_time_ms": 2800,
      "screen_load_time_ms": 1800,
      "memory_increase_mb": 45,
      "battery_consumption_percent_per_min": 4.5,
      "cpu_usage_percent": 26
    }
  }
}
```

## 🎯 使用方法

### ローカル確認
```bash
# ダッシュボード生成
bash scripts/generate_test_dashboard.sh

# ブラウザで確認
open docs/test-dashboard/index.html
```

### GitHub Pages での公開
```bash
# GitHub Pages 設定済みの場合、自動的に公開
# https://zka32101.github.io/yourwish/test-dashboard/
```

## 📋 チェックリスト

- [x] HTML ダッシュボード生成スクリプト実装
- [x] メトリクス集約機能実装
- [x] グラフ表示（Chart.js）
- [x] GitHub Pages デプロイ設定
- [ ] リアルタイム更新（WebSocket）- 将来の改善
- [ ] モバイル最適化 - 将来の改善
- [ ] ダークテーマ対応 - 将来の改善

## 🔧 カスタマイズ

### 基準値の変更
`COMPLETE_TEST_AUTOMATION_2026_09_13.md` のパフォーマンスベースラインセクションを参照

### グラフカラーの変更
`docs/test-dashboard/index.html` の CSS セクションを編集

### 更新間隔の変更
`.github/workflows/7perspective-test.yml` の `schedule` セクションを編集

## 📞 トラブルシューティング

### ダッシュボードが表示されない
- [ ] GitHub Pages が有効化されているか確認
- [ ] リポジトリ設定で Pages を main/docs に設定
- [ ] 5分待ってページをリロード

### メトリクスが古い
- [ ] GitHub Actions が成功したか確認
- [ ] test_results/dashboard_metrics.json を確認

---

**作成日**: 2026-09-13  
**ROI**: 2.0倍  
**実装時間**: 2-3時間
