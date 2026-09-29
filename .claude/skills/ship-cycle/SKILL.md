---
name: ship-cycle
description: 開発→テスト→リリース準備を低リソースで自動実行する3段階パイプライン。Flutterアプリ/パッケージ（小学コレシリーズ・shared_core・yourwish apps）の改修後、PR作成前、CI失敗の予防、リリース前チェックで使う。「チェックして」「テストして」「リリース準備」「PR前確認」「CI落ちないか見て」でトリガー。
---

# ship-cycle — 開発・テスト・リリース準備の自動化

過去の CI 失敗・ビルド失敗の根本原因を**安い順**に検出する。
高コストな処理（Flutter SDK / build_runner / APK ビルド）は、安い段階が通った時だけ・必要な時だけ実行する。

## 使い方

```bash
S=.claude/skills/ship-cycle
bash $S/preflight.sh [dir]      # Stage 1: 静的チェック（Flutter不要・数秒）
bash $S/verify.sh [dir]         # Stage 2: pub get / codegen / analyze / test（変更パッケージのみ）
bash $S/release-prep.sh [dir]   # Stage 3: リリース準備レポート（RELEASE_REPORT.md 生成、store-check 込み）
bash $S/store-check.sh [dir]    # ストア登録・アップロード・広告/課金ポリシーで弾かれる設定を確認
bash $S/device-check.sh <app> [apk] [秒]  # 実機テスト（Windows ローカル + USB 実機。logcat 自動判定）
bash $S/ship.sh [dir]           # 1→2→3 を順に実行し、最初の失敗で停止
```

- `dir` 省略時はカレント。モノレポでは `apps/*` `packages/*` のうち **git 差分がある pubspec 単位だけ** を対象にする（`ALL=1` で全件）。
- 終了コード: 0=OK / 1=ブロッカーあり。警告は止めない。
- 環境変数: `BASE=<ref>`（差分基準。省略時は origin の既定ブランチを自動判定）, `ALL=1`, `SKIP_TEST=1`, `OFFLINE=1`（`pub get --offline` 優先）

## 環境別の使い分け

方針の正本は **shared_core `docs/DEV_PLAYBOOK.md`**（役割分担・マネタイズ・セキュリティ）と
**`docs/DEVICE_TEST_POLICY.md`**（実機テスト: L0〜L6 のレベル、全画面ツアー、連携マトリクス、異常系、合否基準）。
リリース前は同ポリシーの流れ（L0/L1 → 内部テスト/TestFlight → L2〜L4 をストア配信版で → 段階公開）に従い、結果を §9 の形式で PR/Issue に残す。

| 環境 | 実行するもの |
|---|---|
| クラウド Code | `preflight` → `store-check`（SDK なし）→ PR → CI に analyze/test を任せる |
| Windows ローカル（Git Bash） | `ship.sh`（verify 含む）→ `flutter build apk --release` → `device-check.sh` → 結果を PR/Issue にコメント |

## Claude の実行手順（自動運用）

1. 改修後、**必ず Stage 1 から**。ブロッカーが出たら直してから次へ（Flutter を起動する前に潰す）。
2. Stage 2 は Flutter SDK がある環境のみ。無ければ Stage 1 の結果だけで PR を作り、CI に委ねる（SDK を新規インストールしない＝低リソース）。
3. Stage 2 で codegen 差分が出たら生成物をコミットに含める（`.freezed.dart` / `.g.dart` は**コミット対象**）。
4. リリース前は Stage 3。`RELEASE_REPORT.md` の ❌ を 0 にしてから PR 本文に要約を貼る。
5. 失敗を直したら**同じ Stage を再実行して green を確認**してから push（speculative push をしない）。
6. 自動修正してよいもの（確認不要）: version/build 番号の繰り上げ、versionCode/CFBundleVersion を Flutter 変数化、targetSdk/compileSdk/minSdk の引き上げ、PrivacyInfo.xcprivacy・Info.plist の権限説明文・ITSAppUsesNonExemptEncryption の追加、CI の Flutter/Xcode バージョン更新（更新後にビルドが通ることを CI で確認）。
7. ユーザーに依頼するもの: applicationId/Bundle ID の決定（公開後は変更不可）、ストア公開、Secrets・署名鍵、Firebase SHA-1 登録、Play Console/App Store Connect の申告。
8. ストア公開・Secrets 登録・署名鍵作成はユーザー作業。レポートの「ユーザー作業」欄に列挙するだけで止まらない。

## 検出する既知の失敗パターン（実績ベース）

| # | パターン | 過去事例 | Stage |
|---|---|---|---|
| P1 | `part 'x.freezed.dart'/'x.g.dart'` の生成物欠落 | Phase 4.20 で全7アプリCI失敗 | 1 |
| P2 | `@freezed`/`@JsonSerializable` 使用なのに `freezed_annotation`/`json_annotation`/`build_runner` 依存なし | shared_core #42, yourwish #61 | 1 |
| P3 | `FirebaseFirestore.instance` 等をフィールド初期化子/トップレベルで参照 | 起動時クラッシュ shared_core #57 | 1 |
| P4 | `'current_user'` 等のハードコード UID | shared_core #52 | 1 |
| P5 | `pubspec.yaml` の assets 宣言先が存在しない / `lib/` 抜け | shared_core #69 | 1 |
| P6 | `applicationId` と `google-services.json` の `package_name` 不一致 | APKビルド失敗 | 1 |
| P7 | `flutter test` 対象の `test/` 無し・テンプレのままの widget_test | shared_core #48, yourwish #61 | 1 |
| P8 | GitHub Actions のサードパーティ Action が SHA 未固定 | shared_core #49 | 1(警告) |
| P9 | macOS ランナーが push トリガーで動く（10倍課金） | CLAUDE.md 方針 | 1 |
| P10 | 秘密情報のコミット（`goog_`/`appl_`/`AIza`/秘密鍵/keystore） | secure-secrets 方針 | 1 |
| P11 | 1x1 などのダミーアプリアイコン | yourwish 64dc6c1 | 1(警告) |
| P12 | 古い組織 URL `org-zka32101` | shared_core #54 | 1 |
| P16 | 共有パッケージで依存をメジャー更新（依存元アプリと衝突） | shared_core #70 以降 verify-all-apps 全滅 | 1(警告) |
| P13 | stale な `pubspec.lock` / `.dart_tool` による依存解決ズレ | yourwish 29bc4f1 | 2 |
| P14 | codegen 後に生成物差分が出る（コミット漏れ） | shared_core ddaf584 | 2 |
| P15 | version 未更新 / CHANGELOG 未記載 / 署名設定欠落 | リリース前 | 3 |

