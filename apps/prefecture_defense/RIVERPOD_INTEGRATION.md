# Riverpod 状態管理システム — 実装完了

**実装日:** 2026-06-14

---

## 📊 実装内容

### ✅ 完成した機能

#### 1. モデル層（lib/models/）
- **user_model.dart** - ユーザーモデル + 認証状態
  - `User` クラス：uid, nickname, email, level, experience, hometownCode, isPremium
  - `AuthState` enum：initial, loading, authenticated, unauthenticated, error
  - `AuthException` クラス

- **game_model.dart** - ゲーム関連モデル
  - `GameSession` クラス：ゲーム結果を保存
  - `GameInProgress` クラス：進行中のゲーム状態
  - `GameStats` クラス：プレイ統計

#### 2. Provider層（lib/providers/）
- **auth_provider.dart** - 認証管理
  - `authStateProvider` - 認証状態（StateProvider）
  - `currentUserProvider` - 現在のユーザー情報（StateProvider）
  - `authServiceProvider` - 認証ロジック（Provider）
  - `AuthService` クラス：
    - `login(email, password)` - ログイン
    - `logout()` - ログアウト
    - `signup(email, password, nickname)` - 新規登録
    - `updateUser(user)` - ユーザー情報更新

- **game_provider.dart** - ゲーム管理
  - `gameInProgressProvider` - 進行中のゲーム状態
  - `gameStatsProvider` - ゲーム統計（ダミー初期値付き）
  - `gameHistoryProvider` - ゲーム履歴
  - `gameServiceProvider` - ゲームロジック
  - `GameService` クラス：
    - `startGame()` - ゲーム開始
    - `updateGameScore()` - スコア更新
    - `updateGameTime()` - 時間更新
    - `endGame()` - ゲーム終了＆結果保存
    - `cancelGame()` - ゲームキャンセル
    - `getClearedPrefectures()` - クリア済み県リスト取得
    - `getBestScoreForPrefecture()` - 県別最高スコア

#### 3. 画面統合
- **login_screen.dart** → `ConsumerStatefulWidget`
  - `AuthService.login()` 実行
  - 認証状態をリアルタイム監視
  - ローディング表示（ボタン内）
  - ログイン成功時に `/home` へ自動遷移

- **home_screen.dart** → `ConsumerStatefulWidget`
  - ユーザー情報表示（Lv, 経験値）
  - ゲーム統計表示（ダミー）
  - 未認証時は自動的に `/login` へ遷移
  - ボトムナビゲーション統合

- **settings_screen.dart** → `ConsumerStatefulWidget`
  - ログアウト機能（Riverpod 連携）
  - ログアウト後は `/login` へ遷移

#### 4. アプリエントリーポイント
- **main.dart** - `ProviderScope` でラップ
  - すべての画面が Riverpod Provider にアクセス可能

---

## 🔄 データフロー

```
┌─────────────────────────────────────────────────────┐
│                     main.dart                       │
│                  (ProviderScope)                    │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
   ┌─────────────┐      ┌──────────────┐
   │  authState  │      │ currentUser  │
   │ (Provider)  │      │  (Provider)  │
   └──────┬──────┘      └───────┬──────┘
          │                     │
          └──────────┬──────────┘
                     ▼
         ┌───────────────────────┐
         │   AuthService         │
         │  - login()            │
         │  - logout()           │
         │  - signup()           │
         │  - updateUser()       │
         └────────┬──────────────┘
                  │
     ┌────────────┼────────────┐
     ▼            ▼            ▼
┌─────────┐  ┌─────────┐  ┌──────────────┐
│ Splash  │  │ Login   │  │    Home      │
│ Screen  │  │ Screen  │  │    Screen    │
└─────────┘  └────┬────┘  └──────┬───────┘
                  │               │
                  └───────┬───────┘
                          ▼
                   ┌─────────────┐
                   │  Settings   │
                   │   Screen    │
                   └─────────────┘
```

---

## 💡 使用パターン

### ログイン処理例
```dart
// ログイン画面での実装
final authService = ref.read(authServiceProvider);
await authService.login('user@example.com', 'password');
// → authState が AuthState.authenticated に変更
// → currentUser が設定される
// → Home 画面へ自動遷移
```

