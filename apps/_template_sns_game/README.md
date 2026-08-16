# _template_sns_game（テンプレート）

SNS配信（TikTok Live など）向けゲーム環境を新規に追加するためのひな形です。
**このディレクトリ自体はビルド対象ではありません。**

新しいゲームを作る際は、リポジトリルートで以下を実行するのが最も簡単です。

```bash
scripts/new_sns_game.sh <新しいゲーム名> "説明文"
```

（手動でコピーする場合の手順は
[`docs/sns-live-game-environments.md`](../../docs/sns-live-game-environments.md)
を参照してください。）

## このテンプレートに含まれるもの

- `pubspec.yaml` — Flutterプロジェクトの最小構成
  （`packages/sns_live_game_kit` への依存が最初から入っている）
- `lib/main.dart` — `sns_live_game_kit` の `LivesRow` / `CommentTicker` を
  使った最小限のプレースホルダー実装

## 想定している配信ゲームの型

- **配信者操作型**: 配信者がその場でプレイし、画面を配信する。
- **視聴者参加型**: コメント・ギフトなど視聴者からの入力をゲームに反映する
  （SNS側APIとの連携部分は環境ごとに個別実装する）。

どちらの型かは `README.md`（コピー後にゲームごとに書き換えるもの）に明記してください。
