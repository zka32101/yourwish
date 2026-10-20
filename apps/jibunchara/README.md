# ジブンキャラ（統計可視化プロトタイプ）

6軸のギャップ分析（レーダー）・分布ヒストグラム・ほしぞら分布を `fl_chart` で試作。
集団比較は n < 30 のとき理論基準へ自動フォールバック（k匿名性）。

```bash
cd apps/jibunchara
flutter create . --platforms=android,ios   # 初回のみ
flutter pub get && flutter test && flutter run
```

## ホーム画面ウィジェット（Dart側まで実装済み）
`widget_snapshot.dart` が相棒の表情・連続日数・週進捗を JSON にし、`widget_sync.dart` の
`WidgetSink` へ渡す。ネイティブ側（未実装）は次の手順で接続する:
1. `flutter create . --platforms=android` で android/ を生成
2. `home_widget` を追加し、`WidgetSink` の実装で `HomeWidget.saveWidgetData` + `updateWidget`
3. Android: AppWidgetProvider とレイアウトで `mood` / `streakDays` / `line` を表示
