# オーケストレーターセッションの仕組み

**管理セッション**: `yourwish`(このリポジトリ)
**役割**: 複数アプリの Claude Code Remote セッションを横断的に監視・調整する司令塔

> 📌 **このドキュメントは生きた記録です。** 新しい失敗パターン・落とし穴・運用ルールが判明するたびに、下記の該当セクション(「重要な教訓」「既知の問題」など)に追記していきます。過去の記録は消さず積み上げ、同じ問題を二度調査しなくて済むようにすることが目的です。オーケストレーターセッションを引き継ぐ場合は、まずこのファイルに目を通してください。

## 🏗️ アーキテクチャ

```
yourwish (オーケストレーター/管理セッション)
├── 各アプリの状態を list_sessions で監視
├── ブロッカー(権限承認待ち・壊れた依存URL・Secret未設定など)を検知して介入
├── create_trigger / create_session で各アプリセッションに指示を送る
└── 共通パッケージ(shared_core, cross_promo_kit)のインフラ的な不具合を修正
        ↓
各アプリの「ビルド修正」セッション(独立した Claude Code Remote セッション)
├── 国語 (kokugo-kore)
├── 算数 (sansu-kore)
├── 社会 (social_quiz_app)
├── 理科 (newrepo)
├── 英語 (eigo)
├── プログラミング (shogaku-kore-programming)
├── 心身 (shinshin)
├── 近場コレ (chikaba_kore)
├── 星座コレ (seiza_kore)
├── 漢検 (kanken)
├── bike
└── ご縁 (goen)
  各セッションが自分のリポジトリで独立して:
  ✅ CI 状態確認 → 失敗ならログ調査・修正 → push → 再確認 のループを自走
```

## 🎯 役割分担の原則

| 担当 | 内容 |
|------|------|
| **各アプリセッション** | CI/ビルド失敗の詳細調査・コード修正・再ビルドは基本的にここで完結させる |
| **オーケストレーター** | 個別セッションでは解決できない**インフラ的な問題**にのみ介入する:<br>・複数リポジトリ共通の権限承認ブロック(`send_later`, `subscribe_pr_activity` など)<br>・共通パッケージ(shared_core / cross_promo_kit)の壊れた依存URL<br>・GitHub Secret 未設定など、コードでは直せない要因<br>・セッションが本来のミッションから逸れた(スコープドリフト)場合の立て直し |

オーケストレーターは基本的に**深いログ調査をしない**。各セッションの `post_turn_summary` と GitHub Actions の概況(green/red)だけを見て、明らかなブロッカーがあれば対処する。

## 🔁 対応優先順位(小学コレシリーズ)

1. 国語 (kokugo-kore)
2. 算数 (sansu-kore)
3. 社会 (social_quiz_app)
4. 理科 (newrepo)
5. 英語 (eigo)
6. プログラミング (shogaku-kore-programming)
7. 心身 (shinshin)

(近場コレ・星座コレは別シリーズのため優先度低)

## 🆕 追加ビルド対象アプリ(小学コレシリーズ外)

2026-09-07: 漢検(kanken)・bike・ご縁(goen) をビルド修正対象に追加。3アプリとも `.github/workflows/` が未整備(kanken は firebase-import.yml のみ、bike/goen はワークフローなし)だったため、各セッションに既存アプリのAndroidビルドワークフローを参考にした**新規整備**を依頼済み。優先度は上記シリーズより低く、各セッションからのインフラブロッカー報告(Secret未設定等)を待つ。

## 🔧 権限設定(承認プロンプト削減)

各アプリリポジトリの `.claude/settings.json`(コミット対象、チーム共有)に以下を追加済み:

```json
{
  "permissions": {
    "allow": [
      "mcp__Claude_Code_Remote__create_trigger",
      "mcp__Claude_Code_Remote__create_session",
      "mcp__Claude_Code_Remote__list_sessions",
      "mcp__Claude_Code_Remote__send_later",
      "mcp__Claude_Code_Remote__subscribe_pr_activity",
      "mcp__Claude_Code_Remote__unsubscribe_pr_activity",
      "... (他 Claude_Code_Remote 系ツール)"
    ]
  }
}
```

**⚠️ 既知の落とし穴**: `.claude/settings.json`(または `settings.local.json`)を**稼働中のセッションが起動した後に**リポジトリへコミットしても、そのセッションには即座に反映されない。設定変更は「次回そのリポジトリでセッションを新規作成した時」から有効になる。稼働中のセッションが権限待ちで止まっている場合は:
- そのセッションに「そのツールを使わず今のタスクを直接進めて」と回避指示を送る、または
- 新しいセッションを作り直して引き継ぐ(設定は即座に反映される)

## 🚨 重要な教訓: 「CI green ≠ 成果物あり」

### 何が起きたか(2026-09-07, eigo アプリ)

