import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geography_puzzle_king/models/hq_upgrade_model.dart';

class HqUpgradeService {
  static const _levelsKey = 'hq_upgrade_levels_v1';
  static const _pointsKey = 'hq_research_points_v1';

  final SharedPreferences _prefs;
  HqUpgradeService(this._prefs);

  HqUpgradeState load() {
    final raw = _prefs.getString(_levelsKey);
    final points = _prefs.getInt(_pointsKey) ?? 0;
    if (raw == null) {
      return HqUpgradeState.initial().copyWith(researchPoints: points);
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final levels = <HqUpgradeTrack, int>{
        for (final t in HqUpgradeTrack.values) t: (decoded[t.name] as int?) ?? 0,
      };
      return HqUpgradeState(levels: levels, researchPoints: points);
    } catch (_) {
      return HqUpgradeState.initial().copyWith(researchPoints: points);
    }
  }

  Future<void> _save(HqUpgradeState state) async {
    final encoded = jsonEncode({
      for (final e in state.levels.entries) e.key.name: e.value,
    });
    await _prefs.setString(_levelsKey, encoded);
    await _prefs.setInt(_pointsKey, state.researchPoints);
  }

  /// クリア報酬として研究ポイントを加算
  Future<HqUpgradeState> addResearchPoints(HqUpgradeState current, int amount) async {
    final updated = current.copyWith(
      researchPoints: current.researchPoints + amount,
    );
    await _save(updated);
    return updated;
  }

  /// 指定トラックを1レベル強化（ポイント不足・最大到達なら変化なし）
  Future<HqUpgradeState> upgrade(HqUpgradeState current, HqUpgradeTrack track) async {
    final level = current.levelOf(track);
    if (level >= HqUpgradeTrackX.maxLevel) return current;
    final cost = track.costForLevel(level);
    if (current.researchPoints < cost) return current;

    final newLevels = Map<HqUpgradeTrack, int>.from(current.levels);
    newLevels[track] = level + 1;
    final updated = current.copyWith(
      levels: newLevels,
      researchPoints: current.researchPoints - cost,
    );
    await _save(updated);
    return updated;
  }
}
