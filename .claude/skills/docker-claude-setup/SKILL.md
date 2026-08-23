# docker-claude-setup

Claude Code Docker リソース節約セットアップスキル

## 説明

Docker コンテナで Claude Code を実行する際のセットアップ・リソース最適化を自動実行します。

このスキルは以下の機能を提供：
- Docker Compose セットアップの自動化
- リソース制限設定（環境に応じた最適値）
- npm キャッシュの最適化
- Claude Code CLI のインストール

## 使用方法

### 初回セットアップ

```bash
# スキル実行
/docker-claude-setup

# または直接スクリプト実行
./scripts/setup-claude-code.sh
```

### キャッシュクリア＆再セットアップ

```bash
./scripts/setup-claude-code.sh clean
```

### Docker コンテナ接続

```bash
docker-compose up -d claude
docker-compose exec claude bash
```

## 自動実行設定

セッション開始時に自動実行されるよう `.claude/settings.json` で設定可能：

```json
{
  "hooks": {
    "on_session_start": "cd /workspace && ./scripts/setup-claude-code.sh"
  }
}
```

## 設定ファイル

- **docker-compose.yml** - Docker コンテナ定義（リソース制限付き）
- **.env.example** - 環境変数テンプレート
- **scripts/setup-claude-code.sh** - セットアップスクリプト
- **CLAUDE.md** - プロジェクトドキュメント

## リソース設定

`.env` ファイルで環境に応じて調整：

```env
# 低スペック環境（2GB RAM）
NODE_MAX_MEMORY=256
CLAUDE_MEMORY_LIMIT=512M

# 中程度環境（4GB RAM）
NODE_MAX_MEMORY=512
CLAUDE_MEMORY_LIMIT=1G

# 高スペック環境（8GB以上）
NODE_MAX_MEMORY=1024
CLAUDE_MEMORY_LIMIT=2G
```

## トラブルシューティング

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

**リソース確認**
```bash
docker stats yourwish-claude-code
```

## 機能

- ✅ 自動セットアップ（ワンコマンド）
- ✅ リソース制限（ホストマシン保護）
- ✅ npm キャッシュ最適化
- ✅ 環境変数設定（環境適応）
- ✅ クリーンアップ機能