eigo のビルド修正セッションが「Run 14 ✅ 完了: signed APK/AAB builds, artifacts saved」と報告したが、実際に GitHub Actions のアーティファクトを確認すると **`build-logs`(625バイト、ログのみ)しか存在せず、APK/AAB 本体は一切アップロードされていなかった**。

### 根本原因

```yaml
flutter build apk --release \
  --release-build-signing-keystore-path=android/release.keystore \
  ... \
  | tee build_apk.log
```

1. `--release-build-signing-keystore-path` は **Flutter に存在しないオプション** で、`flutter build apk` / `flutter build appbundle` が即座に `exit code 64` で失敗していた
2. しかし `| tee build_apk.log` のように**パイプにつないでいたため、シェルの終了コードは `tee`(常に成功)のものになり、flutter build の失敗が握りつぶされていた**
3. 結果、ジョブ全体は "success" と表示され、後続の "Upload artifacts" ステップも実行されたが `No files were found with the provided path` という警告を出しただけで、誰もそれに気づかなかった

### なぜ見逃されたか

- ビルド修正セッションは GitHub Actions の**ジョブ結果(conclusion: success/failure)だけ**を見て判断し、**アーティファクトの中身(実際にファイルが存在するか)を確認していなかった**
- `| tee` のような exit code を隠すパターンは、レビューでもログの最後だけを見ると気づきにくい

### 再発防止のためのチェックリスト(全アプリ共通)

CI が "success" と表示されても、以下を必ず確認してから「完了」と報告すること:

- [ ] **アーティファクト一覧**(`list_workflow_run_artifacts` 相当、または Actions タブの Artifacts 欄)に、ログだけでなく **APK/AAB 本体のアーティファクトが実在する** ことを確認する
- [ ] "Upload artifacts" ステップのログに `No files were found with the provided path` のような**警告が出ていない**ことを確認する
- [ ] シェルコマンドを `| tee` や `| grep` などにパイプする場合は、**先頭に `set -o pipefail` を入れる**か `${PIPESTATUS[0]}` で実コマンドの終了コードを確認する。パイプの終了コードは既定では最後のコマンドのものになり、実際に実行したいコマンド(flutter build 等)の失敗を隠してしまう
- [ ] 新しい CLI オプションを workflow に追加するときは、**そのバージョンの `flutter build -h` で実在するオプションか確認**してから使う
- [ ] 「ビルドが green になった」＝「タスク完了」ではなく、**目的の成果物(APK/AAB/テスト結果など)が実際に生成されたことを一次データで確認**してから完了報告する

## 🚨 重要な教訓その2: 「アップロード成功ログ ≠ 実際にファイルがある」

### 何が起きたか(2026-09-07, seiza_kore アプリ)

seiza_kore のビルド修正セッションが「Google Drive アップロード成功(APK 27.9MB / AAB 57.3MB)」と報告したが、ユーザーが実際に Google Drive の APK フォルダを確認したところ、**ファイルが見当たらなかった**。

「CI green ≠ 成果物あり」と同じ構造の問題が、GitHub Actions の外(Google Drive のような外部サービスへのアップロード)でも起こりうることが判明した。アップロードスクリプトの exit code や「アップロード成功」のログ表示だけでは、**実際に意図した場所にファイルが届いたかは保証されない**(フォルダID違い、権限不足で別の場所に保存された、レスポンスを正しく検証していない、等の可能性がある)。

### 再発防止のためのチェックリスト(外部サービスへのアップロード全般)

- [ ] アップロード先の ID・パス(Google Drive フォルダID等)が正しい意図した場所を指しているか確認する
- [ ] アップロード API のレスポンスに実際の成功情報(ファイルID等)が含まれているか確認し、HTTPステータス/exit codeだけで判断しない
- [ ] 権限(サービスアカウント等)がアップロード先への書き込み権限を実際に持っているか確認する
- [ ] **アップロード後に、対象の場所を list/get 系の API で読み返して実在を確認する**(書き込みだけでなく読み出しでも検証する)

## 📦 shared_core / cross_promo_kit に関する既知の問題と修正

- `shared_core` の `pubspec.yaml` が `cross_promo_kit` を古い組織アカウント(`org-zka32101/cross_promo_kit`)の git URL で参照しており解決不能だった → `zka32101/cross_promo_kit`(個人アカウント)に修正済み(shared_core commit `bd9660c`)
- 併せて `shared_core` の `environment.sdk` を `cross_promo_kit` が要求する `^3.9.0` に合わせて修正済み
- 同様のパターン(リポジトリが組織アカウントから個人アカウントへ移動しており、依存参照が古いまま)は他にも起こりうるため、`pub get` で依存関係が静かにドロップされている・`.dart_tool` のエラーが出る場合はまずこれを疑うこと

## 📜 運用ルール一覧(随時追加)

判明した運用ルールをここに追記していく。詳しい経緯は各セクション(教訓・既知の問題)を参照。

