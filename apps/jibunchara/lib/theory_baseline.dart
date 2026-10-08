import 'stats_model.dart';

/// 理論基準（初期値）。実測が n >= minGroupSize に達するまでの「設計上の目安」。
/// 軸順は stats_model.dart の `axes` と同じ:
/// 社交性・計画性・行動力・感受性・自信・安定感
const _baseMean = [50.0, 52.0, 55.0, 60.0, 48.0, 50.0];
const _baseSd = [15.0, 14.0, 15.0, 13.0, 16.0, 14.0];

/// MBTI各文字による平均の加算補正（軸順は上と同じ）
const _letterShift = <String, List<double>>{
  'E': [12, 0, 4, 0, 0, 0],
  'I': [-12, 0, -2, 0, 0, 0],
  'S': [0, 3, 0, -4, 0, 3],
  'N': [0, -2, 0, 4, 0, 0],
  'T': [0, 0, 0, -6, 5, 0],
  'F': [0, 0, 0, 10, 0, -3],
  'J': [0, 12, 0, 0, 0, 5],
  'P': [0, -12, 3, 0, 0, 0],
};

/// 例: `theoreticalDistribution('INFP', 3)`（感受性）
AxisDistribution theoreticalDistribution(String mbti, int axisIndex) {
  assert(mbti.length == 4 && axisIndex >= 0 && axisIndex < axes.length);
  var mean = _baseMean[axisIndex];
  for (final ch in mbti.toUpperCase().split('')) {
    mean += _letterShift[ch]![axisIndex];
  }
  return AxisDistribution(
    mean: mean.clamp(15, 85).toDouble(),
    sd: _baseSd[axisIndex],
    n: 0,
    isTheoretical: true,
  );
}

List<AxisDistribution> theoreticalProfile(String mbti) => [
      for (var i = 0; i < axes.length; i++) theoreticalDistribution(mbti, i),
    ];
