import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'stats_model.dart';

void main() => runApp(const JibunCharaApp());

const _pink = Color(0xFFFF8FB1);
const _mint = Color(0xFF7FD8C3);
const _lavender = Color(0xFFB8A9F0);
const _bg = Color(0xFFFFF7FB);

class JibunCharaApp extends StatelessWidget {
  const JibunCharaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ジブンキャラ',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: _pink,
          scaffoldBackgroundColor: _bg,
        ),
        home: const StatsPrototypePage(),
      );
}

class StatsPrototypePage extends StatefulWidget {
  const StatsPrototypePage({super.key});

  @override
  State<StatsPrototypePage> createState() => _StatsPrototypePageState();
}

class _StatsPrototypePageState extends State<StatsPrototypePage> {
  int axis = 0;

  @override
  Widget build(BuildContext context) {
    final dist = pickBaseline(theoretical: demoTheory[axis]);
    final pct = dist.percentile(demoCurrent[axis]);
    return Scaffold(
      appBar: AppBar(title: const Text('ギャップ分析（プロトタイプ）')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Bubble('いまの自分と理想、こんなにちかいよ！'
              '${axes[_biggestGap()]}をのばすとぐんと近づくかも'),
          const SizedBox(height: 12),
          _Card(title: 'レーダー（いま・理想・みんな）', child: _radar()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < axes.length; i++)
                ChoiceChip(
                  label: Text(axes[i]),
                  selected: axis == i,
                  onSelected: (_) => setState(() => axis = i),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Card(
            title: '${axes[axis]}の分布（${_baselineLabel(dist)}）',
            child: Column(children: [
              SizedBox(height: 180, child: _histogram(dist)),
              const SizedBox(height: 8),
              Text(_percentileText(pct),
                  style: Theme.of(context).textTheme.bodyLarge),
            ]),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'ほしぞら分布',
            child: SizedBox(
              height: 160,
              child: CustomPaint(
                painter: _StarfieldPainter(dist, demoCurrent[axis]),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _biggestGap() {
    var best = 0;
    for (var i = 1; i < axes.length; i++) {
      if (demoIdeal[i] - demoCurrent[i] >
          demoIdeal[best] - demoCurrent[best]) {
        best = i;
      }
    }
    return best;
  }

  String _baselineLabel(AxisDistribution d) =>
      d.isTheoretical ? '想定との比較・目安' : 'みんなとの比較 n=${d.n}';

  String _percentileText(double pct) {
    final top = (100 - pct).round();
    if ((pct - 50).abs() < 8) return 'ほぼ平均だよ';
    return pct >= 50 ? '上位 $top% くらいの傾向' : 'じっくりタイプ（上位 $top%）';
  }

  Widget _radar() {
    RadarDataSet set(List<double> v, Color c, {bool fill = true}) =>
        RadarDataSet(
          dataEntries: [for (final x in v) RadarEntry(value: x)],
          borderColor: c,
          fillColor: fill ? c.withValues(alpha: 0.25) : Colors.transparent,
          entryRadius: 2,
          borderWidth: 2,
        );
    return SizedBox(
      height: 260,
      child: RadarChart(RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 4,
        ticksTextStyle: const TextStyle(fontSize: 0),
        getTitle: (i, _) => RadarChartTitle(text: axes[i]),
        titleTextStyle: const TextStyle(fontSize: 12),
        dataSets: [
          set([for (final d in demoTheory) d.mean], _lavender, fill: false),
          set(demoIdeal, _mint),
          set(demoCurrent, _pink),
        ],
      )),
    );
  }

  Widget _histogram(AxisDistribution d) {
    final h = d.histogram();
    final mine = (demoCurrent[axis] ~/ 10).clamp(0, 9);
    return BarChart(BarChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) => Text('${v.toInt() * 10}',
                style: const TextStyle(fontSize: 10)),
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < 10; i++)
          BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: h[i],
              width: 16,
              borderRadius: BorderRadius.circular(8),
              color: i == mine ? _pink : _lavender.withValues(alpha: 0.5),
            ),
          ]),
      ],
    ));
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
        const Text('🐱', style: TextStyle(fontSize: 40)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(text),
          ),
        ),
      ]);
}

/// 集団を小さな星、自分を光る星で描く（個人は特定されない擬似サンプル）
class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter(this.dist, this.mine);
  final AxisDistribution dist;
  final double mine;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(7);
    final paint = Paint()..color = _lavender.withValues(alpha: 0.6);
    for (var i = 0; i < 120; i++) {
      // Box-Muller で分布に沿った擬似サンプル
      final u1 = rnd.nextDouble().clamp(1e-6, 1.0), u2 = rnd.nextDouble();
      final z = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
      final v = (dist.mean + z * dist.sd).clamp(0, 100);
      canvas.drawCircle(
        Offset(v / 100 * size.width, rnd.nextDouble() * size.height),
        2 + rnd.nextDouble() * 2,
        paint,
      );
    }
    final c = Offset(mine / 100 * size.width, size.height / 2);
    canvas.drawCircle(c, 14, Paint()..color = _pink.withValues(alpha: 0.3));
    canvas.drawCircle(c, 7, Paint()..color = _pink);
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) =>
      old.dist != dist || old.mine != mine;
}
