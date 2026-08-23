# Docker Claude Code セットアップスキル

Claude Code Docker リソース節約セットアップを自動化・再利用可能にするスキルです。

## 📋 機能

### 1. **自動スキル読み込み**
- `.claude/settings.json` で定義
- セッション開始時に自動実行
- 環境変数・リソース制限を自動設定

### 2. **セッション開始フック**
- `.claude/hooks/on-session-start.sh`
- Docker セットアップを自動実行
- ワンコマンド初期化

### 3. **新規プロジェクト用テンプレート生成**
- `setup-template.sh`
- 他のプロジェクトに設定を展開
- 再利用可能な構成

---

## 🚀 使用方法

### 現在のプロジェクト（yourwish）での利用

**セッション開始時に自動実行されます**

```bash
# または手動実行
/docker-claude-setup

# またはスクリプト直接実行
./scripts/setup-claude-code.sh
```

### 新規プロジェクトでテンプレート生成

```bash
# 他のプロジェクトでセットアップを使用する場合
bash .claude/skills/docker-claude-setup/setup-template.sh /path/to/new-project

# 生成されるファイル:
# - docker-compose.yml
# - .dockerignore
# - .env.example
# - scripts/setup-claude-code.sh
# - .claude/settings.json
# - .claude/hooks/on-session-start.sh
# - CLAUDE.md
# - .gitignore (更新)
```

### テンプレート生成後の手順

```bash
cd /path/to/new-project

# CLAUDE.md を編集
vi CLAUDE.md

# Docker セットアップ実行
./scripts/setup-claude-code.sh

# Docker コンテナ起動
docker-compose up -d claude
docker-compose exec claude bash
```

---

## 📁 ファイル構成

```
.claude/
├── settings.json                 # Claude Code 設定（自動フック定義）
├── hooks/
│   └── on-session-start.sh      # セッション開始フック
└── skills/
    └── docker-claude-setup/
        ├── SKILL.md              # スキル定義
        ├── README.md             # このファイル
        └── setup-template.sh     # テンプレート生成スクリプト

scripts/
└── setup-claude-code.sh          # セットアップスクリプト本体

docker-compose.yml               # Docker Compose 定義
.env.example                      # 環境変数テンプレート
.dockerignore                     # Docker ビルド除外
CLAUDE.md                         # プロジェクトコンテキスト
```

---

## ⚙️ 自動設定の詳細

### セッション開始時の自動実行フロー

```
セッション開始
    ↓
.claude/settings.json を読み込み
    ↓
on_session_start フック実行
    ↓
.claude/hooks/on-session-start.sh 実行
    ↓
./scripts/setup-claude-code.sh 実行
    ↓
✅ Docker セットアップ完了
```

### 自動設定される項目

- ✅ `.env` ファイル生成（存在しない場合）
- ✅ Docker ボリューム準備
- ✅ npm 最適化設定
- ✅ Claude Code CLI インストール
- ✅ セッション情報確認

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

### リソース設定を変更

`.env` ファイルを編集：

```env
# 低スペック環境
NODE_MAX_MEMORY=256
CLAUDE_MEMORY_LIMIT=512M

# 中程度環境
NODE_MAX_MEMORY=512
CLAUDE_MEMORY_LIMIT=1G

# 高スペック環境
NODE_MAX_MEMORY=1024
CLAUDE_MEMORY_LIMIT=2G
```

---

## 📚 関連ドキュメント

- **CLAUDE.md** - プロジェクト全体のコンテキスト
- **SKILL.md** - スキル定義（スキル一覧での表示内容）
- **scripts/setup-claude-code.sh** - セットアップスクリプト本体

---

## 🎯 ユースケース

### 1. 単一プロジェクト（yourwish）
```bash
# セッション開始時に自動実行
# 追加操作不要
```

### 2. 複数プロジェクト
```bash
# 各プロジェクトでテンプレート生成
bash ./skills/docker-claude-setup/setup-template.sh ~/project-a
bash ./skills/docker-claude-setup/setup-template.sh ~/project-b
bash ./skills/docker-claude-setup/setup-template.sh ~/project-c

# 各プロジェクトで自動セットアップが動作
```

### 3. 他の Claude Code セッション
```bash
# 別マシンでも同じセットアップを利用可能
git clone https://github.com/zka32101/yourwish.git
cd yourwish
# セッション開始時に自動実行される
```

---

## ✅ チェックリスト

### 初期セットアップ後の確認

- [ ] Docker コンテナが起動している
- [ ] Claude Code CLI がインストールされている
- [ ] npm キャッシュが有効化されている
- [ ] リソース制限が適用されている

```bash
# 確認コマンド
docker-compose up -d claude
docker-compose exec claude which claude-code
docker-compose exec claude npm config get cache
docker stats yourwish-claude-code
```

---

## 🐛 トラブルシューティング

**セッション開始フックが実行されない**
```bash
# 手動実行
./scripts/setup-claude-code.sh
```

**メモリ不足**
```bash
# .env で NODE_MAX_MEMORY を減らす
vi .env
docker-compose restart claude
```

**npm インストール遅延**
```bash
./scripts/setup-claude-code.sh clean
docker-compose up -d claude
```

---

## 📝 ライセンス

MIT License - このスキルは自由に使用・改造・配布できます。
