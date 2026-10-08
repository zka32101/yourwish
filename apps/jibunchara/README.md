# ジブンキャラ（統計可視化プロトタイプ）

6軸のギャップ分析（レーダー）・分布ヒストグラム・ほしぞら分布を `fl_chart` で試作。
集団比較は n < 30 のとき理論基準へ自動フォールバック（k匿名性）。

```bash
cd apps/jibunchara
flutter create . --platforms=android,ios   # 初回のみ
flutter pub get && flutter test && flutter run
```
