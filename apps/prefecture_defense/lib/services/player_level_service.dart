import 'package:shared_preferences/shared_preferences.dart';
import 'package:prefecture_defense/models/player_level_model.dart';

class PlayerLevelService {
  final SharedPreferences _prefs;

  PlayerLevelService(this._prefs);

  static const _keyPlayerLevel = 'player_level_v1';
  static const _keyTotalExp = 'player_total_exp_v1';

  // ─── 読み込み・保存 ────────────────────────────────────────

  PlayerLevel loadPlayerLevel() {
    try {
      final level = _prefs.getInt(_keyPlayerLevel) ?? 1;
      final totalExp = _prefs.getInt(_keyTotalExp) ?? 0;
      return PlayerLevel(
        currentLevel: level,
        totalExp: totalExp,
        lastUpdated: DateTime.now(),
      );
    } catch (_) {
      return PlayerLevel.initial();
    }
  }

  Future<void> savePlayerLevel(PlayerLevel level) async {
    await Future.wait([
      _prefs.setInt(_keyPlayerLevel, level.currentLevel),
      _prefs.setInt(_keyTotalExp, level.totalExp),
    ]);
  }

  // ─── EXP追加・レベルアップ ─────────────────────────────────

  /// EXPを追加し、レベルアップ判定を返す
  Future<LevelUpResult> addExperience(int exp) async {
    final current = loadPlayerLevel();
    final oldLevel = current.currentLevel;
    final newTotalExp = current.totalExp + exp;
    final newLevel = PlayerLevelCalculator.calculateLevel(newTotalExp);

    final updated = current.copyWith(
      currentLevel: newLevel,
      totalExp: newTotalExp,
      lastUpdated: DateTime.now(),
    );
    await savePlayerLevel(updated);

    return LevelUpResult(
      previousLevel: oldLevel,
      newLevel: newLevel,
      totalExpGained: exp,
      didLevelUp: oldLevel < newLevel,
      levelUpCount: newLevel - oldLevel,
    );
  }

  // ─── クエリ ─────────────────────────────────────────────────

  /// 次レベルまでの必要EXP
  int getExpToNextLevel() {
    final current = loadPlayerLevel();
    return PlayerLevelCalculator.getExpToNextLevel(current.totalExp);
  }

  /// 現レベル内での進度（0-100%）
  double getLevelProgress() {
    final current = loadPlayerLevel();
    return PlayerLevelCalculator.getLevelProgress(current.totalExp);
  }

  /// ステータスボーナス（敵HP・ATK倍率）
  double getStatMultiplier() {
    final current = loadPlayerLevel();
    return LevelBonus.getStatMultiplier(current.currentLevel);
  }

  /// 初期資金ボーナス
  int getGoldBonus() {
    final current = loadPlayerLevel();
    return LevelBonus.getGoldBonus(current.currentLevel);
  }
}

// ─── レベルアップ結果 ──────────────────────────────────────

class LevelUpResult {
  final int previousLevel;
  final int newLevel;
  final int totalExpGained;
  final bool didLevelUp;
  final int levelUpCount;

  LevelUpResult({
    required this.previousLevel,
    required this.newLevel,
    required this.totalExpGained,
    required this.didLevelUp,
    required this.levelUpCount,
  });

  String get levelUpMessage => 'Lv$previousLevel → Lv$newLevel!';
}
