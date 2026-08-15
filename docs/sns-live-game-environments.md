# SNS配信用ゲーム環境の作り方

TikTok Live / Instagram Live / YouTube Shorts など、SNS配信で使うことを
想定したゲームを、このモノレポに**何個でも**追加していくための規約です。
楽に増やせるように、共通パッケージ・共通CI・スキャフォールドスクリプトを
用意しています。

## 基本方針

- 配信用ゲームも通常のアプリと同様に、1ゲーム = 1環境 = `apps/` 直下の
  1ディレクトリとして追加します（既存の `apps/geography_puzzle_king/` と同じ扱い）。
- 各環境は独立したFlutterプロジェクトですが、投票UI・ライブコメント受信などの
  共通部分は `packages/sns_live_game_kit/` に切り出してあり、そこに依存する形で
  実装します（毎回ゼロから書かない）。
- 「トップ（リポジトリのルート）」は環境を束ねる場所であり、ゲーム固有の
  ロジックは一切置きません。ルートに置くのは、規約・テンプレート・
  共通パッケージ・共通CI設定のみです。

```
yourwish/                        # トップ（リポジトリルート）
├── README.md                    # 環境一覧・全体構成の説明
├── docs/
│   └── sns-live-game-environments.md   # この規約
├── scripts/
│   └── new_sns_game.sh          # 新規環境をコピー生成するスキャフォールドスクリプト
├── packages/
│   └── sns_live_game_kit/       # 共通部品（投票サービス・HP表示・投票バー等）
├── apps/
│   ├── geography_puzzle_king/   # 既存アプリ（配信対象ではない通常ゲーム）
│   ├── _template_sns_game/      # 新規SNS配信用ゲームのひな形（スクリプトが使う）
│   ├── <sns_game_1>/            # SNS配信用ゲーム環境 #1 (viewer_vote_survival)
│   ├── <sns_game_2>/            # SNS配信用ゲーム環境 #2
│   └── ...                      # 以降、何個でも追加していく
└── .github/workflows/
    ├── flutter-app-ci.yml       # 共通の再利用可能CI（analyze + test）
    ├── <app>-ci.yml             # 各環境の薄いCI（flutter-app-ci.yml を呼ぶだけ）
    └── ...
```

## 新しいSNS配信用ゲーム環境を追加する手順（スクリプト利用・推奨）

```bash
scripts/new_sns_game.sh <新しいゲーム名> "説明文"
# 例: scripts/new_sns_game.sh quiz_battle_live "視聴者投票で答えを決めるクイズ配信ゲーム"
```

これで以下が自動生成されます。

- `apps/<新しいゲーム名>/`（テンプレートのコピー、`pubspec.yaml` の name/description 済み）
- `apps/<新しいゲーム名>/README.md`（配信先SNS・操作方法を書く欄だけ空いた状態）
- `.github/workflows/<新しいゲーム名>-ci.yml`（`flutter-app-ci.yml` を呼ぶ薄いCI）

その後、手動でやることは以下だけです。

1. `apps/<新しいゲーム名>/lib/main.dart` を実装する。
   `package:sns_live_game_kit` の部品を組み合わせるのが基本方針。
   - `LiveCommentService` / `MockLiveCommentService` — ライブコメント投票の受け口
   - `VoteScenario` / `VoteChoice` — 選択肢と成功確率のデータモデル
   - `LivesRow` — HP・残機のハート表示
   - `VoteBarList` — 選択肢ごとの得票数・得票率バー
   - `CommentTicker` — 直近のコメントを流す表示
   - 画面が視聴者に見えることを前提に、**縦向き配信 or 横向き配信**の
     どちらを基準にするかを最初に決める（TikTok Liveは縦向きが基本）。
   - 視聴者コメント・ギフトなどの外部入力を受け付ける場合は、
     `LiveCommentService` を実装したゲーム固有のクラス
     （例: `TikTokLiveCommentService`）を作り、`MockLiveCommentService()` の
     生成箇所を差し替える。ゲーム画面側のロジックは変更不要になる設計。
2. `apps/<新しいゲーム名>/README.md` の配信先SNS・操作方法（配信者操作 or
   視聴者参加型か）を埋める。
3. ルートの `README.md` の環境一覧に追記する。

## 手動で作る場合の手順（スクリプトを使わない場合）

1. `apps/_template_sns_game/` を `apps/<新しいゲーム名>/` としてコピーする
   （ゲーム名はスネークケース）。
2. `pubspec.yaml` の `name:` / `description:` を書き換える。
3. `.github/workflows/_template_sns_game-ci.yml` を
   `.github/workflows/<新しいゲーム名>-ci.yml` としてコピーし、
   ファイル内の `_template_sns_game` を新しいゲーム名に置換する。
4. 上記「スクリプト利用」手順の1〜3と同じ作業を行う。

## 共通パッケージ (`packages/sns_live_game_kit`) に何を足すべきか

- **複数のゲームで再利用できそうなUI・ロジック**はここに追加する
  （例: 新しい投票形式、演出用アニメーション、SNS共通の配信メタ情報表示）。
- **特定のゲームにしか使わないロジック**は各 `apps/<ゲーム名>/` 側に置く。
- 実際のTikTok Live APIなど、SNS側との本番連携クラスも複数ゲームで
  使い回せるなら `sns_live_game_kit` 側に追加するのが望ましい
  （`LiveCommentService` を実装する形で）。

## 環境を横断する共通ルール

- 各環境の依存関係・バージョンは環境ごとに独立して管理する
  （`sns_live_game_kit` へのpath依存を除き、パッケージ管理は共有しない）。
- macOSランナー（iOSビルド）を使うCIは、ルートREADME記載の方針どおり
  手動実行またはPR時限定とし、通常pushでは起動しない。
- 環境数が増えても、ルート直下の構成（README / docs / scripts / packages /
  apps / .github）は変えず、常に `apps/` 配下にディレクトリを追加する形で
  拡張する。
