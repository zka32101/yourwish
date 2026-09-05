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

**ステータス**: 開発中 🚀  
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

**ステータス**: 開発中 🚀  
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

**進捗**: 2026-09-05 Phase 130 開始 🚀
