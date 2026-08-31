import 'package:shared_preferences/shared_preferences.dart';

class DailyBonusService {
  final SharedPreferences prefs;

  static const _keyLastLoginDate = 'daily_bonus_last_login';
  static const _keyLoginStreak = 'daily_bonus_streak';
  static const _keyTotalLogins = 'daily_bonus_total_logins';

  DailyBonusService(this.prefs);

  /// 今日のログインボーナスをチェック＆更新
  /// - 初回ログイン: gold=100, exp=50
  /// - ストリーク継続: gold=50, exp=25 + ストリークボーナス
  Future<DailyBonusResult> checkAndClaimDailyBonus() async {
    final today = DateTime.now();
    final todayStr = _dateToString(today);
    final lastLoginStr = prefs.getString(_keyLastLoginDate) ?? '';

    final lastLogin = lastLoginStr.isNotEmpty ? _stringToDate(lastLoginStr) : null;
    final isToday = lastLogin != null && _isSameDay(lastLogin, today);

    // 既に今日ボーナスを取得した場合
    if (isToday) {
      return DailyBonusResult.alreadyClaimed();
    }

    int streak = prefs.getInt(_keyLoginStreak) ?? 0;
    int totalLogins = prefs.getInt(_keyTotalLogins) ?? 0;

    // 前日の続きかチェック
    final isStreakContinue = lastLogin != null &&
        _daysBetween(lastLogin, today) == 1;

    if (isStreakContinue) {
      streak++; // ストリーク継続
    } else {
      streak = 1; // ストリークリセット
    }

    totalLogins++;

    // ボーナス計算
    final baseGold = 50;
    final baseExp = 25;
    final streakBonus = (streak ~/ 7) * 10; // 7日ごとに10 gold追加
    final totalGold = baseGold + streakBonus;
    final totalExp = baseExp + (streak > 3 ? 10 : 0); // 3日以上: +10 exp

    // 保存
    await prefs.setString(_keyLastLoginDate, todayStr);
    await prefs.setInt(_keyLoginStreak, streak);
    await prefs.setInt(_keyTotalLogins, totalLogins);

    return DailyBonusResult(
      claimed: true,
      gold: totalGold,
      exp: totalExp,
      streak: streak,
      totalLogins: totalLogins,
    );
  }

  /// ストリーク情報取得
  int getLoginStreak() => prefs.getInt(_keyLoginStreak) ?? 0;
  int getTotalLogins() => prefs.getInt(_keyTotalLogins) ?? 0;

  String _dateToString(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime _stringToDate(String str) => DateTime.parse(str);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _daysBetween(DateTime a, DateTime b) =>
      b.difference(a).inDays;
}

class DailyBonusResult {
  final bool claimed;
  final int gold;
  final int exp;
  final int streak;
  final int totalLogins;

  DailyBonusResult({
    required this.claimed,
    required this.gold,
    required this.exp,
    required this.streak,
    required this.totalLogins,
  });

  factory DailyBonusResult.alreadyClaimed() =>
      DailyBonusResult(
        claimed: false,
        gold: 0,
        exp: 0,
        streak: 0,
        totalLogins: 0,
      );
}
