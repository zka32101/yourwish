# Flutter 教科アプリ — ビルド・CI/CD ガイド

**最終更新**: 2026年9月8日  
**対象アプリ**: kokugo-kore, seiza_kore, chikaba_kore, sansu-kore

---

## 📋 概要

本ドキュメントは、4つの Flutter 教科アプリの**標準ビルド・CI/CD パイプライン**を説明します。

- ✅ GitHub Actions による自動ビルド・デプロイ
- ✅ ローカル環境不要（リモート実行）
- ✅ SessionStart Hook による自動初期化
- ✅ build-and-test スキルによる 6 観点テスト

---

## 🏗️ アーキテクチャ概要

```
┌─────────────────────────────────────────┐
│ Git Push (claude/continuation-session-*) │
└────────────┬──────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ GitHub Actions Workflow Trigger         │
│ ├─ build-apk.yml (push/manual)          │
│ ├─ deploy.yml (tag push)                │
│ └─ google-drive-upload.yml (optional)   │
└────────────┬──────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ CI Pipeline                             │
│ ├─ Analyze & Test (Flutter)            │
│ ├─ Build Android (APK/AAB)             │
│ ├─ Build iOS (unsigned/TestFlight)     │
│ └─ Upload to Google Drive (optional)   │
└────────────┬──────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ Result: APK/AAB/IPA Ready               │
└─────────────────────────────────────────┘
```

---

## 🚀 クイックスタート

### 1. ローカルセットアップ（初回のみ）

```bash
# 1. リポジトリクローン
git clone https://github.com/zka32101/kokugo-kore.git
cd kokugo-kore

# 2. 開発ブランチに切り替え
git checkout claude/continuation-session-9vahuc

# 3. 依存関係をインストール
flutter pub get

# 4. 分析を実行（オプション）
flutter analyze
```

### 2. 変更をコミット・プッシュ

```bash
# ファイルを編集
# ...

# コミット
git add .
git commit -m "fix: description of changes"

# プッシュ（自動ビルド開始）
git push -u origin claude/continuation-session-9vahuc
```

### 3. GitHub Actions で自動実行

- **Actions タブ** → **最新ワークフロー実行** をクリック
- ビルド進捗をリアルタイム確認

---

## 📦 ワークフロー詳細

### A. build-apk.yml（基本ビルド）

**トリガー**:
```yaml
on:
  push:
    branches: ['claude/continuation-session-*', 'main']
  workflow_dispatch:  # 手動実行
```

**実行内容**:
- ✅ Analyze & Test
- ✅ Build Android APK/AAB
- ✅ Build iOS (unsigned)
- ❌ Upload to Google Drive (シークレット不要)

**使用例**:
```bash
# 自動実行（プッシュ時）
git push origin claude/continuation-session-9vahuc

# 手動実行（GitHub Web UI）
GitHub → Actions → build-apk → Run workflow
```

---

### B. deploy.yml（本番デプロイ）

**トリガー**:
```yaml
on:
  push:
    tags: ['v*']  # v1.0.0 など
  workflow_dispatch:
```

**実行内容**:
- ✅ リリースビルド
- ✅ 署名付き iOS TestFlight デプロイ（オプション）
- ✅ Google Drive アップロード（シークレット設定時）

**使用例**:
```bash
# リリースタグをプッシュ
git tag v1.1.0
git push origin v1.1.0

# GitHub で自動デプロイ開始
```

---

### C. google-drive-upload.yml（Google Drive アップロード）

**用途**: ビルド完了後、APK/AAB を Google Drive にアップロード

**前提条件**:
```
GitHub Secrets 設定:
├─ GOOGLE_DRIVE_SERVICE_ACCOUNT
│  └─ Google Cloud サービスアカウントの JSON キー
└─ GOOGLE_DRIVE_FOLDER_ID
   └─ アップロード先フォルダの ID
```

**設定方法**:
```bash
# 1. Google Cloud Console でサービスアカウントを作成
# 2. JSON キーをダウンロード
# 3. GitHub リポジトリ → Settings → Secrets → New secret
#    名前: GOOGLE_DRIVE_SERVICE_ACCOUNT
#    値: JSON キー全文
# 4. フォルダ ID も追加
```

---

## 🔧 ローカルビルド（オプション）

### Flutter がインストール済みの場合

```bash
# デバッグビルド
flutter build apk --debug

# リリースビルド
flutter build apk --release

# iOS（macOS のみ）
flutter build ios --release
```

### Docker を使用する場合

```bash
# Docker イメージでビルド
docker-compose run --rm flutter flutter build apk --release
```

---

## 🧪 SessionStart Hook — 自動初期化

**目的**: Claude Code セッション起動時に自動的に依存関係をインストール

**動作内容**:
```bash
# セッション起動時に自動実行
✅ flutter pub get          # 依存関係インストール
✅ flutter analyze          # コード分析
✅ build-and-test スキル確認  # テスト環境準備
```

**設定ファイル**:
- `.claude/hooks/session-start.sh` — 初期化スクリプト
- `.claude/settings.json` — Hook 登録設定

**手動実行**:
```bash
./.claude/hooks/session-start.sh
```

---

## 🧪 build-and-test スキル — 6 観点テスト

Claude Code セッションで以下を実行：

```bash
/build-and-test <app_name>
```

**テスト観点**:

| # | 観点 | 説明 |
|---|------|------|
| 1 | **起動テスト** | App startup verification |
| 2 | **接続テスト** | Network connectivity check |
| 3 | **課金画面** | Billing screen display |
| 4 | **認証テスト** | Authentication flow |
| 5 | **広告テスト** | Ad display verification |
| 6 | **クラッシュ検出** | Crash detection |

