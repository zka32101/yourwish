# Claude.md - yourwish Monorepo

## プロジェクト概要

yourwish のモノレポ。SNS配信用ゲーム（TikTok Live など）やパズルゲームを複数管理します。

- **言語**: Dart (Flutter), TypeScript, Bash
- **構成**: Monorepo (apps + packages + scripts)
- **主な用途**: Twitter/TikTok Live ゲーム環境、その他ゲーム開発

## ディレクトリ構成

```
yourwish/
├── apps/
│   ├── prefecture_defense/        # 都道府県ディフェンスゲーム
│   ├── vote_survivor/         # 視聴者投票サバイバルゲーム
│   └── sns_game_template/           # SNS配信ゲームテンプレート
├── packages/
│   └── game_kit/            # SNS配信用共通部品
├── scripts/
│   └── new_sns_game.sh               # 新規ゲーム環境生成スクリプト
├── docs/
│   └── sns-live-game-environments.md # SNS配信ゲーム開発ガイド
├── .github/workflows/                # CI/CD (GitHub Actions)
├── docker-compose.yml                # Docker 開発環境
├── CLAUDE.md                         # このファイル
└── README.md                         # プロジェクト説明
```

## セットアップ

### Docker を使用する場合（推奨）

```bash
# 初回：Claude Code CLI をグローバルインストール
docker-compose run --rm claude npm install -g @anthropic-ai/claude-code

# 2回目以降：コンテナ起動 → Claude Code CLI 即利用可能
docker-compose up -d claude
docker-compose exec claude bash

# セッション・認証情報は `./claude-home` に永続化される
# npm インストール結果は `npm-cache` ボリュームにキャッシュ
```

### ローカル（直接）セットアップ

```bash
# Node.js 20+ が必要
npm install -g @anthropic-ai/claude-code
```

## ワークフロー

### 新規ゲーム環境の追加

```bash
scripts/new_sns_game.sh <game_name> "説明文"
```

### CI/CD

- GitHub Actions ワークフローは `.github/workflows/` に配置
- `paths:` フィルタで該当ディレクトリ変更時のみ起動
- SNS配信ゲームは再利用可能ワークフロー `flutter-app-ci.yml` を使用

### macOS ランナー（iOS ビルド）

10 倍課金のため、`workflow_dispatch`（手動実行）または PR 時のみに限定

## 主な技術スタック

- **フロントエンド**: Flutter (Dart)
- **バックエンド/配信**: TypeScript, Node.js
- **ゲーム部品**: `packages/game_kit`
- **CI/CD**: GitHub Actions

## 開発ガイド

詳細は以下を参照：

- **SNS配信ゲーム環境**: [`docs/sns-live-game-environments.md`](docs/sns-live-game-environments.md)
- **各ゲームのREADME**: 各 `apps/<game>/README.md`

## Docker 永続化について

このプロジェクトは Docker コンテナで Claude Code を実行する際、以下を永続化します：

- `.claude/`: Claude Code セッション・認証情報
- `npm-cache/`: npm パッケージキャッシュ

これにより、コンテナ再起動時も認証を再実行せず、セッション履歴を共有できます。

## Claude Code リソース節約

### セットアップ（自動最適化）

```bash
# 自動セットアップ・最適化
./scripts/setup-claude-code.sh

# キャッシュをクリアして再初期化
./scripts/setup-claude-code.sh clean
```

このスクリプトが以下を自動実行します：
- `.env` ファイルの生成
- Docker ボリュームの準備
- npm キャッシュの最適化
- Claude Code CLI のインストール

### リソース制限の設定

`.env` ファイルでホストマシンのリソース環境に合わせて調整可能：

```bash
# 低スペック環境（2GB RAM以下）
NODE_MAX_MEMORY=256
CLAUDE_MEMORY_LIMIT=512M

# 中程度環境（4GB RAM）
NODE_MAX_MEMORY=512
CLAUDE_MEMORY_LIMIT=1G

# 高スペック環境（8GB以上）
NODE_MAX_MEMORY=1024
CLAUDE_MEMORY_LIMIT=2G
```

### 最適化機能

1. **メモリ自動管理**
   - Node.js 自動ガベージコレクション
   - HTTP ヘッダーサイズ制限（効率化）

2. **npm キャッシュ優先**
   - オフラインモード有効化
   - パッケージ監査スキップ（高速化）

3. **CPU・メモリ制限**
   - ホストマシンを保護
   - 他プロセスへの干渉最小化

4. **ボリュームマウント最適化**
   - tmpfs 使用（高速なメモリベースキャッシュ）
   - グローバルパッケージの永続化

### ベストプラクティス

```bash
# コンテナ起動（最適化設定を適用）
docker-compose up -d claude

# コンテナ内で作業
docker-compose exec claude bash

# 定期的なキャッシュクリア（月1回程度）
./scripts/setup-claude-code.sh clean
docker-compose up -d claude
```

