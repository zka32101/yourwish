import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/storage.dart';
import 'package:jibunchara/streak.dart';
import 'package:jibunchara/widget_snapshot.dart';
import 'package:jibunchara/widget_sync.dart';

void main() {
  final day = DateTime(2026, 10, 20);
  DateTime at(int h) => DateTime(2026, 10, 20, h);
  DateTime ago(int n) => DateTime(2026, 10, 20 - n);

  test('今日達成なら笑顔', () {
    expect(decideMood(StreakState(completed: {day}), at(9)),
        CompanionMood.happy);
  });

  test('今日おやすみカードなら休み', () {
    expect(decideMood(StreakState(rested: {day}), at(9)),
        CompanionMood.resting);
  });

  test('未達成は夕方前は待機、夕方以降はそわそわ', () {
    final s = StreakState(completed: {ago(1)});
    expect(decideMood(s, at(10)), CompanionMood.waiting);
    expect(decideMood(s, at(restlessFromHour)), CompanionMood.restless);
  });

  test('3日以上空くとさみしそう（責めない表現）', () {
    final s = StreakState(completed: {ago(3)});
    expect(decideMood(s, at(10)), CompanionMood.lonely);
    expect(buildSnapshot(s, at(10)).line, isNot(contains('リセット')));
  });

  test('記録なしでもさみしそうで落ちない', () {
    expect(decideMood(StreakState(), at(10)), CompanionMood.lonely);
  });

  test('2日空きまでは待機', () {
    final s = StreakState(completed: {ago(2)});
    expect(decideMood(s, at(10)), CompanionMood.waiting);
  });

  test('スナップショットに連続日数と週進捗が入る', () {
    final s = StreakState(completed: {day, ago(1)});
    final snap = buildSnapshot(s, at(9));
    expect(snap.streakDays, 2);
    expect(snap.weekGoal, weeklyGoalDays);
    expect(snap.toMap()['mood'], 'happy');
  });

  test('syncWidget はJSONを書き込み、失敗してもfalseを返すだけ', () async {
    final store = MemoryStore();
    final ok = await syncWidget(
        StoreWidgetSink(store), StreakState(completed: {day}), at(9));
    expect(ok, isTrue);
    final json = jsonDecode((await store.read(StoreWidgetSink.key))!);
    expect(json['mood'], 'happy');

    final bad = await syncWidget(_FailingSink(), StreakState(), at(9));
    expect(bad, isFalse);
  });
}

class _FailingSink implements WidgetSink {
  @override
  Future<void> push(String json) async => throw Exception('native error');
}
