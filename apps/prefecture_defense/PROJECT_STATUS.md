# 地理パズル王 — プロジェクト実装状況

**更新日:** 2026-06-14

---

## 📊 実装進捗

### ✅ Phase 1: 基本 UI フレームワーク（完成）

#### 実装済み画面（全7画面）

| # | 画面名 | ファイル | 状態 | 内容 |
|---|--------|---------|------|------|
| 1 | Splash 画面 | `screens/auth/splash_screen.dart` | ✅ 完成 | グラデーション背景 + ローディングアニメーション |
| 2 | ログイン画面 | `screens/auth/login_screen.dart` | ✅ 完成 | メール・パスワード入力 + 新規登録リンク |
| 3 | ホーム画面 | `screens/home/home_screen.dart` | ✅ 完成 | 本拠地カード + イベント表示 + メニューボタン |
| 4 | 都道府県マップ | `screens/home/prefecture_map_screen.dart` | ✅ 完成 | 3x グリッド表示 + 県詳細ポップアップ + 難度選択 |
| 5 | 図鑑 | `screens/pokedex/pokedex_screen.dart` | ✅ 完成 | クリア県一覧 + 統計タブ（クリア数・プレイ時間等） |
| 6 | ランキング | `screens/ranking/ranking_screen.dart` | ✅ 完成 | グローバル + 都道府県対抗 の2タブ |
| 7 | 設定 | `screens/settings/settings_screen.dart` | ✅ 完成 | プロフィール・通知・言語・ログアウト等 |

#### ユーティリティ
- ✅ `lib/config/constants.dart` - カラーパレット・テキストスタイル・スペーシング
- ✅ `lib/config/app_config.dart` - アプリ設定・環境設定
- ✅ `lib/utils/prefecture_data.dart` - 47都道府県マスターデータ（14県の詳細実装）

#### ナビゲーション・ルーティング
- ✅ `lib/main.dart` - 全7画面のルート登録
- ✅ ホーム画面からの各画面へのナビゲーション実装
- ✅ ボトムナビゲーションバー（アイコン + ラベル）

---

## 🎨 UI/UX 特徴

### デザイン
- **Material Design 3** 準拠
- **カラースキーム:** グリーン（#2E7D32）をプライマリカラー
- **フォント:** Material Design 3 デフォルトフォント
- **スペーシング:** 一貫した間隔（xs:4, sm:8, md:16, lg:24, xl:32）

### アニメーション
- Splash 画面：フェードイン（1500ms）
- ホーム画面：本拠地カード（グラデーション背景）
- ランキング画面：メダル表示（絵文字）

### インタラクション
- すべてのボタンに視覚的フィードバック
- モーダルダイアログ（県詳細選択）
- SnackBar（アクション確認）

---

## 📱 レスポンシブデザイン

- ✅ **スマートフォン対応:** 320px～ のビューポート対応
- ✅ **都道府県グリッド:** 3列自動調整
- ✅ **ダークモード:** デバイス設定に自動対応（Material Design 3）

---

## 🔄 ダミーデータ

### 都道府県データ
- **14県詳細実装:** 北海道～神奈川県
- **ボス敵設定:** 名前・HP・攻撃力・スキル
- **特産品:** 3～4個リスト表示

### ランキング
- グローバルランキング：5プレイヤー
- 都道府県ランキング：5都道府県

### クリア履歴
- ダミークリア県：5県

---

## 📋 実装の対応状況

| 項目 | 対応 | 備考 |
|------|------|------|
| Splash→Login→Home フロー | ✅ | 2秒遅延で自動遷移 |
| 都道府県データマスター | ✅ | 14県詳細 + 検索関数 |
| ホーム画面の本拠地表示 | ✅ | Lv・経験値バー表示 |
| マップ画面の県選択 | ✅ | グリッド + ポップアップ |
| 難度選択（Easy/Normal/Hard） | ✅ | ボタン + 視覚フィードバック |
| 図鑑のクリア県表示 | ✅ | グリッド + 統計タブ |
| ランキング表示 | ✅ | メダル＆スコア表示 |
| ナビゲーション | ✅ | ボトムナビバー + ルート登録 |

---

## ❌ 未実装（次フェーズ）

### Phase 2: 状態管理＋ゲーム基本ロジック
- [ ] **Riverpod 統合**
  - `providers/auth_provider.dart` - ログイン状態
  - `providers/user_provider.dart` - ユーザー情報
  - `providers/game_provider.dart` - ゲーム状態
- [ ] **ゲーム画面** (`screens/game/game_screen.dart`)
  - グリッドベースのゲームフィールド
  - 敵キャラ表示 + 移動ロジック
  - 施設配置・攻撃機能
- [ ] **結果画面** (`screens/game/result_screen.dart`)
- [ ] **SharedPreferences** - ゲーム履歴保存

