# Docker Claude Code テンプレート

このリポジトリは **GitHub Template** です。「Use this template」ボタンで新規プロジェクトを簡単に立ち上げられます。

Claude Code を Docker コンテナで実行するための、セットアップ・リソース最適化が組み込まれています。

## 🚀 クイックスタート

### 1. このテンプレートから新規リポジトリを作成

GitHub で **「Use this template」** をクリック

または、コマンドラインから：

```bash
git clone --depth 1 \
  https://github.com/zka32101/yourwish.git \
  my-new-project
cd my-new-project

# テンプレート情報を削除
rm -rf .git TEMPLATE_README.md
git init
git add .
git commit -m "Initial commit"
```

### 2. プロジェクト情報を編集

```bash
# CLAUDE.md を編集してプロジェクト説明を追加
vi CLAUDE.md

# README.md を編集
vi README.md
```

### 3. Docker セットアップを実行

```bash
# 自動セットアップ実行
./scripts/setup-claude-code.sh

# Docker コンテナ起動
docker-compose up -d claude

# コンテナに接続
docker-compose exec claude bash

# Claude Code 使用開始
claude-code auth status
```

---

## ✨ 組み込み機能

### 🐳 Docker 開発環境
- Node.js 20 Alpine ベース
- Claude Code CLI 自動インストール
- npm キャッシュ永続化

### 💾 セッション永続化
- Claude Code セッション・認証情報を永続化
- コンテナ再起動後も再認証不要

### ⚡ リソース最適化
- 低スペック環境（256MB）～ 高スペック環境（2GB+）に対応
- CPU・メモリ制限でホストマシンを保護
- Node.js メモリ自動管理

### 🎯 自動セットアップ
- セッション開始時に自動初期化
- ワンコマンド完全セットアップ
- スキル機能で手動実行も可能

---

## 📁 プロジェクト構成

```
.
├── .claude/                          # Claude Code 設定
│   ├── settings.json                 # セッション自動フック定義
│   ├── hooks/
│   │   └── on-session-start.sh      # セッション開始フック
│   └── skills/
│       └── docker-claude-setup/     # Docker セットアップスキル
├── docker-compose.yml                # Docker 開発環境定義
├── .dockerignore                     # Docker ビルド除外設定
├── .env.example                      # 環境変数テンプレート
├── scripts/
│   └── setup-claude-code.sh          # セットアップスクリプト
├── CLAUDE.md                         # プロジェクトコンテキスト（要編集）
└── README.md                         # プロジェクト説明（要編集）
```

---

## ⚙️ リソース設定

`.env` ファイルで環境に合わせてカスタマイズ：

```env
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

詳細は `.env.example` を参照してください。

---

## 📚 ドキュメント

- **CLAUDE.md** - プロジェクト全体のコンテキスト（セットアップ手順含む）
- **README.md** - プロジェクト説明（このテンプレートでは要編集）
- **.claude/skills/docker-claude-setup/README.md** - Docker スキル詳細ガイド

---

## 🎯 使用方法

### Docker コンテナでの開発

```bash
# コンテナ起動
docker-compose up -d claude

# コンテナに接続
docker-compose exec claude bash

# 通常の npm/Node.js コマンドが使用可能
npm install
npm run dev
```

### セッション自動初期化（デフォルト）

セッション開始時に自動で Docker セットアップが実行されます。

```bash
# または手動実行
/docker-claude-setup
./scripts/setup-claude-code.sh
```

### キャッシュクリア

```bash
# npm キャッシュをリセット
./scripts/setup-claude-code.sh clean
docker-compose up -d claude
```

---

## 🔧 カスタマイズ

### セッション開始フックを無効化

`.claude/settings.json` で `runImmediately` を `false` に：

```json
{
  "hooks": {
    "on_session_start": {
      "runImmediately": false
    }
  }
}
```

### Docker イメージを変更

`docker-compose.yml` で image を変更：

```yaml
services:
  claude:
    image: node:20-alpine  # 別のイメージに変更
```

---

## 📊 トラブルシューティング

**メモリ不足エラー**
```bash
# .env で NODE_MAX_MEMORY を減らす
NODE_MAX_MEMORY=256
docker-compose restart claude
```

**npm インストール遅延**
```bash
./scripts/setup-claude-code.sh clean
docker-compose up -d claude
```

**リソース使用状況確認**
```bash
docker stats yourwish-claude-code
```

**セッション開始フックが実行されない**
```bash
# 手動実行
./scripts/setup-claude-code.sh
```

---

## 📝 テンプレート準備チェックリスト

新規プロジェクト作成後、以下を完了してください：

- [ ] `CLAUDE.md` をプロジェクト説明に編集
- [ ] `README.md` をプロジェクト説明に編集
- [ ] `.env.example` で環境に合わせたデフォルト値を確認
- [ ] `docker-compose.yml` で `container_name` を変更（オプション）
- [ ] Git の初期化と最初のコミット
- [ ] GitHub にリポジトリをプッシュ

---

## 🎁 このテンプレートの特徴

✅ **ゼロ設定デプロイ** - `./scripts/setup-claude-code.sh` だけで完全セットアップ
✅ **自動初期化** - セッション開始時に自動で Docker 環境を整える
✅ **リソース効率** - 低スペック環境でも動作可能
✅ **再利用可能** - 複数プロジェクトで統一された開発環境
✅ **スキル統合** - Claude Code スキル機能で簡単に拡張可能

---

## 📖 関連リソース

- **元のリポジトリ**: https://github.com/zka32101/yourwish
- **Claude Code ドキュメント**: https://claude.ai/code
- **Docker ドキュメント**: https://docs.docker.com/

---

## 📄 ライセンス

MIT License - 自由に使用・改造・配布できます

---

**Happy coding with Claude Code! 🎉**
