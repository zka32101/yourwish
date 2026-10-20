import 'growth.dart';
import 'streak.dart';

/// ホーム画面ウィジェットに表示する相棒の表情。
enum CompanionMood { happy, resting, waiting, restless, lonely }

/// 夕方以降（この時刻を過ぎて未達成なら「そわそわ」）
const restlessFromHour = 18;

/// 何日以上お休みが続いたら「さみしそう」にするか
const lonelyAfterDays = 3;

/// ウィジェットへ渡す表示用データ（ネイティブ側はこのJSONだけを読む）。
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.mood,
    required this.stage,
    required this.streakDays,
    required this.weekDays,
    required this.weekGoal,
    required this.line,
  });

  final CompanionMood mood;
  final GrowthStage stage;
  final int streakDays;
  final int weekDays;
  final int weekGoal;
  final String line;

  /// ウィジェットに表示する画像のキー（例: `adult_happy`）。
  /// 画像ファイル名は `<imageKey>.png`（docs/widget_images.md 参照）。
  String get imageKey => '${stage.name}_${mood.name}';

  Map<String, Object> toMap() => {
        'imageKey': imageKey,
        'stage': stage.name,
        'mood': mood.name,
        'streakDays': streakDays,
        'weekDays': weekDays,
        'weekGoal': weekGoal,
        'line': line,
      };
}

const _lines = <CompanionMood, String>{
  CompanionMood.happy: 'きょうもできたね！',
  CompanionMood.resting: 'きょうはゆっくりおやすみ',
  CompanionMood.waiting: 'きょうのひとつ、いっしょにやろう',
  CompanionMood.restless: 'まだだいじょうぶ、ひとつだけやってみる？',
  CompanionMood.lonely: 'また会えるのを、まってるよ',
};

/// 直近の最後の「達成または休み」からの空き日数（今日が達成済みなら0）。
int _daysSinceActive(StreakState s, DateTime today) {
  var day = DateTime(today.year, today.month, today.day);
  for (var i = 0; i < 365; i++) {
    if (s.completed.contains(day) || s.rested.contains(day)) return i;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return 365;
}

/// 責めない表現で表情を決める（連続がリセットされても「さみしそう」止まり）。
CompanionMood decideMood(StreakState s, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  if (s.completed.contains(today)) return CompanionMood.happy;
  if (s.rested.contains(today)) return CompanionMood.resting;
  if (_daysSinceActive(s, today) >= lonelyAfterDays) {
    return CompanionMood.lonely;
  }
  return now.hour >= restlessFromHour
      ? CompanionMood.restless
      : CompanionMood.waiting;
}

WidgetSnapshot buildSnapshot(
  StreakState s,
  DateTime now, {
  GrowthState growth = const GrowthState(),
}) {
  final mood = decideMood(s, now);
  return WidgetSnapshot(
    mood: mood,
    stage: growth.stage,
    streakDays: s.currentStreak(now),
    weekDays: s.daysCompletedInWeek(now),
    weekGoal: weeklyGoalDays,
    line: _lines[mood]!,
  );
}
