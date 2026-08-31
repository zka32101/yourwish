import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_level_model.freezed.dart';
part 'player_level_model.g.dart';

@freezed
class PlayerLevel with _$PlayerLevel {
  const factory PlayerLevel({
    required int currentLevel,
    required int totalExp,
    required DateTime lastUpdated,
  }) = _PlayerLevel;

  factory PlayerLevel.fromJson(Map<String, dynamic> json) =>
      _$PlayerLevelFromJson(json);

  /// 初期レベル
  factory PlayerLevel.initial() => PlayerLevel(
    currentLevel: 1,
    totalExp: 0,
    lastUpdated: DateTime.now(),
  );
}

// ─── レベルボーナス計算 ────────────────────────────────────────

class LevelBonus {
  /// 敵HP・ATK倍率 (Lv5: 1.04 = 4% UP)
  static double getStatMultiplier(int level) {
    return 1.0 + ((level - 1) * 0.01);
  }

  /// 初期資金ボーナス (Lv5: +20 gold)
  static int getGoldBonus(int level) {
    return (level - 1) * 5;
  }

  /// 獲得EXP倍率
  static double getExpMultiplier(int level) {
    return 1.0 + ((level - 1) * 0.05);
  }
}

// ─── EXP→レベル計算 ────────────────────────────────────────────

class PlayerLevelCalculator {
  static const int EXP_PER_LEVEL = 100;

  /// totalExp からレベルを計算
  static int calculateLevel(int totalExp) {
    return (totalExp ~/ EXP_PER_LEVEL) + 1;
  }

  /// レベル n に必要な総EXP
  static int getExpForLevel(int level) {
    return (level - 1) * EXP_PER_LEVEL;
  }

  /// 次レベルまでの必要EXP
  static int getExpToNextLevel(int totalExp) {
    final currentLevel = calculateLevel(totalExp);
    final nextThreshold = getExpForLevel(currentLevel + 1);
    return nextThreshold - totalExp;
  }

  /// 現在のレベル内での進度（0-100%）
  static double getLevelProgress(int totalExp) {
    final currentLevel = calculateLevel(totalExp);
    final levelStartExp = getExpForLevel(currentLevel);
    final levelEndExp = getExpForLevel(currentLevel + 1);
    final expInLevel = totalExp - levelStartExp;
    final expRange = levelEndExp - levelStartExp;
    return (expInLevel / expRange).clamp(0.0, 1.0);
  }

  /// レベルアップしたか判定
  static bool didLevelUp(int oldExp, int newExp) {
    return calculateLevel(oldExp) < calculateLevel(newExp);
  }
}