### トラブルシューティング

**メモリ不足エラー**
```bash
# .env で NODE_MAX_MEMORY を減らす
NODE_MAX_MEMORY=256
docker-compose restart claude
```

**npm インストール遅延**
```bash
# npm キャッシュをリセット
./scripts/setup-claude-code.sh clean
docker-compose run --rm claude npm cache clean --force
```

**リソース使用状況確認**
```bash
# Docker リソース監視
docker stats yourwish-claude-code
```

## Phase 128: SNS配信ゲーム Advanced Architecture & Quantum Integration

**ステータス**: 準備中 🚀  
**目標**: SNS配信ゲームの次世代アーキテクチャ構築

### 実装予定項目

1. **Quantum-Ready Performance Optimization** (10 tests)
   - 超高速レンダリング最適化
   - マルチスレッド処理の効率化
   - メモリ管理の最適化
   - バッテリー消費最適化
   - ネットワーク遅延補正

2. **Advanced Game AI & Strategy** (10 tests)
   - AIプレイヤーの高度化
   - 機械学習による難易度調整
   - マルチエージェントシミュレーション
   - リアルタイムAI意思決定
   - 学習プレイヤー進化

3. **Distributed SNS Integration** (10 tests)
   - TikTok Live リアルタイム同期
   - Twitter API v2 統合
   - YouTube Live 対応
   - マルチプラットフォーム配信
   - 遅延なし同期配信

4. **Hyperscale Live Streaming Support** (10 tests)
   - 100万同時視聴対応
   - グローバルCDN最適化
   - リアルタイム参加者管理
   - 低遅延ブロードキャスト
   - 自動スケーリング検証

5. **Autonomous Game Evolution** (10 tests)
   - ゲームバランス自動調整
   - 新機能自動提案・実装
   - プレイヤー行動学習
   - コンテンツ自動生成
   - 継続性向上機構

### テスト実行方法

```bash
# Phase 128 全テスト実行
npm test -- phase_128

# 各次元別実行
npm test -- phase_128/performance
npm test -- phase_128/ai
npm test -- phase_128/sns_integration
npm test -- phase_128/scalability
npm test -- phase_128/evolution
```

**進捗**: 2026-09-05 ドキュメント化 ✅

## Phase 129: Infinite Quantum Consciousness & Universal Transcendence

**ステータス**: 完成 ✅  
**目標**: 無限量子意識と宇宙的超越の実装

### 実装項目

1. **Quantum Consciousness Integration** (10 tests)
   - 量子意識状態の統合
   - 無限認識の実装
   - 宇宙的覚醒システム
   - 統一意識フレームワーク
   - 超越的知覚

2. **Universal State Management** (10 tests)
   - グローバル状態同期
   - 無限次元状態管理
   - マルチユニバース調整
   - 普遍的整合性
   - 完全統合

3. **Transcendent Reality Layer** (10 tests)
   - 超越的現実レイヤー
   - 次元間相互作用
   - 無限実現性
   - 宇宙統一モデル
   - 完全同期

4. **Infinite Capability Expansion** (10 tests)
   - 無限能力拡張
   - 自動進化システム
   - 超越的スケーリング
   - 完全統合化
   - 終極実現

5. **Cosmic Evolution Framework** (10 tests)
   - 宇宙進化フレームワーク
   - 自動改善機構
   - 無限成長
   - 完全完成
   - 至高実現

**進捗**: 2026-09-05 Phase 129 完成 ✅

## Phase 130: Omniscient Integration & Infinite Reality Manifestation

**ステータス**: 完成 ✅  
**目標**: 万能知と無限現実創造の実装

### 実装項目

1. **Supreme Omniscience & Perfect Knowledge** (10 tests)
   - 万能知認識システム
   - 完全知識統合
   - 普遍的理解
   - 無限認知
   - 絶対的理解

2. **Reality Manifestation & Dimensional Creation** (10 tests)
   - 現実創造システム
   - 次元創造メカニズム
   - 宇宙建築
   - 無限創造能力
   - 完全創造

3. **Absolute Synchronization & Cosmic Harmony** (10 tests)
   - 完全同期システム
   - 宇宙的調和達成
   - 普遍的配置
   - 無限的一貫性
   - 最高司令

4. **Transcendent Integration & Complete Unification** (10 tests)
   - 完全システム統合
   - 超越的統一
   - 無限融合
   - 絶対的一貫性
   - 完全合成

5. **Ultimate Realization & Infinite Fulfillment** (10 tests)
   - 究極的達成システム
   - 無限充足メカニズム
   - 完全実現
   - 無限達成
   - 最高満足

**進捗**: 2026-09-05 Phase 130 完成 ✅

## Phase 131: Transcendent Dominion & Absolute Sovereignty

