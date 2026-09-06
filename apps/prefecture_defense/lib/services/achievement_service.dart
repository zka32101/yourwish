import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prefecture_defense/models/achievement_model.dart';
import 'package:prefecture_defense/models/game_model.dart';

class AchievementService {
  static const _key = 'achievements_v1';
  static const _timestampsKey = 'achievement_timestamps_v1';
  static const _bossKillsKey = 'boss_kills_total';

  final SharedPreferences _prefs;
  AchievementService(this._prefs);

  List<Achievement> loadAchievements() {
    final raw = _prefs.getString(_key);
    if (raw == null) return List.from(allAchievements);
    try {
      final unlocked = Set<String>.from(jsonDecode(raw) as List);
      final timestamps = _loadTimestamps();
      return allAchievements.map((a) {
        final key = a.id.name;
        return a.copyWith(
          isUnlocked: unlocked.contains(key),
          unlockedAt: timestamps[key],
        );
      }).toList();
    } catch (_) {
      return List.from(allAchievements);
    }
  }

  Map<String, DateTime> _loadTimestamps() {
    final raw = _prefs.getString(_timestampsKey);
    if (raw == null) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map((k, v) =>
          MapEntry(k, DateTime.fromMillisecondsSinceEpoch(v as int)));
    } catch (_) {
      return {};
    }
  }

  Future<List<Achievement>> checkAndUnlock({
    required List<Achievement> current,
    required GameSession session,
    required int totalCleared,
    required int hardCleared,
    required int totalBossKills,
    required Set<String> facilitiesUsed,
    bool usedUltimate = false,
    int maxSynergyDirections = 0,
    int criticalCount = 0,
  }) async {
    final toUnlock = <AchievementId>[];

    if (session.isCleared) {
      if (totalCleared >= 1)  toUnlock.add(AchievementId.firstClear);
      if (totalCleared >= 5)  toUnlock.add(AchievementId.clearFive);
      if (totalCleared >= 47) toUnlock.add(AchievementId.clearAll);
      if (hardCleared >= 10)  toUnlock.add(AchievementId.hardMaster);
      if (session.mistakes == 0) toUnlock.add(AchievementId.noMistakes);
      if (session.clearTime <= 180) toUnlock.add(AchievementId.speedRunner);
      // facilityMaster: 全6タイプを使用
      const allTypes = {'farm', 'fishery', 'factory', 'mine', 'castle', 'shrine'};
      if (allTypes.every(facilitiesUsed.contains)) {
        toUnlock.add(AchievementId.facilityMaster);
      }
    }
    if (totalBossKills >= 10) toUnlock.add(AchievementId.bossSlayer);
    if (usedUltimate) toUnlock.add(AchievementId.ultimateUser);
    if (maxSynergyDirections >= 4) toUnlock.add(AchievementId.synergyMaster);
    if (criticalCount >= 10) toUnlock.add(AchievementId.criticalStreak);

    if (toUnlock.isEmpty) return current;

    final updated = current.map((a) {
      if (toUnlock.contains(a.id) && !a.isUnlocked) {
        return a.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return a;
    }).toList();

    // 保存
    final unlockedIds =
        updated.where((a) => a.isUnlocked).map((a) => a.id.name).toList();
    await _prefs.setString(_key, jsonEncode(unlockedIds));

    final timestamps = {
      for (var a in updated.where((a) => a.isUnlocked && a.unlockedAt != null))
        a.id.name: a.unlockedAt!.millisecondsSinceEpoch
    };
    await _prefs.setString(_timestampsKey, jsonEncode(timestamps));

    return updated;
  }

  int getBossKills() => _prefs.getInt(_bossKillsKey) ?? 0;

  Future<void> addBossKills(int n) async {
    await _prefs.setInt(_bossKillsKey, getBossKills() + n);
  }
}
