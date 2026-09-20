---
name: shogi-card-6perspective-test-plan
description: shogi_app + card_rivals の6観点テスト実行ガイド・チェックリスト・結果記録フォーマット
metadata: 
  node_type: memory
  type: project
  projects: 
    - shogi_app
    - card_rivals
  status: test-plan-ready
  date: 2026-09-12
  modified: 2026-09-12T03:42:36.671Z
  originSessionId: 40d5d5bc-2a53-48a7-ba63-f79dd03718ae
---

# 🎯 shogi_app / card_rivals 6観点テスト実行ガイド

## 📋 6観点テスト概要

| 観点 | テスト内容 | 合否条件 |
|------|-----------|--------|
| **1️⃣ 起動** | splash_screen表示・ホーム画面表示・クラッシュなし | logcat で Exception/ANR なし |
| **2️⃣ Firebase** | 認証初期化・Firestore接続・Remote Config取得 | ネットワーク接続確認 |
| **3️⃣ 課金** | IAP画面表示・プロダクト情報取得（Google Play Billing） | 課金画面が表示される |
| **4️⃣ 認証** | 匿名認証 / メール認証 / Google OAuth フロー | ユーザープロフィール取得 |
| **5️⃣ 広告** | バナー広告表示・インタースティシャル・リワード動作 | AdMob コンソール配信確認 |
| **6️⃣ クラッシュ** | 画面遷移・ジェスチャー・ダークモード切替・メモリ圧迫テスト | スタックトレースなし |

---

## 🔧 セットアップ（各テスト開始前）

### 1. エミュレータ準備

```powershell
# エミュレータ起動確認
adb devices
# → emulator-5554 device （"device" = 認可済み）

# 認可待ち（必要時）
Start-Sleep -Seconds 60
adb devices  # 再確認
```

### 2. メモリ解放

```powershell
# バックグラウンドプロセス終了
Get-Process -Name "java", "chrome", "msedge" -ErrorAction SilentlyContinue | Stop-Process -Force

# GC実行
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
```

### 3. logcat 開始（テスト全期間）

```bash
adb logcat > test-results/logcat-{project}-{date}.log &
# テスト終了時: Ctrl+C で停止
```

---

## 📱 **shogi_app テスト実行**

### テスト対象: 将棋ボード・AI対局・ネットワーク対局

#### 1️⃣ 起動テスト

```powershell
cd "H:\マイドライブ\apps\shogi_app"
subst S: .
cd S:\

# APK ビルド
flutter build apk --debug --no-pub

# インストール
adb install build\app\outputs\flutter-apk\app-debug.apk

# 起動
adb logcat > logcat-startup.log &
flutter run --debug

# 確認項目
# ✅ splash_screen (🌟 スター) 2-3秒表示
# ✅ ホーム画面表示（loading spinner なし）
# ✅ 各メニュータブ表示（local, network, stats）
# ✅ logcat で "FATAL", "ANR", "Exception" なし
```

**記録**: `test-results/shogi-app-startup-{date}.log`

---

#### 2️⃣ Firebase接続テスト

```powershell
# Firebase Console 確認（別ブラウザ）
# https://console.firebase.google.com

# アプリ内での確認
# 1. ネットワーク対局タブを開く
# 2. 「対戦相手を探す」ボタンをタップ
# 3. Firebase認証・Firestore接続確認
#    ✅ ユーザー登録画面またはマッチング画面表示
#    ✅ 通信エラーが出ない
```

**確認項目**:
- ✅ Firebase Authentication 初期化（匿名認証）
- ✅ Firestore 接続（マッチング情報取得）
- ✅ Realtime Database 接続（盤面同期）
- ✅ Cloud Functions 呼び出し（AI手筋取得）

**記録**: Firebase Console の Analytics タブで DAU/セッション確認

---

#### 3️⃣ 課金テスト

```powershell
# 課金画面への遷移
# 1. ホーム画面 → プレミアム/ショップ タブ
# 2. 「購入」ボタンをタップ
# 3. Google Play 購入画面表示

# 確認項目
# ✅ プロダクト情報取得（価格・説明）
# ✅ 購入ダイアログ表示
# ✅ キャンセルボタン動作
```

**備考**: テスト環境では実際の課金は発生しない

**記録**: `test-results/shogi-app-billing-{date}.log`

---

#### 4️⃣ 認証テスト

```powershell
# 匿名認証フロー
# 1. ネットワーク対局 → 「マッチング」をタップ
# 2. 匿名認証画面（自動または手動選択）
# 3. ユーザープロフィール表示

# メール認証（オプション）
# 1. ホーム → ユーザーアイコン → 「ログイン」
# 2. メール入力 → メール受信 → リンククリック
# 3. プロフィール更新画面

# Google認証（オプション）
# 1. 「Google でログイン」ボタンをタップ
# 2. Google アカウント選択
# 3. プロフィール自動取得
```

