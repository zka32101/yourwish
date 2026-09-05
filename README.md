# yourwish Monorepo

yourwish の各アプリをまとめて管理するモノレポです。
トップ（リポジトリルート）が全体を束ね、`apps/` 配下に各アプリ・
各ゲーム環境を1ディレクトリ = 1環境として何個でも追加していきます。

## 構成

```
apps/
  prefecture_defense/   # 日本領土ディフェンス（都道府県タワーディフェンス）
  sns_game_template/      # SNS配信（TikTok Liveなど）用ゲーム環境のテンプレート
  vote_survivor/    # 視聴者投票サバイバル（TikTok Live / 視聴者参加型）
  (今後、SNS配信用ゲームを含め、他アプリ/環境を追加していく想定)
packages/
  game_kit/       # SNS配信用ゲーム共通の部品（投票UI・ライブコメント受信など）
scripts/
  new_sns_game.sh          # 新しいSNS配信用ゲーム環境をコピー生成するスクリプト
```

### SNS配信用ゲーム環境

TikTok Live など、SNS配信で使うゲームは `apps/` 配下に環境を1つずつ
追加していく方針です。新規追加は次の1行でひな形を生成できます。

```bash
scripts/new_sns_game.sh <新しいゲーム名> "説明文"
```

投票UI・ライブコメント受信などの共通部分は `packages/game_kit/`
にまとまっており、各ゲームはそれに依存する形で実装します。
詳細な手順・規約は
[`docs/sns-live-game-environments.md`](docs/sns-live-game-environments.md)
を参照してください。1本目の環境として
[`apps/vote_survivor/`](apps/vote_survivor/README.md)
（視聴者コメント投票で進行が決まるサバイバルゲーム）を追加済みです。

## 🚀 ビルド方法（ローカル環境不要）

**最も簡単（Docker自動利用）:**

```bash
# Flutterアプリ全体をテスト
./scripts/build.sh flutter

# Android APK ビルド
./scripts/build.sh flutter:android

# Web ビルド
./scripts/build.sh flutter:web
```

**詳細ガイド:** [`docs/LOCAL_ENV_FREE_BUILD.md`](docs/LOCAL_ENV_FREE_BUILD.md)

前提条件：
- ✅ Docker がインストール済み
- ❌ Dart/Flutter SDK 不要
- ❌ Node.js ローカルインストール不要

## CI/CD

各アプリの GitHub Actions ワークフローは `.github/workflows/` に配置し、
`paths:` フィルタで該当アプリのディレクトリ変更時のみ起動するようにしています
（例: `<app>-ci.yml` が `apps/<app>/**` の変更時のみ起動）。

**自動デプロイワークフロー** (`.github/workflows/build-deploy.yml`):
- main/master へのプッシュで自動実行
- Lint → Test → Web ビルド → Android ビルド → デプロイ
- **ビルド時間: 約 8-10 分**

SNS配信用ゲームのCIは、共通の再利用可能ワークフロー
`.github/workflows/flutter-app-ci.yml`（analyze + test）を各アプリの
`<app>-ci.yml` から呼び出す形になっており、新規環境追加時のCI設定は
数行で済むようにしています。

macOS ランナー（iOS ビルド）は 10 倍課金のため、`workflow_dispatch`（手動実行）
または PR 時のみに限定し、通常の push では絶対に自動起動しない方針としています。
