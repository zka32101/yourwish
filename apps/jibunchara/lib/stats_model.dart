import 'dart:math';

/// 6軸の名前（レーダー・ヒストグラム共通）
const axes = ['社交性', '計画性', '行動力', '感受性', '自信', '安定感'];

/// 集団比較の最小サンプル数（k匿名性）。実運用では Remote Config で配信。
const minGroupSize = 30;

/// 軸ごとの集団分布（理論基準 or 実測集計）
class AxisDistribution {
  const AxisDistribution({
    required this.mean,
    required this.sd,
    required this.n,
    required this.isTheoretical,
  });

  final double mean;
  final double sd;
  final int n;
  final bool isTheoretical;

  /// 正規近似のパーセンタイル（0-100）
  double percentile(double score) {
    final z = (score - mean) / sd;
    return 100 * _phi(z);
  }

  /// ヒストグラム（10区間 0-100）の相対度数
  List<double> histogram() {
    return List.generate(10, (i) {
      final lo = i * 10.0, hi = lo + 10;
      final p = _phi((hi - mean) / sd) - _phi((lo - mean) / sd);
      return p * 100;
    });
  }
}

double _phi(double z) => 0.5 * (1 + _erf(z / sqrt2));

double _erf(double x) {
  // Abramowitz-Stegun 近似
  const a1 = 0.254829592, a2 = -0.284496736, a3 = 1.421413741;
  const a4 = -1.453152027, a5 = 1.061405429, p = 0.3275911;
  final s = x < 0 ? -1 : 1;
  final t = 1 / (1 + p * x.abs());
  final y = 1 -
      (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-x * x);
  return s * y;
}

/// 実測 n が閾値以上なら実測、未満なら理論基準を返す。
AxisDistribution pickBaseline({
  required AxisDistribution theoretical,
  AxisDistribution? measured,
}) {
  if (measured != null && measured.n >= minGroupSize) return measured;
  return theoretical;
}

/// デモ用データ
const demoCurrent = [62.0, 48.0, 70.0, 80.0, 42.0, 55.0];
const demoIdeal = [75.0, 70.0, 80.0, 72.0, 70.0, 68.0];
const demoTheory = [
  AxisDistribution(mean: 50, sd: 15, n: 0, isTheoretical: true),
  AxisDistribution(mean: 52, sd: 14, n: 0, isTheoretical: true),
  AxisDistribution(mean: 55, sd: 15, n: 0, isTheoretical: true),
  AxisDistribution(mean: 60, sd: 13, n: 0, isTheoretical: true),
  AxisDistribution(mean: 48, sd: 16, n: 0, isTheoretical: true),
  AxisDistribution(mean: 50, sd: 14, n: 0, isTheoretical: true),
];
