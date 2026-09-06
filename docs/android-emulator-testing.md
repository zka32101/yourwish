# Android Emulator Testing Guide

テストセッション分離モデルによる Flutter アプリ用 Android エミュレータテスト。各アプリセッションで独立してテストを実行します。

## 📱 アーキテクチャ概要

```
管理セッション（yourwish）
├── オーケストレーション
├── テンプレート管理
└── 配布・監視

テストセッション群（各アプリ）
├── eigo
├── shinshin
├── social_quiz_app
├── newrepo
├── kokugo-kore
├── shogaku-kore-programming
├── sansu-kore
├── chikaba_kore
└── seiza_kore

各セッションが独立して：
✅ ローカル改修
✅ ビルド（APK/AAB）
✅ Android Emulator テスト実行
✅ Google Drive 自動アップロード
```

## 🚀 クイックスタート

### 1. ローカル環境セットアップ

```bash
# セッション開始時に自動実行（非同期）
# または手動で実行：
bash scripts/setup-android-emulator.sh [app_name]

# 例：eigo アプリ用 AVD 作成
bash scripts/setup-android-emulator.sh eigo
```

**インストール内容：**
- Android SDK コマンドラインツール
- Platform Tools (API 34)
- System Images (x86_64)
- Gradle キャッシュ最適化
- Flutter キャッシュ初期化

### 2. エミュレータ起動

```bash
# Android Virtual Device 起動
emulator -avd eigo -no-audio -no-boot-anim &

# 起動確認
adb devices
adb shell getprop ro.boot.serialno
```

### 3. テスト実行

```bash
# Flutter テスト実行（エミュレータ接続時）
flutter test

# または全テスト
flutter test --verbose

# 特定テスト
flutter test test/specific_test.dart
```

## 🔄 CI/CD ワークフロー統合

### Reusable Workflow: `android-emulator-test.yml`

各アプリの CI から呼び出し可能：

```yaml
jobs:
  test:
    uses: zka32101/yourwish/.github/workflows/android-emulator-test.yml@main
    with:
      app-path: 'apps/yourapp'
      test-command: 'flutter test'
```

**機能：**
- ✅ Android SDK/AVD 自動セットアップ
- ✅ エミュレータ自動起動・ブート待機
- ✅ Flutter テスト自動実行
- ✅ ログ収集・アップロード
- ✅ エミュレータ自動停止・クリーンアップ

### ローカルでの CI/CD テスト

```bash
# GitHub Actions ワークフロー をローカルシミュレート
# act (https://github.com/nektos/act) をインストール後：

act -j test-job

# または特定ワークフロー
act --workflows .github/workflows/android-emulator-test.yml
```

## 📦 テンプレート配布

### 管理セッションから全アプリへ配布

```bash
# テンプレート生成・配布
bash scripts/distribute-templates.sh

# 出力：
# ✅ .github/workflows/android-emulator-test.yml (各リポジトリ)
# ✅ scripts/setup-android-emulator.sh (各リポジトリ)
# ✅ Draft PR 自動作成（マージ待ち）
```

### 手動配布（単一リポジトリ）

```bash
# テンプレートコピー
cp .github/workflows/android-emulator-test.yml ../[app]/
cp scripts/setup-android-emulator.sh ../[app]/scripts/

# または git + 新ブランチ
cd ../[app]
git checkout -b android-emulator-setup
git add .github/workflows/android-emulator-test.yml scripts/setup-android-emulator.sh
git commit -m "Add Android emulator test support"
git push origin android-emulator-setup
```

## ⚙️ 環境変数・設定

### `.gradle/gradle.properties` (自動生成)

```properties
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.workers.max=4
org.gradle.jvmargs=-Xmx2048m -XX:+UseParallelGC
android.useAndroidX=true
android.enableJetifier=true
```

### `.claude/hooks/session-start.sh`

セッション開始時に自動実行：
- ✅ Docker/Flutter 環境確認
- ✅ Android SDK 初期化（`setup-android-emulator.sh`）
- ✅ AVD 作成