1. CI が green でも、目的の成果物(APK/AAB等)が実在するかを一次データで確認してから「完了」と報告する(詳細: 「重要な教訓」参照)
2. `.claude/settings.json` の変更は、稼働中のセッションには即時反映されない。ブロックされたセッションは回避指示 or 再作成で対応する
3. `pub get` で依存関係が静かにドロップされる・`.dart_tool` エラーが出る場合は、まず git dependency の URL(組織アカウント→個人アカウント移動など)が壊れていないか疑う
4. シェルコマンドを `| tee` 等にパイプする場合は `set -o pipefail` を必須にする(実コマンドの失敗が握りつぶされないように)
5. 外部サービス(Google Drive等)へのアップロードも、「成功ログが出た」だけでなく **アップロード後に list/get で実在を読み返して確認**する(詳細: 「重要な教訓その2」参照)
6. ユーザー対応待ち(GitHub Secret再登録など)で保留中のアプリは、毎時の定期進捗確認の対象から外し、別ルーティンで1日1回のみ確認する(頻繁に確認しても状況が変わらないため)。毎時ルーティン: `trig_017FkDU6pc5FsBTxH8Xs2npx` / 保留アプリ用1日1回ルーティン: `trig_01V3YaPRPgP8VQZCW9wrzvyk`

## 🗓️ 失敗・インシデント記録(随時追加)

新しい失敗が判明した際は、日付・アプリ名・症状・原因・対応を1エントリとして追記する。

### 2026-09-07: eigo — CI green なのに APK/AAB 未生成
詳細は「重要な教訓」セクション参照。原因: 存在しない Flutter CLI オプション + `| tee` によるexit code握りつぶし。

### 2026-09-07: seiza_kore — Google Drive アップロード成功ログなのに実ファイルなし
詳細は「重要な教訓その2」セクション参照。原因: アップロードスクリプトが成功ログを出していたが、実際のフォルダにファイルが存在するかは検証していなかった(具体的な根本原因はセッション側で調査中)。

### 2026-09-06〜07: shared_core → cross_promo_kit の依存URL切れ
詳細は「shared_core / cross_promo_kit に関する既知の問題」セクション参照。原因: リポジトリが org-zka32101 から zka32101 個人アカウントへ移動したが、依存参照が更新されていなかった。

### 2026-09-07: kokugo-kore(国語) — 公開済みだが Google Play 検索に出てこない(調査中)
**症状**: 1週間以上前に Production(製品版)公開済み・直接リンクは開けるが、Play ストア検索に出てこない。

**除外できた要因**(スクリーンショットで確認済み):
- リリーストラック: 製品版が「有効」でステータス正常(非公開トラックの誤りではない)
- 国/地域ターゲティング: 「日本」が正しく単独でターゲット設定済み(誤設定ではない)

**残る手がかり**: Play Console が明示的に警告 「アプリの最適化がしきい値を下回っています — 難読化 11%(閾値 25%)— Google Playでの認知度や公開機能に影響する可能性」。
`android/app/build.gradle.kts` は `isMinifyEnabled = true` / `isShrinkResources = true` 済みだが、`proguard-rules.pro` に `-keep class io.flutter.** { *; }` 等、パッケージ丸ごとの広範な `-keep` ルールが多数(Flutter, Firebase/GMS, Play Billing, Kotlin/Kotlinx, Play Core, AdMob)あり、これが Java/Kotlin 側クラスの大半を難読化対象外にしている可能性が高い(Flutter アプリは Dart ロジックがネイティブコンパイルされるため、そもそも Java 側クラスの大半がサードパーティSDKで占められやすい構造的な弱点でもある)。

**対応**: 今のリリース(16/1.4.2)はそのまま維持し、次リリースに向けて kokugo-kore のビルド修正セッションに `proguard-rules.pro` の過剰な `-keep` の見直し(特に `kotlin.**`/`kotlinx.**`/`io.flutter.plugins.**` を必要最小限に)を依頼(trigger `trig_01BgZvcAhVbXjGkx1fPNJJEX`)。

**注意**: 難読化率警告は「影響する可能性がある」という表現に留まり、検索非表示の断定的な原因とは限らない。ストア掲載情報(タイトル/説明文のキーワード)・審査系設定(コンテンツレーティング/データセーフティ)未完了なども並行して確認中。他アプリでも同種の「公開済みなのに検索に出ない」報告があれば、まずこのチェックリスト(①トラック ②国設定 ③難読化率 ④ストア掲載情報のキーワード ⑤審査系設定の完了)から潰すこと。

## 🔗 関連ドキュメント

- [`docs/android-emulator-testing.md`](./android-emulator-testing.md) — Android Emulator テスト環境
- [`docs/LOCAL_ENV_FREE_BUILD.md`](./LOCAL_ENV_FREE_BUILD.md) — ローカル環境不要ビルド
- `.claude/skills/orchestrator/SKILL.md` — オーケストレータースキルの詳細な運用ルール

---

**作成日**: 2026-09-07
**管理セッション**: yourwish (orchestrator, session_01EpWdM7CVRG7rwgrAPuUfML)
