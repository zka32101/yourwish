import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/notification_picker.dart';
import 'package:jibunchara/notification_prefs.dart';

void main() {
  const infp = CompanionProfile(name: 'ミルク', mbti: 'INFP', element: 'water');
  const entj = CompanionProfile(name: 'レオ', mbti: 'ENTJ', element: 'fire');
  final mon = DateTime(2026, 10, 5); // 月曜
  final sat = DateTime(2026, 10, 10); // 土曜

  group('NotifPrefs', () {
    test('平日のみは土日に送らない', () {
      const p = NotifPrefs(frequency: NotifFrequency.weekdays);
      expect(p.shouldSendOn(mon), isTrue);
      expect(p.shouldSendOn(sat), isFalse);
    });

    test('週3は月水金のみ', () {
      const p = NotifPrefs(frequency: NotifFrequency.threePerWeek);
      expect(p.shouldSendOn(mon), isTrue);
      expect(p.shouldSendOn(DateTime(2026, 10, 6)), isFalse);
    });

    test('休む曜日は送らない', () {
      const p = NotifPrefs(restDays: {DateTime.monday});
      expect(p.shouldSendOn(mon), isFalse);
    });

    test('時間帯は上限3件まで・朝から順に残す', () {
      const p = NotifPrefs(slots: {...NotifSlot.values});
      expect(p.effectiveSlots(), [
        NotifSlot.morning,
        NotifSlot.noon,
        NotifSlot.evening,
      ]);
    });
  });

  group('pickMessage', () {
    test('同じ入力なら同じ結果', () {
      final a = pickMessage(
          kind: NotifKind.action, tone: NotifTone.gentle, profile: infp, day: mon);
      final b = pickMessage(
          kind: NotifKind.action, tone: NotifTone.gentle, profile: infp, day: mon);
      expect(a.id, b.id);
    });

    test('直近に使った文面は除外される', () {
      final first = pickMessage(
          kind: NotifKind.action, tone: NotifTone.gentle, profile: infp, day: mon);
      final second = pickMessage(
          kind: NotifKind.action,
          tone: NotifTone.gentle,
          profile: infp,
          day: mon,
          recentIds: {first.id});
      expect(second.id, isNot(first.id));
    });

    test('全て除外済みでも文面を返す', () {
      final m = pickMessage(
          kind: NotifKind.mood,
          tone: NotifTone.cool,
          profile: infp,
          day: mon,
          recentIds: {'moo_c_1', 'moo_c_2', 'moo_c_3'});
      expect(m.body, isNotEmpty);
    });

    test('タイプ限定文面は該当しないタイプに出ない', () {
      for (var d = 1; d <= 28; d++) {
        final m = pickMessage(
            kind: NotifKind.action,
            tone: NotifTone.energetic,
            profile: infp, // E を持たない
            day: DateTime(2026, 10, d));
        expect(m.id, isNot('act_e_2'));
      }
    });

    test('名前が差し込まれ、タイトルにタイプが入る', () {
      final m = pickMessage(
          kind: NotifKind.action,
          tone: NotifTone.energetic,
          profile: entj,
          day: mon,
          recentIds: {'act_e_1', 'act_e_3'});
      expect(m.id, 'act_e_2');
      expect(m.body, contains('レオ'));
      expect(m.title, 'レオ（ENTJ）');
    });

    test('全種類×全トーンで文面が取得できる', () {
      for (final k in NotifKind.values) {
        for (final t in NotifTone.values) {
          final m = pickMessage(kind: k, tone: t, profile: infp, day: mon);
          expect(m.body, isNotEmpty);
        }
      }
    });
  });
}