非同期実行（セッション起動を遅延させない）

### GitHub Secrets (必須)

各リポジトリで設定済み：

```
GOOGLE_DRIVE_FOLDER_ID = 1iXxOO750AyuIwXNwGF-qTJLmElIldgwD
GOOGLE_DRIVE_SERVICE_ACCOUNT = (JSON)
```

参照：`.github/workflows/google-drive-upload.yml`

## 🔍 トラブルシューティング

### エミュレータ起動失敗

```bash
# 1. AVD リスト確認
emulator -list-avds

# 2. キャッシュクリア
rm -rf ~/.android/avd/[app_name].avd/cache.img

# 3. マニュアル AVD 再作成
rm -rf ~/.android/avd/[app_name].avd/
bash scripts/setup-android-emulator.sh [app_name]

# 4. ログ確認
cat /tmp/emulator.log
```

### テスト失敗

```bash
# 1. エミュレータ接続確認
adb devices

# 2. キャッシュクリア
flutter clean
flutter pub get

# 3. テスト詳細ログ
flutter test --verbose 2>&1 | tee test.log

# 4. ローカルビルド確認
flutter build apk --release

# 5. CI ログ確認
# GitHub Actions → [Job] → [Step: Run tests] → ログ
```

### メモリ不足

```bash
# Gradle メモリ削減（.gradle/gradle.properties）
org.gradle.jvmargs=-Xmx1024m -XX:+UseParallelGC

# または Android Studio での制限
export ANDROID_EMULATOR_WAIT_TIME_BEFORE_KILL=60
```

### SDK 再インストール

```bash
# 既存 SDK クリア
rm -rf ~/Android/Sdk

# 再セットアップ
bash scripts/setup-android-emulator.sh --force

# または完全初期化
./scripts/setup-android-emulator.sh clean
```

## 📊 テスト結果・ログ

### ローカル実行

```bash
# テスト結果ファイル
flutter test --reporter=json > test-results.json

# カバレッジ
flutter test --coverage
open coverage/index.html
```

### CI/CD 実行

```
GitHub Actions → [Workflow] → [Job: emulator-test]

Artifacts:
├── android-emulator-logs
│   ├── logcat.log (デバイスログ)
│   └── emulator.log (エミュレータログ)
└── test-results.json (テスト結果)
```

Download from Actions tab → 分析

## 🎯 ベストプラクティス

### 1. **セッション専属化**
```
各アプリセッション = 改修 + ビルド + テスト
→ 責務明確、テスト並列化
```

### 2. **キャッシュ活用**
```bash
# GitHub Actions キャッシュ
- uses: actions/cache@v4
  with:
    path: ~/.gradle/caches
    key: gradle-${{ runner.os }}-${{ hashFiles('**/*.gradle.lock') }}
```

### 3. **エラーハンドリング**
```yaml
continue-on-error: true  # テスト失敗時も CI 続行
upload-artifact:          # ログ・結果を保持
```

### 4. **リソース最適化**
```
emulator memory: 2048MB
gradle workers: 4
java heap: 2048m
```

## 📋 チェックリスト（新規セッション）

- [ ] Android SDK インストール確認
- [ ] `setup-android-emulator.sh` 実行
- [ ] AVD 作成完了
- [ ] `flutter pub get` 実行
- [ ] ローカル ビルド成功（`flutter build apk --release`）
- [ ] ローカル テスト成功（`flutter test`）
- [ ] GitHub Secrets 設定確認
- [ ] CI 最初実行 → ビルド成功
- [ ] Google Drive アップロード確認

## 🔗 参考資料

- [Flutter テスト - 公式ドキュメント](https://flutter.dev/docs/testing)
- [Android Emulator - 公式ガイド](https://developer.android.com/studio/run/emulator)
- [GitHub Actions - Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [rclone + Google Drive](https://rclone.org/drive/)

---

**作成日**: 2026-09-06  
**管理セッション**: yourwish (orchestrator)  
**対象**: 9 Flutter apps + テスト独立化
