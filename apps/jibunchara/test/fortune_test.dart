import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/fortune.dart';
import 'package:jibunchara/user_profile.dart';

void main() {
  const profile = UserProfile(
    mbti: 'INFP',
    birthMonth: 3,
    birthDay: 25,
    bloodType: BloodType.a,
  );
  final day = DateTime(2026, 10, 21);

  test('同じ日・同じプロフィールなら同じ結果', () {
    final a = fortuneFor(profile, day);
    final b = fortuneFor(profile, day);
    expect(a.stars, b.stars);
    expect(a.message, b.message);
    expect(a.luckyColor, b.luckyColor);
    expect(a.advice, b.advice);
  });

  test('星は2〜5で、1は出ない（30日分・全タイプで確認）', () {
    for (final mbti in ['INFP', 'ENTJ', 'ISTJ', 'ESFP']) {
      for (var i = 0; i < 30; i++) {
        final f = fortuneFor(
            UserProfile(mbti: mbti), DateTime(2026, 10, 1 + i % 28));
        expect(f.stars, inInclusiveRange(2, 5));
      }
    }
  });

  test('日が変わると内容が変わる（30日で星が3種類以上）', () {
    final stars = <int>{};
    final messages = <String>{};
    for (var i = 0; i < 30; i++) {
      final f = fortuneFor(profile, DateTime(2026, 9, 1 + i));
      stars.add(f.stars);
      messages.add(f.message);
    }
    expect(stars.length, greaterThanOrEqualTo(3));
    expect(messages.length, greaterThan(2));
  });

  test('プロフィールが違えば結果も変わりうる', () {
    final results = <String>{};
    for (final m in ['INFP', 'ENTJ', 'ISTJ', 'ESFP', 'INTP', 'ENFJ']) {
      final f = fortuneFor(UserProfile(mbti: m), day);
      results.add('${f.stars}${f.luckyColor}${f.luckyItem}${f.advice}');
    }
    expect(results.length, greaterThan(1));
  });

  test('星座・血液型が無ければ傾向の一言は空、あれば入る', () {
    expect(fortuneFor(const UserProfile(), day).traitLine, isEmpty);
    expect(fortuneFor(profile, day).traitLine, isNotEmpty);
  });

  test('全ての項目が空でなく、不安をあおる語を含まない', () {
    for (var i = 0; i < 60; i++) {
      final f = fortuneFor(profile, DateTime(2026, 1, 1 + i));
      for (final t in [f.message, f.luckyColor, f.luckyItem, f.advice]) {
        expect(t, isNotEmpty);
        expect(t, isNot(contains('最悪')));
        expect(t, isNot(contains('凶')));
      }
    }
  });

  test('全12星座・4血液型の一言が定義されている', () {
    for (final z in Zodiac.values) {
      final p = UserProfile(birthMonth: _monthOf(z), birthDay: _dayOf(z));
      expect(p.zodiac, z);
      expect(fortuneFor(p, day).traitLine, isNotEmpty);
    }
    for (final b in BloodType.values) {
      expect(fortuneFor(UserProfile(bloodType: b), day).traitLine, isNotEmpty);
    }
  });
}

// 各星座の代表的な月日（星座の範囲内）
int _monthOf(Zodiac z) => const {
      Zodiac.aries: 4,
      Zodiac.taurus: 5,
      Zodiac.gemini: 6,
      Zodiac.cancer: 7,
      Zodiac.leo: 8,
      Zodiac.virgo: 9,
      Zodiac.libra: 10,
      Zodiac.scorpio: 11,
      Zodiac.sagittarius: 12,
      Zodiac.capricorn: 1,
      Zodiac.aquarius: 2,
      Zodiac.pisces: 3,
    }[z]!;

int _dayOf(Zodiac z) => z == Zodiac.capricorn ? 5 : 1;
