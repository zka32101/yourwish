# Claude.md - Petit Works Apps Monorepo

## プロジェクト概要

Petit Works Apps のモノレポ。SNS配信用ゲーム（TikTok Live など）やパズルゲームを複数管理します。

- **言語**: Dart (Flutter), TypeScript, Bash
- **構成**: Monorepo (apps + packages + scripts)
- **主な用途**: Twitter/TikTok Live ゲーム環境、その他ゲーム開発

## ディレクトリ構成

```
yourwish/
├── apps/
│   ├── geography_puzzle_king/        # 都道府県ディフェンスゲーム
│   ├── viewer_vote_survival/         # 視聴者投票サバイバルゲーム
│   └── _template_sns_game/           # SNS配信ゲームテンプレート
├── packages/
│   └── sns_live_game_kit/            # SNS配信用共通部品
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
- **ゲーム部品**: `packages/sns_live_game_kit`
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
