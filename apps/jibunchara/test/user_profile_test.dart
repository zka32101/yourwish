import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/app_repository.dart';
import 'package:jibunchara/storage.dart';
import 'package:jibunchara/theory_baseline.dart';
import 'package:jibunchara/user_profile.dart';

void main() {
  group('zodiacOf', () {
    test('境界日: 開始日から次の星座', () {
      expect(zodiacOf(3, 20), Zodiac.pisces);
      expect(zodiacOf(3, 21), Zodiac.aries);
      expect(zodiacOf(1, 19), Zodiac.capricorn);
      expect(zodiacOf(1, 20), Zodiac.aquarius);
      expect(zodiacOf(12, 21), Zodiac.sagittarius);
      expect(zodiacOf(12, 22), Zodiac.capricorn);
      expect(zodiacOf(1, 1), Zodiac.capricorn);
      expect(zodiacOf(12, 31), Zodiac.capricorn);
    });

    test('12星座すべてが出る', () {
      final seen = <Zodiac>{};
      for (var m = 1; m <= 12; m++) {
        for (var d = 1; d <= daysInMonth(m); d++) {
          seen.add(zodiacOf(m, d)!);
        }
      }
      expect(seen.length, 12);
    });

    test('存在しない日付は null', () {
      expect(zodiacOf(2, 30), isNull);
      expect(zodiacOf(4, 31), isNull);
      expect(zodiacOf(13, 1), isNull);
      expect(zodiacOf(0, 1), isNull);
      expect(zodiacOf(2, 29), Zodiac.pisces);
    });
  });

  group('UserProfile', () {
    test('MBTI の形式チェック', () {
      expect(isValidMbti('INFP'), isTrue);
      expect(isValidMbti('XNFP'), isFalse);
      expect(isValidMbti('infp'), isFalse);
      expect(isValidMbti('INF'), isFalse);
    });

    test('JSON で往復できる', () {
      const p = UserProfile(
        name: 'レオ',
        mbti: 'ENTJ',
        element: 'fire',
        birthMonth: 8,
        birthDay: 1,
        bloodType: BloodType.ab,
      );
      final back = UserProfile.fromJson(p.toJson())!;
      expect(back.name, 'レオ');
      expect(back.mbti, 'ENTJ');
      expect(back.zodiac, Zodiac.leo);
      expect(back.bloodType, BloodType.ab);
    });

    test('不正なデータは null、日付だけ不正なら日付だけ捨てる', () {
      expect(UserProfile.fromJson('x'), isNull);
      expect(
          UserProfile.fromJson({'name': '', 'mbti': 'INFP', 'element': 'fire'}),
          isNull);
      expect(
          UserProfile.fromJson({'name': 'a', 'mbti': 'ZZZZ', 'element': 'fire'}),
          isNull);
      expect(
          UserProfile.fromJson({'name': 'a', 'mbti': 'INFP', 'element': '?'}),
          isNull);
      final p = UserProfile.fromJson({
        'name': 'a',
        'mbti': 'INFP',
        'element': 'fire',
        'birthMonth': 2,
        'birthDay': 31,
      })!;
      expect(p.birthMonth, isNull);
      expect(p.zodiac, isNull);
    });

    test('copyWith: 省略は維持、null 指定でクリア', () {
      const p = UserProfile(birthMonth: 5, birthDay: 5, bloodType: BloodType.a);
      expect(p.copyWith(name: 'x').birthMonth, 5);
      expect(p.copyWith(birthMonth: null, birthDay: null).zodiac, isNull);
      expect(p.copyWith(bloodType: null).bloodType, isNull);
    });

    test('相棒プロフィールへ変換でき、タイプで理論基準が変わる', () {
      const e = UserProfile(mbti: 'ENFP');
      const i = UserProfile(mbti: 'INFP');
      expect(e.toCompanion().mbti, 'ENFP');
      expect(theoreticalProfile(e.mbti)[0].mean,
          greaterThan(theoreticalProfile(i.mbti)[0].mean));
    });
  });

  group('AppRepository のプロフィール', () {
    test('保存して復元できる。未保存・破損は null', () async {
      final store = MemoryStore();
      final repo = AppRepository(store);
      expect(await repo.loadProfile(), isNull);

      await repo.saveProfile(const UserProfile(name: 'ミント', mbti: 'ISTJ'));
      final back = (await repo.loadProfile())!;
      expect(back.name, 'ミント');
      expect(back.mbti, 'ISTJ');

      await store.write('profile_v1', '{broken');
      expect(await repo.loadProfile(), isNull);
    });
  });
}