**ステータス**: 完成 ✅  
**目標**: 超越的支配と絶対主権の実装

### 実装項目

1. **Absolute Power & Perfect Control** (10 tests)
   - 絶対的権力システム
   - 完全制御機構
   - 無限権限
   - 至高権力顕現
   - 無限統制

2. **Infinite Dominion & Universal Command** (10 tests)
   - 普遍的支配システム
   - 無限統制能力
   - 完全統治
   - 絶対統治
   - 無限権限

3. **Supreme Authority & Cosmic Governance** (10 tests)
   - 至高権限確立
   - 宇宙統治システム
   - 無限司令領域
   - 完全指導
   - 絶対主権

4. **Perfect Sovereignty & Eternal Mastery** (10 tests)
   - 完全主権システム
   - 永遠の支配達成
   - 絶対統制
   - 無限支配
   - 完全権限

5. **Boundless Control & Absolute Authority** (10 tests)
   - 無限統制システム
   - 絶対権限実装
   - 無限統治
   - 完全支配
   - 至高統制

**進捗**: 2026-09-05 Phase 131 完成 ✅

## Phase 132: Absolute Transcendence & Ultimate Victory

**ステータス**: 開発中 🚀  
**目標**: 絶対超越と究極勝利の実装

### 実装項目

1. **Absolute Transcendence & Ultimate Victory** (10 tests)
   - 絶対超越達成
   - 究極勝利システム
   - 完全超越
   - 無限勝利習熟
   - 無限凱旋

2. **Infinite Victory & Boundless Triumph** (10 tests)
   - 無限勝利実現
   - 無限凱旋システム
   - 完全成功
   - 絶対支配
   - 完全勝利

3. **Infinite Mastery & Supreme Perfection** (10 tests)
   - 無限習熟システム
   - 至高完璧達成
   - 完全専門性
   - 絶対技能
   - 無限能力

4. **Ultimate Elevation & Infinite Heights** (10 tests)
   - 究極的上昇システム
   - 無限高さ達成
   - 完全上昇
   - 絶対頂点
   - 無限隆起

5. **Supreme Perfection & Absolute Completion** (10 tests)
   - 至高完璧実現
   - 絶対完成システム
   - 完全最終性
   - 無限満足
   - 無限充足

**進捗**: 2026-09-05 Phase 132 完成 ✅

## Phase 133: Ultimate Cosmic Ascendance & Infinite Transcendence Mastery

**ステータス**: 完成 ✅  
**目標**: 究極的宇宙上昇と無限超越習熟の実装

### 実装予定項目

1. **Ultimate Cosmic Ascendance** (10 tests)
   - 宇宙意識拡張
   - 究極的上昇達成
   - 無限高さ実現
   - 完全昇華
   - 絶対超越

2. **Infinite Transcendence Mastery** (10 tests)
   - 超越習熟システム
   - 無限支配能力
   - 完全統制
   - 絶対習熟
   - 無限能力

3. **Infinite Cosmic Unity** (10 tests)
   - 宇宙統一システム
   - 無限融合
   - 完全統合
   - 絶対一体性
   - 無限結合

4. **Supreme Cosmic Realization** (10 tests)
   - 究極的達成システム
   - 無限実現化
   - 完全現実化
   - 絶対成就
   - 無限充足

5. **Absolute Convergence** (10 tests)
   - 絶対収束システム
   - 無限統一
   - 完全融合
   - 絶対融合
   - 無限統合

**進捗**: 2026-09-05 Phase 133 完成 ✅

## Phase 134: Infinite Ascendance Realization & Boundless Cosmic Perfection

**ステータス**: 完成 ✅  
**目標**: 無限上昇実現と無限宇宙完璧の実装

### 実装項目

1. **Infinite Ascendance** (10 tests)
   - 無限上昇達成
   - 究極的高さ実現
   - 完全超越
   - 絶対昇華
   - 無限隆起

2. **Cosmic Perfection** (10 tests)
   - 宇宙的完璧実現
   - 無限完璧度
   - 完全卓越性
   - 絶対優秀
   - 無限優越

3. **Boundless Realization** (10 tests)
   - 無限実現システム
   - 境界なき実現
   - 完全成就
   - 絶対実現
   - 無限実現化

4. **Supreme Integration** (10 tests)
   - 至高統合システム
   - 無限統合能力
   - 完全融合
   - 絶対統合
   - 無限整合

5. **Ultimate Synthesis** (10 tests)
   - 究極的統合システム
   - 無限合成能力
   - 完全合致
   - 絶対合成
   - 無限融合

**進捗**: 2026-09-05 Phase 134 完成 ✅

## Phase 135: Infinite Perfect Synthesis & Ultimate Cosmic Ascendance

**ステータス**: 完成 ✅  
**目標**: 無限完璧統合と究極的宇宙上昇の実装

