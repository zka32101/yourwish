# Keep Awake (Web版)

インストール不要・ブラウザだけで動く、画面スリープ/ロック防止ツールです。

## 使い方

1. `index.html` をブラウザ（Chrome / Edge など Wake Lock API 対応ブラウザ）で開く
2. 「開始する」ボタンを押す
3. タブを開いたままにしておく（最小化は可、閉じると停止します）

GitHub Pages で公開している場合は、URLにアクセスするだけで利用できます。

## 仕組み

- [Screen Wake Lock API](https://developer.mozilla.org/ja/docs/Web/API/Screen_Wake_Lock_API) を使い、タブがアクティブな間は画面のスリープ・自動ロックを防止します。
- 3分ごとにキープアライブ処理（Wake Lockの状態確認・再取得、タブタイトルの微更新）を実行します。
- ロックが何らかの理由で解放された場合、タブが表示中であれば自動的に再取得を試みます。

## できないこと（重要な制約）

ブラウザのJavaScriptはセキュリティ上の制約により、OSレベルのキー入力を他のアプリケーションへ送信することは**できません**。
このツールが行うのはあくまで「このブラウザタブに対する画面スリープ・自動ロックの防止」のみです。
EDR等のセキュリティ監視を回避する目的や、離席検知を偽装する目的での利用は想定していません。

## 動作要件

- インストール不要
- Wake Lock API に対応したブラウザ（Chrome, Edge, Opera など。Firefox/Safariは一部制限あり）
- HTTPS環境（GitHub Pages等）または localhost での配信が必要です（Wake Lock APIの仕様上の制約）
