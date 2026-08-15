# Petit Works Apps Monorepo

Petit Works Apps の各アプリをまとめて管理するモノレポです。
トップ（リポジトリルート）が全体を束ね、`apps/` 配下に各アプリ・
各ゲーム環境を1ディレクトリ = 1環境として何個でも追加していきます。

## 構成

```
apps/
  geography_puzzle_king/   # 日本領土ディフェンス（都道府県タワーディフェンス）
  _template_sns_game/      # SNS配信（TikTok Liveなど）用ゲーム環境のテンプレート
  (今後、SNS配信用ゲームを含め、他アプリ/環境を追加していく想定)
```

### SNS配信用ゲーム環境

TikTok Live など、SNS配信で使うゲームは `apps/` 配下に環境を1つずつ
追加していく方針です。新規追加の手順・規約は
[`docs/sns-live-game-environments.md`](docs/sns-live-game-environments.md)
を参照してください。

## CI

各アプリの GitHub Actions ワークフローは `.github/workflows/` に配置し、
`paths:` フィルタで該当アプリのディレクトリ変更時のみ起動するようにしています
（例: `<app>-ci.yml` が `apps/<app>/**` の変更時のみ起動）。

macOS ランナー（iOS ビルド）は 10 倍課金のため、`workflow_dispatch`（手動実行）
または PR 時のみに限定し、通常の push では絶対に自動起動しない方針としています。
