import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/stats_model.dart';

void main() {
  const theory =
      AxisDistribution(mean: 50, sd: 15, n: 0, isTheoretical: true);

  test('平均のパーセンタイルは約50', () {
    expect(theory.percentile(50), closeTo(50, 0.5));
  });

  test('ヒストグラム合計はほぼ100', () {
    final sum = theory.histogram().reduce((a, b) => a + b);
    expect(sum, greaterThan(95));
    expect(sum, lessThanOrEqualTo(100.01));
  });

  test('nが閾値未満なら理論基準を使う', () {
    const small = AxisDistribution(
        mean: 60, sd: 10, n: minGroupSize - 1, isTheoretical: false);
    const enough = AxisDistribution(
        mean: 60, sd: 10, n: minGroupSize, isTheoretical: false);
    expect(pickBaseline(theoretical: theory, measured: small), theory);
    expect(pickBaseline(theoretical: theory, measured: enough), enough);
  });
}
