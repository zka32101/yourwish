import 'notification_picker.dart';

/// プロフィール（端末内のみに保存。誕生日は月日だけ、年は持たない）。
enum BloodType { a, b, o, ab }

enum Zodiac {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces,
}

const zodiacLabels = <Zodiac, String>{
  Zodiac.aries: 'おひつじ座',
  Zodiac.taurus: 'おうし座',
  Zodiac.gemini: 'ふたご座',
  Zodiac.cancer: 'かに座',
  Zodiac.leo: 'しし座',
  Zodiac.virgo: 'おとめ座',
  Zodiac.libra: 'てんびん座',
  Zodiac.scorpio: 'さそり座',
  Zodiac.sagittarius: 'いて座',
  Zodiac.capricorn: 'やぎ座',
  Zodiac.aquarius: 'みずがめ座',
  Zodiac.pisces: 'うお座',
};

const bloodLabels = <BloodType, String>{
  BloodType.a: 'A型',
  BloodType.b: 'B型',
  BloodType.o: 'O型',
  BloodType.ab: 'AB型',
};

/// 属性（見た目・演出用）。値は [CompanionProfile.element] と同じ。
const elementLabels = <String, String>{
  'fire': '火',
  'wind': '風',
  'earth': '土',
  'water': '水',
};

const _daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

int daysInMonth(int month) => _daysInMonth[month - 1];

bool isValidMbti(String s) => RegExp(r'^[EI][SN][TF][JP]$').hasMatch(s);

// (月, 開始日, 星座)。1/1〜1/19 は山羊座。
const _zodiacStarts = <(int, int, Zodiac)>[
  (1, 20, Zodiac.aquarius),
  (2, 19, Zodiac.pisces),
  (3, 21, Zodiac.aries),
  (4, 20, Zodiac.taurus),
  (5, 21, Zodiac.gemini),
  (6, 22, Zodiac.cancer),
  (7, 23, Zodiac.leo),
  (8, 23, Zodiac.virgo),
  (9, 23, Zodiac.libra),
  (10, 24, Zodiac.scorpio),
  (11, 23, Zodiac.sagittarius),
  (12, 22, Zodiac.capricorn),
];

/// 月日から太陽星座を返す。存在しない日付は null。
Zodiac? zodiacOf(int month, int day) {
  if (month < 1 || month > 12 || day < 1 || day > daysInMonth(month)) {
    return null;
  }
  var sign = Zodiac.capricorn;
  for (final (m, d, z) in _zodiacStarts) {
    if (month > m || (month == m && day >= d)) sign = z;
  }
  return sign;
}

class UserProfile {
  const UserProfile({
    this.name = 'ミルク',
    this.mbti = 'INFP',
    this.element = 'water',
    this.birthMonth,
    this.birthDay,
    this.bloodType,
  });

  static const defaults = UserProfile();

  final String name; // 相棒の名前
  final String mbti;
  final String element;
  final int? birthMonth;
  final int? birthDay;
  final BloodType? bloodType;

  Zodiac? get zodiac => birthMonth == null || birthDay == null
      ? null
      : zodiacOf(birthMonth!, birthDay!);

  CompanionProfile toCompanion() =>
      CompanionProfile(name: name, mbti: mbti, element: element);

  UserProfile copyWith({
    String? name,
    String? mbti,
    String? element,
    Object? birthMonth = _keep,
    Object? birthDay = _keep,
    Object? bloodType = _keep,
  }) =>
      UserProfile(
        name: name ?? this.name,
        mbti: mbti ?? this.mbti,
        element: element ?? this.element,
        birthMonth: identical(birthMonth, _keep)
            ? this.birthMonth
            : birthMonth as int?,
        birthDay:
            identical(birthDay, _keep) ? this.birthDay : birthDay as int?,
        bloodType: identical(bloodType, _keep)
            ? this.bloodType
            : bloodType as BloodType?,
      );

  Map<String, Object?> toJson() => {
        'name': name,
        'mbti': mbti,
        'element': element,
        'birthMonth': birthMonth,
        'birthDay': birthDay,
        'bloodType': bloodType?.name,
      };

  /// 不正なデータは null（呼び出し側で初期値にする）。
  static UserProfile? fromJson(Object? json) {
    if (json is! Map) return null;
    final name = json['name'];
    final mbti = json['mbti'];
    final element = json['element'];
    if (name is! String || name.trim().isEmpty || name.length > 10) return null;
    if (mbti is! String || !isValidMbti(mbti)) return null;
    if (element is! String || !elementLabels.containsKey(element)) return null;

    final m = json['birthMonth'];
    final d = json['birthDay'];
    final validDate = m is int && d is int && zodiacOf(m, d) != null;
    BloodType? blood;
    for (final b in BloodType.values) {
      if (b.name == json['bloodType']) blood = b;
    }
    return UserProfile(
      name: name,
      mbti: mbti,
      element: element,
      birthMonth: validDate ? m : null,
      birthDay: validDate ? d : null,
      bloodType: blood,
    );
  }
}

const Object _keep = Object();
