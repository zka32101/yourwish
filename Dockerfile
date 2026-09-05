# マルチステージビルド: ローカル環境不要でアプリをビルド・実行
#
# 使用例:
#   # 開発イメージ（キャッシュ付き、デバッグ可能）
#   docker build -t yourwish:dev --target builder .
#
#   # 本番イメージ（最小化、実行のみ）
#   docker build -t yourwish:prod -f Dockerfile .
#
#   # ビルドの実行
#   docker run --rm -v $(pwd):/workspace -w /workspace yourwish:dev /scripts/build.sh flutter
#
#   # Webサーバー起動
#   docker run -p 8080:8080 yourwish:prod

# ========================
# ステージ1: ビルド環境
# ========================
FROM cirrusci/flutter:3.24.0 as builder

LABEL maintainer="yourwish-team"
LABEL description="Unified build environment for Flutter apps (Node.js + Flutter + Dart)"

# 作業ディレクトリ設定
WORKDIR /workspace

# システムパッケージ更新
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    bash \
    jq \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Node.js インストール（TypeScript バックエンド対応）
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# npm グローバル設定（オフラインモード、キャッシュ優先）
RUN npm config set prefer-offline true && \
    npm config set audit false && \
    npm install -g @anthropic-ai/claude-code 2>/dev/null || true

# ビルドスクリプトをコピー
COPY scripts /workspace/scripts
RUN chmod +x /workspace/scripts/*.sh

# ビルドキャッシュ用ボリュームマウントポイント
VOLUME ["/workspace/.build-cache", "/root/.pub-cache", "/root/.gradle"]

# デフォルトコマンド
CMD ["/bin/bash"]

# ========================
# ステージ2: Flutter Web ランタイム環境
# ========================
FROM nginx:alpine as flutter-web

LABEL maintainer="yourwish-team"
LABEL description="Flutter Web app runtime (nginx)"

# デフォルトのnginx設定を削除
RUN rm /etc/nginx/conf.d/default.conf

# カスタムnginx設定
COPY << 'EOF' /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name _;

    # キャッシュ設定
    client_max_body_size 20M;

    # SPA ルーティング
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;

        # キャッシュ制御
        add_header Cache-Control "public, max-age=3600";
    }

    # アセット（JS/CSS）キャッシュ（長期）
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        root /usr/share/nginx/html;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # ヘルスチェックエンドポイント
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# ビルド成果物をコピーするための前提（マルチステージビルドで使用）
WORKDIR /usr/share/nginx/html

# デフォルトでサーブするポート
EXPOSE 80

# ========================
# ステージ3: Node.js バックエンド環境
# ========================
FROM node:20-alpine as node-app

LABEL maintainer="yourwish-team"
LABEL description="Node.js backend runtime"

WORKDIR /app

# システムパッケージ
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates

# npm オフラインモード設定
RUN npm config set prefer-offline true && \
    npm config set audit false

# アプリケーション実行用ユーザー
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

EXPOSE 3000

CMD ["node", "dist/index.js"]

# ========================
# ステージ4: Android/iOS ビルド環境（オプション）
# ========================
FROM cirrusci/flutter:3.24.0 as android-builder

LABEL maintainer="yourwish-team"
LABEL description="Android APK builder"

WORKDIR /workspace

# Java SDK + Gradle キャッシュボリューム
VOLUME ["/root/.gradle", "/workspace/.build-cache"]

CMD ["/bin/bash"]

# ========================
# ステージ5: 本番環境統合イメージ
# ========================
FROM alpine:3.18 as prod

LABEL maintainer="yourwish-team"
LABEL description="Minimal production image (multi-platform support)"

RUN apk add --no-cache \
    ca-certificates \
    curl \
    bash \
    openssh-client \
    git

WORKDIR /app

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

CMD ["/bin/sh"]

# ========================
# 注記
# ========================
# ビルド手順:
# 1. ビルド環境でコンパイル
#    docker run --rm -v $(pwd):/workspace builder /workspace/scripts/build.sh flutter
#
# 2. Web版をデプロイ
#    docker build -t yourwish-web:latest \
#      --build-arg APP_PATH=apps/vote_survivor \
#      -f Dockerfile.web .
#
# 3. バックエンド実行
#    docker build -t yourwish-api:latest \
#      --build-arg BACKEND_PATH=packages/backend \
#      -f Dockerfile.backend .