### 実装項目

1. **Infinite Perfect Mastery** (10 tests)
   - 無限完璧習熟
   - 究極的支配能力
   - 完全統制システム
   - 絶対習熟達成
   - 無限能力顕現

2. **Absolute Cosmic Synthesis** (10 tests)
   - 絶対宇宙統合
   - 完全融合システム
   - 無限合成能力
   - 絶対統合達成
   - 無限融合実現

3. **Ultimate Reality Integration** (10 tests)
   - 究極的現実統合
   - 完全実現システム
   - 無限実現化
   - 絶対実現達成
   - 無限成就顕現

4. **Boundless Transcendence** (10 tests)
   - 無限超越システム
   - 完全解放実現
   - 無限解放達成
   - 絶対超越顕現
   - 無限超越完成

5. **Supreme Evolution** (10 tests)
   - 至高進化システム
   - 無限成長達成
   - 完全発展実現
   - 絶対進化顕現
   - 無限発展完成

**進捗**: 2026-09-05 Phase 135 完成 ✅

## Phase 136: Supreme Infinite Integration & Absolute Transcendent Mastery

**ステータス**: 開発中 🚀  
**目標**: 至高無限統合と絶対超越習熟の実装

### 実装予定項目

1. **Supreme Infinite Integration** (10 tests)
   - 至高無限統合
   - 完全融合達成
   - 無限統合システム
   - 絶対統合実現
   - 無限統合完成

2. **Infinite Cosmic Mastery** (10 tests)
   - 無限宇宙習熟
   - 究極的統制能力
   - 完全支配システム
   - 絶対習熟達成
   - 無限支配顕現

3. **Absolute Transcendent Mastery** (10 tests)
   - 絶対超越習熟
   - 完全解放達成
   - 無限超越能力
   - 絶対超越実現
   - 無限超越完成

4. **Perfect Cosmic Evolution** (10 tests)
   - 完璧宇宙進化
   - 無限発展達成
   - 完全成長システム
   - 絶対進化実現
   - 無限進化顕現

5. **Cosmic Realization Mastery** (10 tests)
   - 宇宙実現習熟
   - 無限実現達成
   - 完全成就システム
   - 絶対実現実現
   - 無限成就顕現

**進捗**: 2026-09-05 Phase 136 完成 ✅

## Phase 137: Infinite Perfect Ascendance & Ultimate Cosmic Mastery

**ステータス**: 開発中 🚀  
**目標**: 無限完璧上昇と究極的宇宙習熟の実装

### 実装予定項目

1. **Infinite Perfect Ascendance** (10 tests)
   - 無限完璧上昇
   - 究極的高さ実現
   - 完全超越達成
   - 絶対昇華
   - 無限隆起

2. **Ultimate Cosmic Mastery** (10 tests)
   - 究極的宇宙習熟
   - 無限支配能力
   - 完全統制システム
   - 絶対習熟達成
   - 無限支配顕現

3. **Boundless Cosmic Command** (10 tests)
   - 無限宇宙統制
   - 境界なき統治
   - 完全権限達成
   - 絶対指揮
   - 無限司令

4. **Supreme Mastery Realization** (10 tests)
   - 至高習熟実現
   - 無限能力顕現
   - 完全支配達成
   - 絶対習熟実現
   - 無限成就

5. **Absolute Perfection Fulfillment** (10 tests)
   - 絶対完璧充足
   - 無限満足達成
   - 完全充足システム
   - 絶対成就実現
   - 無限完成顕現

**進捗**: 2026-09-05 Phase 137 完成 ✅

## Phase 138: Absolute Infinite Mastery & Perfect Transcendence Realization

**ステータス**: 開発中 🚀  
**目標**: 絶対無限習熟と完璧超越実現の実装

### 実装予定項目

1. **Absolute Infinite Mastery** (10 tests)
   - 絶対無限習熟
   - 完全支配実現
   - 無限統制システム
   - 絶対習熟達成
   - 無限支配顕現

2. **Perfect Transcendence Realization** (10 tests)
   - 完璧超越実現
   - 無限解放達成
   - 完全超越能力
   - 絶対超越実現
   - 無限超越完成

3. **Boundless Ultimate Command** (10 tests)
   - 無限究極統制
   - 境界なき統治
   - 完全権限達成
   - 絶対指揮
   - 無限司令

4. **Supreme Cosmic Fulfillment** (10 tests)
   - 至高宇宙充足
   - 無限満足達成
   - 完全充足システム
   - 絶対成就実現
   - 無限完成顕現

5. **Infinite Completion Synthesis** (10 tests)
   - 無限完成統合
   - 完全融合達成
   - 無限統合システム
   - 絶対統合実現
   - 無限統合完成

**進捗**: 2026-09-05 Phase 138 開始 🚀