### Phase 3: Firebase 統合
- [ ] Firebase Core 初期化
- [ ] Firebase Auth（メール認証）
- [ ] Firestore（ユーザー・ゲーム履歴）
- [ ] 親向けダッシュボード

### Phase 4: 複雑機能＋ポーランド
- [ ] RevenueCat（課金）
- [ ] AdMob（広告）
- [ ] チート検出
- [ ] マルチプレイ対応
- [ ] テスト（ユニット・ウィジェット・E2E）

---

## 🚀 実行方法

### ビルド前提
- Flutter 3.x 以上
- Dart 3.x 以上
- Java 11+ (Android)

### 実行手順（日本語パス対応）

```bash
# 1. プロジェクトフォルダ
cd H:\マイドライブ\apps\prefecture_defense

# 2. 依存関係インストール
flutter pub get

# 3. ウェブ版で実行（日本語パス回避）
flutter run -d chrome

# 4. Windows デスクトップ版（将来）
# 注: シンボリックリンク問題のため、C:\apk\ にコピー推奨
```

### デバッグ・開発

```bash
# ホットリロード有効
flutter run -d chrome --hot

# ビルドのクリア
flutter clean
flutter pub get
```

---

## 📂 ファイル構成

```
lib/
├── main.dart                          # ✅ エントリーポイント + ルーティング
├── config/
│   ├── constants.dart                 # ✅ カラーパレット・テキストスタイル
│   └── app_config.dart                # ✅ アプリ設定
├── utils/
│   └── prefecture_data.dart           # ✅ 都道府県マスターデータ
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart         # ✅
│   │   └── login_screen.dart          # ✅
│   ├── home/
│   │   ├── home_screen.dart           # ✅
│   │   └── prefecture_map_screen.dart # ✅
│   ├── pokedex/
│   │   └── pokedex_screen.dart        # ✅
│   ├── ranking/
│   │   └── ranking_screen.dart        # ✅
│   ├── settings/
│   │   └── settings_screen.dart       # ✅
│   └── game/                          # ⏳ Phase 2
├── models/                            # ⏳ Phase 2
├── providers/                         # ⏳ Phase 2
├── services/                          # ⏳ Phase 2
├── widgets/                           # ⏳ Phase 2
└── extensions/                        # ⏳ Phase 3
```

---

## 💡 設計との対応

| 設計書セクション | 実装状況 |
|-----------------|--------|
| Section 2: 技術スタック | ✅ 準備完了（Firebase は次フェーズ） |
| Section 3: ディレクトリ構成 | ✅ 実装済み |
| Section 4.1-4.11: 画面設計 | ✅ UI 完成（ロジックは次フェーズ） |
| Section 5: Firestore スキーマ | ⏳ Phase 3 |
| Section 6: API 仕様 | ⏳ Phase 3 |
| Section 7: 認証フロー | ⏳ Phase 2-3 |
| Section 8: チート対策 | ⏳ Phase 4 |

---

## 📝 次のステップ

### 今すぐ
- [ ] Chrome または実機で実行して動作確認
- [ ] UI の微調整（余白・フォントサイズ等）
- [ ] 都道府県データ全47県を完成

### 近い将来（1～2日）
- [ ] **Riverpod** で状態管理を実装
- [ ] **ゲーム画面** の基本ロジック実装
- [ ] **SharedPreferences** でローカル保存

### 中期（1～2週間）
- [ ] Firebase との連携
- [ ] 親向けダッシュボード基本版
- [ ] テスト開始

---

## 🛠️ 技術メモ

### 使用パッケージ
- `flutter_riverpod` 2.4.0 - 状態管理
- `go_router` 14.0.0 - ナビゲーション（準備）
- `shared_preferences` 2.2.0 - ローカルストレージ
- `lottie` 2.7.0 - アニメーション
- `cached_network_image` 3.3.1 - 画像キャッシュ（準備）

### 設計パターン
- **MVVM** パターン（Provider を使用）
- **MaterialApp** × **Navigator 2.0** ベースのナビゲーション
- **Material Design 3** 準拠

### パフォーマンス最適化
- リスト表示：`ListView.builder` で遅延レンダリング
- 画像：`cached_network_image` で効率化（準備）
- UI 再構築：`StatefulWidget` で局所的な状態管理

---

## ✨ 完成状況

```
初期セットアップ     ███████████████████  100% ✅
UI フレームワーク   ███████████████████  100% ✅
状態管理（Riverpod） ░░░░░░░░░░░░░░░░░░░   0% ⏳
ゲームロジック      ░░░░░░░░░░░░░░░░░░░   0% ⏳
Firebase 統合      ░░░░░░░░░░░░░░░░░░░   0% ⏳
全体的な完成度      ████░░░░░░░░░░░░░░░  20%
```

---

**🎯 目標:** 2026年8月末までに Phase 1 完全完成 → Google Play/App Store リリース準備