### ユーザー情報の取得
```dart
// どの画面でも
final user = ref.watch(currentUserProvider);
print(user?.nickname); // "ゲストプレイヤー"
print(user?.level);    // 5
```

### ゲーム統計の取得
```dart
// どの画面でも
final stats = ref.watch(gameStatsProvider);
print(stats.totalScore);              // 45230
print(stats.totalClearedPrefectures); // 5
```

### ゲーム開始〜終了の流れ
```dart
// ゲーム開始
final gameService = ref.read(gameServiceProvider);
gameService.startGame('01', 'normal');

// ゲーム進行中
gameService.updateGameScore(1250);
gameService.updateGameTime(150);

// ゲーム終了
gameService.endGame(
  finalScore: 1250,
  finalTime: 187,
  finalMistakes: 0,
  isCleared: true,
);
// → gameStats が自動更新
// → gameHistory に結果が追加
```

---

## 🔐 セキュリティメモ

### 現在（ダミー実装）
- メモリ上の状態管理のみ
- パスワード検証なし
- トークン管理なし

### Firebase 統合時の予定（Phase 3）
- JWT トークン管理
- Firebase Auth 実装
- SecureStorage でトークン保存
- 自動トークンリフレッシュ

---

## 📝 テスト方法

### 1. ログインテスト
```
1. Splash → Login 画面へ自動遷移
2. 任意のメール・パスワードを入力
3. ログインボタンをタップ
   - ローディング表示（1秒）
   - Home 画面へ遷移
4. ホーム画面でユーザー情報表示確認
```

### 2. ホーム画面テスト
```
1. ホーム画面に遷移後
2. Lv.5 / 600 XP 表示確認
3. ボトムナビバーをタップして各画面遷移確認
```

### 3. ログアウトテスト
```
1. ホーム → 設定画面へ遷移
2. 「ログアウト」をタップ
3. 確認ダイアログで「ログアウト」を選択
4. ログイン画面へ戻る
5. currentUser が null に初期化
```

### 4. 未認証時の処理
```
1. ホーム画面を開いた直後、未認証状態なら
2. 自動的にログイン画面へ遷移
```

---

## 🚀 次のステップ

### 次フェーズで実装予定

#### Phase 2: ゲーム画面実装
- [ ] `screens/game/game_screen.dart`
  - GameService を使用してゲーム状態管理
  - リアルタイムでスコア・時間・ミスを更新
- [ ] `screens/game/result_screen.dart`
  - ゲーム結果表示
  - `gameService.endGame()` で統計を自動更新

#### Phase 3: Firebase 統合
- [ ] Firebase Auth との連携
- [ ] Firestore への永続化
- [ ] トークンリフレッシュロジック

#### Phase 4: 複雑機能
- [ ] フレンド管理プロバイダー
- [ ] 課金状態プロバイダー
- [ ] ランキング更新ロジック

---

## 📚 ファイル構成

```
lib/
├── models/
│   ├── user_model.dart          # ✅ 完成
│   ├── game_model.dart          # ✅ 完成
│   └── ...
├── providers/
│   ├── auth_provider.dart       # ✅ 完成（Riverpod実装）
│   ├── game_provider.dart       # ✅ 完成（Riverpod実装）
│   └── ...
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # ✅ ConsumerStatefulWidget化
│   │   └── splash_screen.dart   # ✅ 既存
│   ├── home/
│   │   └── home_screen.dart     # ✅ ConsumerStatefulWidget化
│   └── settings/
│       └── settings_screen.dart # ✅ ConsumerStatefulWidget化
└── main.dart                    # ✅ ProviderScope 追加
```

---

## ✨ 完成状況

```
UI フレームワーク      ███████████████████  100% ✅
Riverpod 統合          ███████████████████  100% ✅
認証フロー             ███████████████████  100% ✅ (ダミー)
ゲーム状態管理         ███████████████████  100% ✅ (ダミー)
Firebase 連携          ░░░░░░░░░░░░░░░░░░░   0% ⏳
```

---

**🎯 状態：** Riverpod 状態管理 ✅ 完成
**次:**  ゲーム画面の基本ロジック実装