**使用例**:
```bash
# kokugo-kore をテスト
/build-and-test kokugo-kore

# seiza_kore をテスト
/build-and-test seiza_kore
```

---

## ⚠️ トラブルシューティング

### エラー: "Unexpected end of JSON input"

**原因**: GOOGLE_DRIVE_SERVICE_ACCOUNT シークレットが空または不正

**解決**:
```bash
# 1. GitHub → Settings → Secrets → Verify secret is set
# 2. JSON 形式をチェック
cat /tmp/sa.json | python3 -m json.tool

# 3. 無効な場合は再設定
```

---

### エラー: "flutter: command not found"

**原因**: Flutter SDK がインストールされていない（リモート環境）

**解決**:
- ✅ GitHub Actions で自動実行（推奨）
- または
- 📦 ローカル Flutter 環境でビルド

```bash
# Flutter インストール
curl https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz | tar xJ
export PATH="$PATH:$(pwd)/flutter/bin"
flutter pub get
```

---

### エラー: "lint: 25 issues found"

**原因**: コード品質チェックで問題が検出

**解決**:
```bash
# 1. 分析詳細を確認
flutter analyze

# 2. 修正
# - 警告を対応するか、
# - .analysis_options.yaml で無視するか

# 3. 再プッシュ
git add .
git commit -m "fix: resolve lint issues"
git push
```

---

### ワークフロー実行失敗時の確認

**GitHub 画面**:
1. リポジトリ → **Actions** タブ
2. 失敗したワークフローをクリック
3. ジョブ詳細 → **ステップ** → エラーメッセージ確認
4. 特定ステップの **Logs** を展開

**デバッグ例**:
```bash
# ローカルで同じコマンドを実行
flutter pub get
flutter analyze
flutter build apk --release
```

---

## 📊 ビルド結果の入手

### APK/AAB（Android）

**取得方法**:
1. GitHub Actions → ワークフロー実行完了
2. **Artifacts** セクション → `android-build` をダウンロード
3. `build/app/outputs/apk/release/app-release.apk` を取得

**インストール**:
```bash
adb install -r app-release.apk
```

### IPA（iOS）

**取得方法**:
1. macOS 環境でローカルビルド
2. または TestFlight 経由でテスト

```bash
flutter build ios --release
# => build/ios/iphoneos/Runner.app
```

### Google Drive アップロード

シークレット設定済みの場合、自動アップロード:
- `deploy.yml` 実行後、APK が Drive に配置される

---

## 🔐 セキュリティ設定

### GitHub Secrets（本番環境のみ）

**必須シークレット**:
```
GOOGLE_DRIVE_SERVICE_ACCOUNT    # Google Cloud サービスアカウント JSON
GOOGLE_DRIVE_FOLDER_ID           # アップロード先フォルダ ID
```

**設定方法**:
```
GitHub → Settings → Secrets and variables → Actions
→ New repository secret
```

**注意**:
- ❌ シークレット値をコミットしない
- ❌ .env ファイルにハードコードしない
- ✅ GitHub Secrets を使用

---

## 📚 参考資料

### Flutter 公式ドキュメント
- [Flutter ビルドガイド](https://flutter.dev/docs/deployment)
- [Flutter CI/CD](https://flutter.dev/docs/deployment/cd)

### GitHub Actions
- [Workflow 構文](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)
- [Environment Variables](https://docs.github.com/actions/learn-github-actions/environment-variables)

### 各アプリケーション README
- [kokugo-kore](../apps/kokugo-kore/README.md)
- [seiza_kore](../apps/seiza_kore/README.md)
- [chikaba_kore](../apps/chikaba_kore/README.md)
- [sansu-kore](../apps/sansu-kore/README.md)

---

## 💡 ベストプラクティス

### 1. ブランチ戦略

```
main (stable)
  ├─ v1.0.0 (tag)
  │
  └─ claude/continuation-session-* (development)
     ├─ feature/A
     ├─ fix/B
     └─ ...
```

### 2. コミットメッセージ

```bash
git commit -m "fix: SessionStart Hook 追加"
git commit -m "feat: Google Drive upload 対応"
git commit -m "chore: 依存関係更新"
```

### 3. バージョン管理

```yaml
# pubspec.yaml
version: 1.1.0+5
# 形式: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

### 4. リリースチェックリスト

- [ ] `flutter analyze` でエラーなし
- [ ] すべてのテスト合格
- [ ] README 更新
- [ ] バージョンアップ
- [ ] タグをプッシュ
- [ ] GitHub Releases で説明追加

---

## 🚨 よくある質問（FAQ）

**Q: 開発環境に Flutter をインストールする必要はありますか？**  
A: GitHub Actions で自動ビルドできるため不要ですが、ローカルテストには推奨します。

**Q: ビルド時間はどのくらいですか？**  
A: 初回 10-15 分、キャッシュ有り時 3-5 分。

**Q: iOS ビルドは macOS でのみ実行ですか？**  
A: はい。iOS ビルドには macOS ランナーが必要です。

**Q: Google Drive アップロードを無効にしたいです**  
A: `deploy.yml` で upload-to-google-drive ジョブを削除またはコメントアウト。

---

## 🔄 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-09-08 | 初版作成・公開 |
| | SessionStart Hook・build-and-test スキル統合 |
| | CI/CD パイプライン標準化 |

---

**質問・改善提案**: 各リポジトリの Issue を作成してください。