**確認項目**:
- ✅ ユーザー UUID 生成
- ✅ プロフィール情報取得（username, avatar）
- ✅ Firestore ユーザードキュメント作成

**記録**: `test-results/shogi-app-auth-{date}.log`

---

#### 5️⃣ 広告テスト

```powershell
# バナー広告確認
# 1. ホーム画面下部 → バナー広告表示確認

# インタースティシャル広告確認
# 1. ローカル対局終了後 → 広告表示（数秒）→ 「閉じる」

# リワード広告確認
# 1. ホーム → 「無料ボーナス」→ 「広告を見てコイン獲得」
# 2. リワード広告再生
# 3. 完了後ボーナス付与確認
```

**確認項目**:
- ✅ AdMob バナー表示
- ✅ インタースティシャル フルスクリーン表示
- ✅ リワード動画再生 + コイン加算
- ✅ 広告ブロック / 遅延なし

**記録**: AdMob Console → Earnings / Impressions タブで確認

---

#### 6️⃣ クラッシュテスト

```powershell
# 画面遷移テスト
adb logcat | grep -E "FATAL|ANR|Exception" &
# 各タブを順番にタップ（local → network → stats → badge）

# ジェスチャーテスト
# 1. スワイプ（タブ間の移動）
# 2. ダブルタップ（盤面操作）
# 3. ロングプレス（コンテキストメニュー）
# 4. ピンチズーム（盤面拡大）

# ダークモード切替
# 1. 設定 → 「ダークモード」オン/オフ
# 2. 画面遷移確認

# メモリ圧迫テスト（オプション）
adb shell dumpsys meminfo
# → Used RAM が 80% 超過時でもクラッシュなし確認
```

**確認項目**:
- ✅ ANR（Application Not Responding）なし
- ✅ クラッシュ（Fatal Exception）なし
- ✅ フリーズ（UI応答遅延）なし
- ✅ メモリリーク（RAM 徐々に増加）なし

**記録**: `test-results/shogi-app-crash-{date}.log`

---

## 🃏 **card_rivals テスト実行**

### テスト対象: AI生成カード×属性戦

同じ 6観点テストを実施（above を参照）

```powershell
cd "H:\マイドライブ\apps\card_rivals"
subst C: .
cd C:\

# 以降、shogi_app と同じ手順
```

---

## 📊 テスト結果記録フォーマット

```
test-results/{project}-6perspective-{date}.txt

# ================================
# プロジェクト: shogi_app
# 日付: 2026-09-12
# テスター: Claude
# ================================

## 1️⃣ 起動テスト
結果: PASS / FAIL
詳細: splash_screen表示 ✅ / ホーム画面 ✅ / クラッシュなし ✅
エラー: （なし）

## 2️⃣ Firebase接続テスト
結果: PASS / FAIL
詳細: Auth初期化 ✅ / Firestore接続 ✅ / RTDB接続 ✅
エラー: （なし）

## 3️⃣ 課金テスト
結果: PASS / FAIL
詳細: 課金画面表示 ✅ / プロダクト取得 ✅ / キャンセル機能 ✅
エラー: （なし）

## 4️⃣ 認証テスト
結果: PASS / FAIL
詳細: 匿名認証 ✅ / プロフィール取得 ✅ / Firestore保存 ✅
エラー: （なし）

## 5️⃣ 広告テスト
結果: PASS / FAIL
詳細: バナー表示 ✅ / インタースティシャル ✅ / リワード ✅
エラー: （なし）

## 6️⃣ クラッシュテスト
結果: PASS / FAIL
詳細: 画面遷移 ✅ / ジェスチャー ✅ / ダークモード ✅
エラー: （なし）

## 総合判定: PASS / FAIL
重大度別エラー: 0 critical, 0 major, 0 minor
```

---

## ✅ チェックリスト（テスト前）

- [ ] エミュレータ起動済み（emulator-5554 device）
- [ ] メモリ解放完了
- [ ] logcat ストリーミング開始
- [ ] APK ビルド完了
- [ ] APK インストール完了
- [ ] test-results/ ディレクトリ作成
- [ ] Firebase Console アクセス可能
- [ ] AdMob Console アクセス可能

---

## 🔗 リンク

- Firebase Console: https://console.firebase.google.com
- AdMob Console: https://admob.google.com
- Google Play Console: https://play.google.com/console

---

**このガイドは次セッション（2026-09-13以降）で実行してください**

