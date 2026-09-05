# 🚀 ローカル環境不要ビルドガイド

このドキュメントは、ローカルに Dart/Flutter SDK をインストール**不要**で、すべてのビルドを **Docker内で完結** させる方法を説明します。

**前提条件:**
- Docker / Docker Desktop がインストールされていること
- Git がインストールされていること
- インターネット接続が利用可能なこと

---

## 📦 クイックスタート

### 1️⃣ 統一ビルドコマンド（最も簡単）

```bash
# リポジトリをクローン
git clone https://github.com/zka32101/yourwish.git
cd yourwish

# ビルド実行（Docker 自動起動）
./scripts/build.sh flutter

# ビルド完了！ 🎉
```

この1コマンドで以下が実行されます：
- ✅ Flutter 環境セットアップ
- ✅ 依存関係インストール
- ✅ コード分析（analyze）
- ✅ ユニットテスト実行

---

## 🐳 Docker を使用したビルド方法

### パターン1: ビルドコマンド（推奨）

```bash
# Flutterアプリ全体のテスト
./scripts/build.sh flutter

# 特定のアプリをビルド
./scripts/build.sh flutter:vote_survivor

# Android APK ビルド
./scripts/build.sh flutter:android

# Web ビルド
./scripts/build.sh flutter:web

# パッケージテスト
./scripts/build.sh packages

# キャッシュクリア
./scripts/build.sh clean
```

### パターン2: Docker Compose（フル環境）

```bash
# コンテナ起動（初回のみ数分）
docker-compose up -d claude

# コンテナ内に入る
docker-compose exec claude bash

# ビルド実行
cd /workspace
./scripts/build.sh flutter
```

### パターン3: Docker Run（直接実行）

```bash
# ビルドコマンド直接実行
docker run --rm -v $(pwd):/workspace \
  -w /workspace \
  cirrusci/flutter:3.24.0 \
  /bin/bash scripts/build.sh flutter
```

---

## 🏗️ プロダクション用Dockerイメージ

### Web 版をビルド

```bash
# イメージビルド（本番環境最適化）
docker build -t yourwish-web:latest -f Dockerfile.web .

# ローカルテスト実行
docker run -p 8080:80 yourwish-web:latest

# ブラウザで確認
open http://localhost:8080
```

### Android APK をビルド

```bash
# イメージビルド
docker build -t yourwish-android:latest -f Dockerfile.android .

# ビルド実行（APK を ./build に出力）
docker run --rm -v $(pwd)/build:/output \
  yourwish-android:latest \
  cp -r /output /output
```

---

## 🔄 CI/CD パイプライン（自動化）

プッシュ時に**自動でビルド・デプロイ**が実行されます。

### トリガー条件

```yaml
main / master ブランチへの Push → 自動ビルド
Pull Request 作成 → Lint + Test
```

### GitHub Actions ワークフロー

```bash
# ワークフロー確認
cat .github/workflows/build-deploy.yml

# ワークフロー手動実行（Web UI）
GitHub → Actions → Build & Deploy → Run workflow
```

### パイプラインステップ

| ステップ | 説明 | 時間 |
|---------|------|------|
| Setup | 環境準備 | ~10s |
| Lint | コード分析 | ~30s |
| Test | ユニットテスト | ~1min |
| Build Web | Web イメージビルド | ~2min |
| Build Android | Android APK ビルド | ~3min |
| Deploy | デプロイメント | ~1min |

**合計ビルド時間: 約 8-10 分**

---

## 📊 ビルドモード比較

| モード | ビルド時間 | サイズ | 推奨用途 |
|--------|-----------|--------|---------|
| **Debug** | ~2分 | 大（デバッグ情報含む） | 開発・デバッグ |
| **Release** | ~3分 | 小（最適化） | 本番環境・デプロイ |

```bash
# Debug モード
./scripts/build.sh flutter:android BUILD_MODE=debug

# Release モード（デフォルト）
./scripts/build.sh flutter:android BUILD_MODE=release
```

---

## 🎯 よくある使用例

### シナリオ1: ローカルで開発、CI で本番ビルド

