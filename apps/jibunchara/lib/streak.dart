/// 連続記録（責めない設計）。
///
/// - 行動チェックをした日が「達成日」。
/// - 「おやすみカード」を使った日は、達成日と同じく連続を途切れさせない。
/// - 今日がまだ未達成でも、昨日までの連続は維持して表示する。
/// - 週5日以上できたら、その週は達成。
const restCardsPerMonth = 2;
const weeklyGoalDays = 5;

DateTime _d(DateTime t) => DateTime(t.year, t.month, t.day);

class StreakState {
  StreakState({
    Set<DateTime> completed = const {},
    Set<DateTime> rested = const {},
  })  : completed = {for (final d in completed) _d(d)},
        rested = {for (final d in rested) _d(d)};

  final Set<DateTime> completed;
  final Set<DateTime> rested;

  bool _counts(DateTime day) => completed.contains(day) || rested.contains(day);

  StreakState markCompleted(DateTime day) =>
      StreakState(completed: {...completed, _d(day)}, rested: rested);

  /// その月に残っているおやすみカード枚数
  int restCardsLeft(DateTime today) {
    final used = rested
        .where((d) => d.year == today.year && d.month == today.month)
        .length;
    return (restCardsPerMonth - used).clamp(0, restCardsPerMonth);
  }

  /// おやすみカードを使えるか（未来日・達成済み・使用済み・枚数切れは不可）
  bool canUseRestCard(DateTime day, DateTime today) {
    final d = _d(day), t = _d(today);
    if (d.isAfter(t)) return false;
    if (completed.contains(d) || rested.contains(d)) return false;
    final inMonth = rested.where((r) => r.year == d.year && r.month == d.month);
    return inMonth.length < restCardsPerMonth;
  }

  /// 使えない場合は元の状態をそのまま返す
  StreakState useRestCard(DateTime day, DateTime today) {
    if (!canUseRestCard(day, today)) return this;
    return StreakState(completed: completed, rested: {...rested, _d(day)});
  }

  /// 現在の連続日数。今日が未達成なら昨日から数える。
  int currentStreak(DateTime today) {
    var day = _d(today);
    if (!_counts(day)) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (_counts(day)) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }

  /// 指定日を含む週（月〜日）の達成日数（おやすみ日は含めない）
  int daysCompletedInWeek(DateTime anyDayInWeek) {
    final day = _d(anyDayInWeek);
    final monday = DateTime(day.year, day.month, day.day - (day.weekday - 1));
    var n = 0;
    for (var i = 0; i < 7; i++) {
      if (completed.contains(DateTime(monday.year, monday.month, monday.day + i))) {
        n++;
      }
    }
    return n;
  }

  bool weeklyGoalAchieved(DateTime anyDayInWeek) =>
      daysCompletedInWeek(anyDayInWeek) >= weeklyGoalDays;
}
