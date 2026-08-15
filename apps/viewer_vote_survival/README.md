# 視聴者投票サバイバル (viewer_vote_survival)

SNS配信（TikTok Live想定）向けの**視聴者参加型**ゲーム環境です。
`apps/_template_sns_game/` から作成した1本目のSNS配信用ゲームです。

## 配信先SNS

- TikTok Live（縦向き配信を想定）

## 操作方法（視聴者参加型）

- 一定時間ごとに画面上に2択の選択肢が表示される。
- 視聴者はライブコメントで `1` または `2` と投票する。
- 制限時間終了後、最多得票の選択肢が採用され、確率判定で
  「安全」か「ピンチ（HP減少）」かが決まる。
- HPが0になったら生存失敗、全ラウンドを生き延びれば生還成功。

## ゲーム内容

漂流島サバイバルがテーマ。全6ラウンド、各ラウンド2択、開始HPは3。
シナリオ内容は `lib/data/scenarios.dart` にあり、自由に差し替え・追加できる。

## TikTok Live連携について（現状はモック）

現時点では実際のTikTok Live APIとの連携は行っておらず、
`lib/services/live_comment_service.dart` の `MockLiveCommentService` が
ランダムに投票コメントを生成して動作確認できるようにしている。

実際にTikTok Liveのコメントを取り込むには、`LiveCommentService` を実装した
`TikTokLiveCommentService`（仮）を作成し、`LiveGameScreen` 内の
`MockLiveCommentService()` の生成箇所を差し替えるだけでよい
（ゲームロジック側の変更は不要な設計にしている）。

## ローカルでの実行

```bash
cd apps/viewer_vote_survival
flutter pub get
flutter run
```

## テスト

```bash
cd apps/viewer_vote_survival
flutter analyze
flutter test
```