### ストア登録・アップロードエラー（`store-check.sh`、要件値は `store-rules.env`）

| # | 検出内容 | 起きるエラー |
|---|---|---|
| S1 | targetSdk < 36（2026-08-31〜） / compileSdk < targetSdk | Play: ターゲット API レベル要件でアップロード拒否 |
| S2 | Firebase 使用で minSdk < 23 | Manifest merger / ビルド失敗 |
| S3 | build.gradle に versionCode 直書き | pubspec を上げても「バージョンコード使用済み」 |
| S4 | version が `X.Y.Z+N` でない / build 番号が既存タグ以下 / 上限超過 | Play・App Store とも重複で拒否 |
| S5 | CI の Flutter < 3.32、NDK < r28 | Play: 16KB ページ非対応で更新拒否 |
| S6 / I4 | `com.example` の applicationId / Bundle ID、xcodeproj 欠落 | ストアに登録できない |
| S7 | google_mobile_ads 使用で AdMob APPLICATION_ID なし | 起動直後クラッシュ |
| S8 | 広告ID使用 | Play Console の広告ID申告不一致でリジェクト |
| S9 | Google サインイン | 本番だけ DEVELOPER_ERROR 10（SHA-1 未登録） |
| S10 | RevenueCat | entitlement ID 不一致・課金アイテム未有効化 |
| I1 | PrivacyInfo.xcprivacy なし | ITMS-91053 |
| I2 | プラグインに必要な Info.plist の権限説明文なし | ITMS-90683 |
| I3 | CFBundleVersion が直書き | build 番号重複で拒否 |
| I5 | 1024 アイコンにアルファあり | ITMS-90717 |
| I6 | ITSAppUsesNonExemptEncryption なし | 毎回輸出コンプラ質問で提出が止まる |
| I7 | CI の Xcode < 26（2026-04-28〜） | App Store Connect がアップロード拒否 |
| I8 | GoogleService-Info.plist の BUNDLE_ID 不一致 | Firebase 初期化失敗 |

### マネタイズ・セキュリティ（子ども向けアプリ前提）

| # | 検出内容 | リスク |
|---|---|---|
| M1 | 子ども向けアプリで AdMob に TFCD/TFAT・`maxAdContentRating` なし | Play ファミリーポリシー違反で削除 |
| M2 | UMP 同意フローなし | EEA/UK で広告停止・ポリシー違反 |
| M3 | 本番広告ユニット ID の直書き | 開発中の自己クリックで AdMob 停止 |
| M4 | iOS で AdMob + Firebase Analytics（Kids カテゴリ） | ガイドライン 1.3 リジェクト |
| M5 | 購入の復元導線なし | ガイドライン 3.1.1 リジェクト |
| M6 | 購入導線に保護者ゲートなし | Kids / Families ポリシー違反 |
| M7 | 子ども向けアプリの外部リンク（CrossPromoSection 等）に保護者ゲートなし | Apple 1.3 / Families リジェクト |
| SEC1 | Firestore `write: if true` / 公開読取 | データ改ざん・個人情報漏えい |
| SEC2 | `usesCleartextTraffic` / `debuggable` | 通信盗聴・解析 |
| SEC3 | `.sh` の CRLF、`.gitattributes` 未設定 | Windows 編集後に CI/クラウドで実行不能 |
| SEC4 | release ビルドの難読化なし | リバースエンジニアリング |

### ルール更新（ユーザー確認不要・自動）

`store-rules.env` の `RULES_CHECKED` が 90 日以上前なら（store-check が RULES 警告を出す）:
1. 各値の横にある公式 URL を WebFetch し、要件・期限を再確認（ブログより公式を優先）
2. 値と `RULES_CHECKED` を更新し、変わった項目をコミットメッセージに書く
3. yourwish と shared_core の両方の `ship-cycle` を同じ内容にそろえる

新しい失敗が起きたら、**その根本原因を `preflight.sh` にチェックとして追加**し、この表に 1 行足す（同じ失敗を 2 度 CI で踏まない）。

## 低リソース方針

- Stage 1 は `grep`/`find` のみ。Flutter・Docker・ネットワーク不要。
- Stage 2 は差分パッケージのみ、`build_runner` は生成物が古い/欠落の時だけ、`flutter test` は `test/` がある時だけ。
- APK/AAB・エミュレータは CI（`release-readiness-check.yml` / emulator ワークフロー）に任せ、ローカルでは実行しない。
- `flutter clean` は P13 が疑われる時だけ（`CLEAN=1`）。毎回はしない。
