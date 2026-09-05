# 🚀 yourwish ビルド環境 - セッション開始ガイド

このドキュメントは Claude Code セッション開始時に自動表示されます。

---

## ✨ セッション初期化完了

自動初期化フック (`on-session-start.sh`) が実行され、以下の準備が完了しました：

- ✅ Docker セットアップ
- ✅ ビルド環境初期化
- ✅ 依存関係チェック

---

## 🎯 すぐに使えるコマンド

### Flutter アプリをテスト

```bash
./scripts/build.sh flutter
```

**結果:**
- コード分析（analyze）実行
- ユニットテスト実行
- Docker 内で完全完結（ローカルSDK不要）

### Android APK をビルド

```bash
./scripts/build.sh flutter:android
```

### Web 版をビルド

```bash
./scripts/build.sh flutter:web
```

### パッケージのみテスト

```bash
./scripts/build.sh packages
```

---

## 📦 Docker で完全環境

### コンテナ起動

```bash
docker-compose up -d claude
```

### コンテナ接続

```bash
docker-compose exec claude bash
```

コンテナ内で任意のビルドコマンド実行可能：

```bash
cd /workspace
./scripts/build.sh flutter
```

---

## 📚 詳細ドキュメント

全機能の説明、トラブルシューティング、本番環境デプロイ手順：

```bash
cat docs/LOCAL_ENV_FREE_BUILD.md
```

---

## ✅ チェックリスト

- [ ] Docker がインストール済み（`docker --version`）
- [ ] リポジトリクローン済み（`git clone ...`）
- [ ] `./scripts/build.sh flutter` で初回テスト実行

---

## 🆘 トラブルシューティング

### Docker が見つからない

```bash
docker --version  # インストール確認

# インストール: https://www.docker.com/products/docker-desktop
```

### ビルドが遅い

```bash
./scripts/build.sh clean    # キャッシュリセット
docker system prune -a      # Docker全体クリア
```

### 詳細なエラーログ

```bash
cat docs/LOCAL_ENV_FREE_BUILD.md  # セクション: トラブルシューティング
```

---

## 🔗 関連リンク

- **プロジェクト概要**: `CLAUDE.md`
- **開発ガイド**: `docs/LOCAL_ENV_FREE_BUILD.md`
- **ビルドスクリプト**: `scripts/build.sh`
- **GitHub**: https://github.com/zka32101/yourwish

---

**🎉 ビルド環境の準備完了！アプリ開発をお楽しみください。**
