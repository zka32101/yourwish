import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/notification_picker.dart';
import 'package:jibunchara/notification_prefs.dart';
import 'package:jibunchara/notification_scheduler.dart';

const _profile = CompanionProfile(name: 'ミルク', mbti: 'INFP', element: 'water');

void main() {
  // 2026-10-20 は火曜
  final from = DateTime(2026, 10, 20, 7, 0);

  test('朝・夜の設定で7日分14件（過去の時刻は含まない）', () {
    final plan = planSchedule(
        prefs: const NotifPrefs(), profile: _profile, from: from, days: 7);
    expect(plan.length, 14);
    expect(plan.every((n) => n.when.isAfter(from)), isTrue);
  });

  test('今日の朝の時刻を過ぎていれば今日の朝は含まない', () {
    final plan = planSchedule(
        prefs: const NotifPrefs(),
        profile: _profile,
        from: DateTime(2026, 10, 20, 9, 0),
        days: 1);
    expect(plan.map((n) => n.slot), [NotifSlot.night]);
  });

  test('平日のみなら土日は予定しない', () {
    final plan = planSchedule(
        prefs: const NotifPrefs(frequency: NotifFrequency.weekdays),
        profile: _profile,
        from: from,
        days: 7);
    expect(plan.any((n) => n.when.weekday >= DateTime.saturday), isFalse);
  });

  test('休む曜日は予定しない', () {
    final plan = planSchedule(
        prefs: const NotifPrefs(restDays: {DateTime.wednesday}),
        profile: _profile,
        from: from,
        days: 7);
    expect(plan.any((n) => n.when.weekday == DateTime.wednesday), isFalse);
  });

  test('1日の上限は3件', () {
    final plan = planSchedule(
        prefs: const NotifPrefs(slots: {...NotifSlot.values}),
        profile: _profile,
        from: from,
        days: 1);
    expect(plan.length, lessThanOrEqualTo(maxNotifsPerDay));
    expect(plan.map((n) => n.slot), isNot(contains(NotifSlot.night)));
  });

  test('週のふりかえりは日曜だけ', () {
    final plan = planSchedule(
        prefs: const NotifPrefs(kinds: {NotifKind.weeklyReview}),
        profile: _profile,
        from: from,
        days: 7);
    expect(plan, isNotEmpty);
    expect(plan.every((n) => n.when.weekday == DateTime.sunday), isTrue);
  });

  test('内容は時間帯ごとに順番に回る', () {
    final plan = planSchedule(
        prefs: const NotifPrefs(kinds: {NotifKind.fortune, NotifKind.mood}),
        profile: _profile,
        from: from,
        days: 1);
    expect(plan.length, 2);
    expect(plan[0].kind, isNot(plan[1].kind));
  });

  test('通知IDは日付と時間帯で一意', () {
    final plan = planSchedule(
        prefs: const NotifPrefs(slots: {NotifSlot.morning, NotifSlot.night}),
        profile: _profile,
        from: from,
        days: 7);
    expect(plan.map((n) => n.id).toSet().length, plan.length);
  });

  test('同じ入力なら同じ計画（決定論的）', () {
    final a = planSchedule(
        prefs: const NotifPrefs(), profile: _profile, from: from);
    final b = planSchedule(
        prefs: const NotifPrefs(), profile: _profile, from: from);
    expect(a.map((n) => n.message.id), b.map((n) => n.message.id));
  });

  test('時間帯または内容が空なら予定なし', () {
    expect(
        planSchedule(
            prefs: const NotifPrefs(slots: {}), profile: _profile, from: from),
        isEmpty);
    expect(
        planSchedule(
            prefs: const NotifPrefs(kinds: {}), profile: _profile, from: from),
        isEmpty);
  });

  test('reschedule は全消去してから登録し、失敗してもfalseを返すだけ', () async {
    final ok = _FakeScheduler();
    final plan = planSchedule(
        prefs: const NotifPrefs(), profile: _profile, from: from, days: 2);
    expect(await reschedule(ok, plan), isTrue);
    expect(ok.log.first, 'cancelAll');
    expect(ok.log.length, plan.length + 1);

    expect(await reschedule(_FakeScheduler(fail: true), plan), isFalse);
  });
}

class _FakeScheduler implements NotificationScheduler {
  _FakeScheduler({this.fail = false});
  final bool fail;
  final log = <String>[];

  @override
  Future<void> cancelAll() async => log.add('cancelAll');

  @override
  Future<void> schedule(PlannedNotification n) async {
    if (fail) throw Exception('native error');
    log.add('schedule ${n.id}');
  }
}
