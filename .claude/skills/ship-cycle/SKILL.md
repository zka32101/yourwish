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
bash $S/release-prep.sh [dir]   # Stage 3: リリース準備レポート（RELEASE_REPORT.md 生成）
bash $S/ship.sh [dir]           # 1→2→3 を順に実行し、最初の失敗で停止
```

- `dir` 省略時はカレント。モノレポでは `apps/*` `packages/*` のうち **git 差分がある pubspec 単位だけ** を対象にする（`ALL=1` で全件）。
- 終了コード: 0=OK / 1=ブロッカーあり。警告は止めない。
- 環境変数: `BASE=<ref>`（差分基準。省略時は origin の既定ブランチを自動判定）, `ALL=1`, `SKIP_TEST=1`, `OFFLINE=1`（`pub get --offline` 優先）

## Claude の実行手順（自動運用）

1. 改修後、**必ず Stage 1 から**。ブロッカーが出たら直してから次へ（Flutter を起動する前に潰す）。
2. Stage 2 は Flutter SDK がある環境のみ。無ければ Stage 1 の結果だけで PR を作り、CI に委ねる（SDK を新規インストールしない＝低リソース）。
3. Stage 2 で codegen 差分が出たら生成物をコミットに含める（`.freezed.dart` / `.g.dart` は**コミット対象**）。
4. リリース前は Stage 3。`RELEASE_REPORT.md` の ❌ を 0 にしてから PR 本文に要約を貼る。
5. 失敗を直したら**同じ Stage を再実行して green を確認**してから push（speculative push をしない）。
6. ストア公開・Secrets 登録・署名鍵作成はユーザー作業。レポートの「ユーザー作業」欄に列挙するだけで止まらない。

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
| P13 | stale な `pubspec.lock` / `.dart_tool` による依存解決ズレ | yourwish 29bc4f1 | 2 |
| P14 | codegen 後に生成物差分が出る（コミット漏れ） | shared_core ddaf584 | 2 |
| P15 | version 未更新 / CHANGELOG 未記載 / 署名設定欠落 | リリース前 | 3 |

新しい失敗が起きたら、**その根本原因を `preflight.sh` にチェックとして追加**し、この表に 1 行足す（同じ失敗を 2 度 CI で踏まない）。

## 低リソース方針

- Stage 1 は `grep`/`find` のみ。Flutter・Docker・ネットワーク不要。
- Stage 2 は差分パッケージのみ、`build_runner` は生成物が古い/欠落の時だけ、`flutter test` は `test/` がある時だけ。
- APK/AAB・エミュレータは CI（`release-readiness-check.yml` / emulator ワークフロー）に任せ、ローカルでは実行しない。
- `flutter clean` は P13 が疑われる時だけ（`CLEAN=1`）。毎回はしない。
