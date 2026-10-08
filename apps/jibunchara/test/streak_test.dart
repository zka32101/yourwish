import 'package:flutter_test/flutter_test.dart';
import 'package:jibunchara/streak.dart';

void main() {
  final today = DateTime(2026, 10, 8); // 木曜
  DateTime ago(int n) => DateTime(2026, 10, 8 - n);

  test('記録なしは0', () {
    expect(StreakState().currentStreak(today), 0);
  });

  test('今日と昨日を達成していれば2', () {
    final s = StreakState(completed: {today, ago(1)});
    expect(s.currentStreak(today), 2);
  });

  test('今日が未達成でも昨日までの連続は維持される', () {
    final s = StreakState(completed: {ago(1), ago(2), ago(3)});
    expect(s.currentStreak(today), 3);
  });

  test('1日空くと連続は途切れる', () {
    final s = StreakState(completed: {today, ago(2), ago(3)});
    expect(s.currentStreak(today), 1);
  });

  test('おやすみカードの日は連続を途切れさせない', () {
    final s = StreakState(completed: {today, ago(2), ago(3)})
        .useRestCard(ago(1), today);
    expect(s.currentStreak(today), 4);
  });

  test('月のおやすみカードは2枚まで', () {
    var s = StreakState();
    s = s.useRestCard(ago(1), today).useRestCard(ago(2), today);
    expect(s.restCardsLeft(today), 0);
    expect(s.canUseRestCard(ago(3), today), isFalse);
    expect(s.useRestCard(ago(3), today).rested.length, 2);
  });

  test('未来日・達成済みの日にはカードを使えない', () {
    final s = StreakState(completed: {today});
    expect(s.canUseRestCard(DateTime(2026, 10, 9), today), isFalse);
    expect(s.canUseRestCard(today, today), isFalse);
  });

  test('月をまたぐとカードは別枠', () {
    final s = StreakState(rested: {DateTime(2026, 9, 28), DateTime(2026, 9, 29)});
    expect(s.canUseRestCard(ago(1), today), isTrue);
    expect(s.restCardsLeft(today), 2);
  });

  test('月またぎでも連続を数えられる', () {
    final s = StreakState(completed: {
      DateTime(2026, 9, 30),
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 2),
    });
    expect(s.currentStreak(DateTime(2026, 10, 2)), 3);
  });

  test('週5日で週間達成（おやすみ日は含めない）', () {
    // 2026-10-05(月)〜
    final s = StreakState(
      completed: {
        DateTime(2026, 10, 5),
        DateTime(2026, 10, 6),
        DateTime(2026, 10, 7),
        DateTime(2026, 10, 8),
      },
      rested: {DateTime(2026, 10, 9)},
    );
    expect(s.daysCompletedInWeek(today), 4);
    expect(s.weeklyGoalAchieved(today), isFalse);
    expect(s.markCompleted(DateTime(2026, 10, 10)).weeklyGoalAchieved(today),
        isTrue);
  });
}