```bash
# ✅ 開発環境（ローカルまたは Docker）
./scripts/build.sh flutter

# ✅ 本番環境（GitHub Actions で自動実行）
git push origin main
# → GitHub Actions で自動ビルド・デプロイ
```

### シナリオ2: 異なるプラットフォームでビルド

```bash
# Linux/Windows で Android ビルド
./scripts/build.sh flutter:android

# macOS のみ iOS ビルド
./scripts/build.sh flutter:ios

# 全プラットフォーム対応 Web ビルド
./scripts/build.sh flutter:web
```

### シナリオ3: 新しいアプリを追加

```bash
# 1. 新規アプリを scaffolding
./scripts/new_sns_game.sh my_new_game "説明文"

# 2. ビルド
./scripts/build.sh flutter:my_new_game

# 3. CI/CD に組み込み
# → .github/workflows/<app>-ci.yml に自動反映
```

---

## 🔧 トラブルシューティング

### ❌ Docker が見つからない

```bash
# Docker インストール確認
docker --version

# Docker Desktop のインストール
# macOS/Windows: https://www.docker.com/products/docker-desktop
# Linux: sudo apt install docker.io
```

### ❌ ビルドが遅い

```bash
# キャッシュをリセット
./scripts/build.sh clean

# Docker キャッシュをクリア
docker system prune -a

# メモリ制限を確認
docker stats
```

### ❌ メモリ不足エラー

```bash
# .env ファイルで Node.js メモリを削減
NODE_MAX_MEMORY=256

# Docker Desktop のメモリ割り当てを増加
# Settings → Resources → Memory: 4GB 以上推奨
```

### ❌ ネットワークエラー

```bash
# プロキシ設定を確認
echo $HTTP_PROXY $HTTPS_PROXY

# Docker ネットワークリセット
docker network prune
docker-compose down
```

---

## 📈 パフォーマンス最適化

### 1. ビルドキャッシュを活用

```bash
# キャッシュを保持（デフォルト）
docker build --cache-from=myimage:latest .

# キャッシュなし（完全リビルド）
docker build --no-cache .
```

### 2. 並列ビルド

```bash
# GitHub Actions は複数ジョブを並列実行
# ローカルで複数アプリをビルド
./scripts/build.sh packages &
./scripts/build.sh flutter &
wait
```

### 3. マルチステージビルド（イメージサイズ削減）

```bash
# ビルド環境（大）→ 実行環境（小）に圧縮
# Dockerfile のステージ1: builder
# Dockerfile のステージ2: runtime (Alpine Linux)

# イメージサイズ比較
docker images | grep yourwish
# REPOSITORY    TAG      SIZE
# yourwish-web  prod     85MB    ← 本番環境（最小化）
# yourwish-web  dev      500MB   ← 開発環境（デバッグ情報付き）
```

---

## 🌐 本番環境デプロイ

### Container Registry へ Push

```bash
# Docker Hub
docker login
docker tag yourwish-web:latest myusername/yourwish-web:latest
docker push myusername/yourwish-web:latest

# GitHub Container Registry (GHCR)
docker login ghcr.io
docker tag yourwish-web:latest ghcr.io/zka32101/yourwish-web:latest
docker push ghcr.io/zka32101/yourwish-web:latest
```

### Kubernetes へデプロイ（オプション）

```bash
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: yourwish-web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: yourwish-web
  template:
    metadata:
      labels:
        app: yourwish-web
    spec:
      containers:
      - name: yourwish-web
        image: ghcr.io/zka32101/yourwish-web:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

```bash
# デプロイ実行
kubectl apply -f deployment.yaml
kubectl get pods
```

---

## 📚 関連ドキュメント

- [`CLAUDE.md`](../CLAUDE.md) - プロジェクト概要
- [`docs/sns-live-game-environments.md`](sns-live-game-environments.md) - SNS配信ゲーム開発ガイド
- [Flutter 公式ドキュメント](https://flutter.dev/docs)
- [Docker 公式ドキュメント](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/en/actions)

---

## 🤝 サポート

質問や問題がある場合：

1. **GitHub Issues** で報告
2. **Discussion** で議論
3. **Wiki** でドキュメント確認

**著者**: yourwish チーム  
**更新**: 2026-09-05
