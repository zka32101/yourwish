import 'user_profile.dart';

/// 今日の運勢。同じ日・同じプロフィールなら同じ結果になる（決定論的）。
/// 娯楽と自己理解のきっかけが目的で、断定や不安をあおる表現は使わない。
class Fortune {
  const Fortune({
    required this.stars,
    required this.message,
    required this.traitLine,
    required this.luckyColor,
    required this.luckyItem,
    required this.advice,
  });

  /// 2〜5（1は出さない）
  final int stars;
  final String message;

  /// 星座・血液型・タイプから一言（情報が無ければ空）
  final String traitLine;
  final String luckyColor;
  final String luckyItem;
  final String advice;
}

const _starsPattern = [2, 3, 3, 4, 4, 4, 5, 5, 3, 4];

const _messages = <int, List<String>>{
  2: ['きょうはゆっくり進むのがよさそうな日かも', 'むりをしないで、小さなことから始めるといい日かも'],
  3: ['いつもどおりが心地いい日かも', 'ふつうの日こそ、ちいさな工夫が光るかも'],
  4: ['いい流れに乗れそうな日かも', 'まわりとの会話から、うれしい発見がありそう'],
  5: ['やってみたかったことに一歩ふみ出せそうな日かも', 'いつもの自分より、少しだけ大胆になれそう'],
};

const _zodiacLines = <Zodiac, String>{
  Zodiac.aries: 'おひつじ座らしい行動力が、背中を押してくれそう',
  Zodiac.taurus: 'おうし座らしいマイペースが、安心につながりそう',
  Zodiac.gemini: 'ふたご座らしい好奇心で、新しい発見がありそう',
  Zodiac.cancer: 'かに座らしいやさしさが、まわりをほっとさせそう',
  Zodiac.leo: 'しし座らしい明るさが、場を照らしてくれそう',
  Zodiac.virgo: 'おとめ座らしい丁寧さが、きれいな仕上がりを呼びそう',
  Zodiac.libra: 'てんびん座らしいバランス感覚が、助けになりそう',
  Zodiac.scorpio: 'さそり座らしい集中力が、しっかり力を発揮しそう',
  Zodiac.sagittarius: 'いて座らしい自由な発想が、視野を広げてくれそう',
  Zodiac.capricorn: 'やぎ座らしいコツコツが、あとで効いてきそう',
  Zodiac.aquarius: 'みずがめ座らしいユニークさが、アイデアを生みそう',
  Zodiac.pisces: 'うお座らしい感性が、やさしい気づきをくれそう',
};

const _bloodLines = <BloodType, String>{
  BloodType.a: 'A型の几帳面さを、今日は少しゆるめてもよさそう',
  BloodType.b: 'B型のマイペースを、今日は大切にしてよさそう',
  BloodType.o: 'O型の大らかさが、いい空気をつくりそう',
  BloodType.ab: 'AB型の切り替え上手が、役に立ちそう',
};

const _colors = [
  'ミントグリーン',
  'さくらピンク',
  'ラベンダー',
  'クリームイエロー',
  'そらいろ',
  'ピーチ',
  'ライラック',
  'しろ',
];

const _items = [
  'ハンカチ',
  'ノート',
  'あたたかい飲み物',
  'イヤホン',
  'ちいさなぬいぐるみ',
  'ペン',
  'ふせん',
  'お気に入りの靴下',
];

const _advices = [
  '深呼吸を3回してから始めてみよう',
  '今日のひとつを、朝のうちに終わらせてみよう',
  '「ありがとう」を1回多く言ってみよう',
  '5分だけ外の空気をすってみよう',
  '終わったら、自分をほめてあげよう',
  'うまくいかなくても、ここまでできたことを数えよう',
];

const _modulus = 2147483647;

// Park–Miller 法。掛け算が 2^53 未満に収まるのでWebでも結果が変わらない。
int _next(int x) => (x * 48271) % _modulus;

int _seed(UserProfile p, DateTime day) {
  var code = 0;
  for (final u in p.mbti.codeUnits) {
    code = (code * 7 + u) % 1000003;
  }
  final z = p.zodiac?.index ?? 12;
  final b = p.bloodType?.index ?? 4;
  final dayNum = day.year * 372 + day.month * 31 + day.day;
  var s = (dayNum * 7919 + code * 104729 + z * 1299709 + b * 15485863) %
      _modulus;
  if (s == 0) s = 1;
  // 数回まわして偏りをならす
  for (var i = 0; i < 3; i++) {
    s = _next(s);
  }
  return s;
}

Fortune fortuneFor(UserProfile profile, DateTime day) {
  var s = _seed(profile, day);
  int pick(int n) {
    s = _next(s);
    return s % n;
  }

  final stars = _starsPattern[pick(_starsPattern.length)];
  final msgs = _messages[stars]!;
  final message = msgs[pick(msgs.length)];

  final traits = <String>[
    if (profile.zodiac != null) _zodiacLines[profile.zodiac]!,
    if (profile.bloodType != null) _bloodLines[profile.bloodType]!,
  ];
  final traitLine = traits.isEmpty ? '' : traits[pick(traits.length)];

  return Fortune(
    stars: stars,
    message: message,
    traitLine: traitLine,
    luckyColor: _colors[pick(_colors.length)],
    luckyItem: _items[pick(_items.length)],
    advice: _advices[pick(_advices.length)],
  );
}
