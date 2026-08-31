# 地理パズル王 — 実装計画

**プロジェクト開始日:** 2026-06-14  
**最初のリリース目標:** 2026-08-31  
**現在フェーズ:** Phase 1 - 基本 UI フレームワーク

---

## ✅ 完了項目（初期セットアップ）

### ディレクトリ構成
- ✅ `lib/config/` - 定数・設定ファイル
- ✅ `lib/screens/` - 画面別スクリーン
  - ✅ `auth/` - ログイン・新規登録
  - ✅ `home/` - ホーム画面
  - その他スクリーン用フォルダ
- ✅ `lib/models/` - データモデル
- ✅ `lib/providers/` - Riverpod プロバイダー
- ✅ `lib/services/` - Firebase・API サービス
- ✅ `lib/widgets/` - 共通ウィジェット
- ✅ `lib/utils/` - ユーティリティ
- ✅ `lib/extensions/` - 拡張メソッド

### 実装済みファイル

#### UI フレームワーク
- ✅ `lib/config/constants.dart` - カラーパレット、テキストスタイル、スペーシング
- ✅ `lib/config/app_config.dart` - アプリ設定・環境設定
- ✅ `lib/screens/auth/splash_screen.dart` - Splash 画面
- ✅ `lib/screens/auth/login_screen.dart` - ログイン画面（シンプル版）
- ✅ `lib/screens/home/home_screen.dart` - ホーム画面（本拠地表示）
- ✅ `lib/main.dart` - エントリーポイント

#### 依存関係
- ✅ `flutter_riverpod` - 状態管理（本実装待ち）
- ✅ `go_router` - ナビゲーション（本実装待ち）
- ✅ `shared_preferences` - ローカルストレージ
- ✅ `lottie` - アニメーション
- ✅ `cached_network_image` - 画像キャッシュ（本実装待ち）

---

## 📋 次の実装ステップ（簡単なものから順）

### Step 1: 基本ナビゲーション設定（1-2時間）
- [ ] `go_router` でルーティング実装
- [ ] 各画面へのナビゲーション完成
- [ ] Splash → Login → Home の動作確認

### Step 2: 簡単な UI 画面を追加（2-4時間）
- [ ] **都道府県マップ画面** (`screens/home/prefecture_map_screen.dart`)
  - SVG 地図またはシンプルなグリッド表示
  - 県タップでポップアップ表示
- [ ] **図鑑画面** (`screens/pokedex/pokedex_screen.dart`)
  - クリア済み県リスト表示
  - グリッドレイアウト
- [ ] **ランキング画面** (`screens/ranking/ranking_screen.dart`)
  - ダミーデータのランキング表示
- [ ] **設定画面** (`screens/settings/settings_screen.dart`)
  - プロフィール表示
  - ログアウトボタン

### Step 3: 状態管理の実装（Riverpod）（2-3時間）
- [ ] `providers/auth_provider.dart` - ログイン状態管理
- [ ] `providers/user_provider.dart` - ユーザー情報プロバイダー
- [ ] `providers/game_provider.dart` - ゲーム状態管理（基本）
- [ ] Login と Home のナビゲーション連携

### Step 4: 簡単なゲーム画面（基本的な TD ロジック）（3-5時間）
- [ ] **ゲーム画面** (`screens/game/game_screen.dart`)
  - グリッドベースの簡単なフィールド
  - 敵キャラ表示（Lottie or simple animation）
  - 施設配置ボタン
- [ ] **結果画面** (`screens/game/result_screen.dart`)
  - スコア表示
  - 県ファクト表示

### Step 5: ローカルストレージ（SharedPreferences）（1-2時間）
- [ ] `services/storage_service.dart` - ローカル保存
- [ ] ゲーム履歴の保存・読み込み
- [ ] ログイン状態のキャッシュ

### Step 6: Firebase 統合（後段階）
- [ ] Firebase Core 初期化
- [ ] Firebase Auth（メール認証）
- [ ] Firestore（ユーザー・ゲーム履歴保存）

---

## 📚 設計参考資料

- **全体設計書:** `H:\マイドライブ\design\地理パズル王\地理パズル王_実装設計書_v1_0.md`
- **画面フロー:** 設計書の Section 4

---

## 🚀 実行方法

```bash
# プロジェクトフォルダに移動
cd H:\マイドライブ\apps\prefecture_defense

# 依存関係インストール済み
flutter pub get

# 開発版で起動
flutter run

# ホットリロード有効
```

---

## ⚠️ 既知の制限

1. **日本語パス対応:**
   - Firebase ビルド時は `C:\apk\` にコピーして実行
   - iOS ビルドは現在のパスでOK

2. **実装段階:**
   - Firebase（→ Phase 3+）
   - 複雑な TD ロジック（→ Phase 2）
   - 親向けダッシュボード（→ Phase 3）
   - 決済機能（RevenueCat）（→ Phase 4）

---

## 📝 メモ

- **簡単なものから始める** → UI フレームワーク → 基本ゲームロジック → Firebase/複雑機能
- **テストに先立つ UI 検証** → `flutter run` で実機 / エミュレーター確認
- **設計書準拠** → lib ディレクトリ構成は設計書 Section 3 に従う
