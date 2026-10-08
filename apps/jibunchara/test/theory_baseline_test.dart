import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/stats_model.dart';
import 'package:jibunchara/theory_baseline.dart';

void main() {
  test('E型はI型より社交性の平均が高い', () {
    expect(theoreticalDistribution('ENFP', 0).mean,
        greaterThan(theoreticalDistribution('INFP', 0).mean));
  });

  test('J型はP型より計画性の平均が高い', () {
    expect(theoreticalDistribution('ISTJ', 1).mean,
        greaterThan(theoreticalDistribution('ISTP', 1).mean));
  });

  test('全16タイプ×6軸が妥当な範囲（平均15〜85・理論基準）', () {
    for (final e in ['E', 'I']) {
      for (final s in ['S', 'N']) {
        for (final t in ['T', 'F']) {
          for (final j in ['J', 'P']) {
            final p = theoreticalProfile('$e$s$t$j');
            expect(p.length, axes.length);
            for (final d in p) {
              expect(d.mean, inInclusiveRange(15, 85));
              expect(d.isTheoretical, isTrue);
            }
          }
        }
      }
    }
  });
}
