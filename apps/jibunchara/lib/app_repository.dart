import 'dart:convert';

import 'growth.dart';
import 'notification_prefs.dart';
import 'storage.dart';
import 'streak.dart';

String _fmt(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? _parse(Object? v) => v is String ? DateTime.tryParse(v) : null;

Set<DateTime> _dates(Object? v) {
  if (v is! List) return <DateTime>{};
  return {
    for (final e in v)
      if (_parse(e) != null) _parse(e)!,
  };
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

/// 連続記録と通知設定の保存・読み込み。保存データが壊れていても初期値で起動する。
class AppRepository {
  AppRepository(this._store);
  final KeyValueStore _store;

  static const _streakKey = 'streak_v1';
  static const _prefsKey = 'notif_prefs_v1';
  static const _growthKey = 'growth_v1';

  Future<StreakState> loadStreak() async {
    try {
      final raw = await _store.read(_streakKey);
      if (raw == null) return StreakState();
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return StreakState(
        completed: _dates(m['completed']),
        rested: _dates(m['rested']),
      );
    } catch (_) {
      return StreakState();
    }
  }

  Future<void> saveStreak(StreakState s) => _store.write(
        _streakKey,
        jsonEncode({
          'completed': (s.completed.toList()..sort()).map(_fmt).toList(),
          'rested': (s.rested.toList()..sort()).map(_fmt).toList(),
        }),
      );

  Future<NotifPrefs> loadPrefs() async {
    try {
      final raw = await _store.read(_prefsKey);
      if (raw == null) return const NotifPrefs();
      final m = jsonDecode(raw) as Map<String, dynamic>;
      const d = NotifPrefs();
      return NotifPrefs(
        slots: {
          for (final e in (m['slots'] as List? ?? d.slots.map((s) => s.name)))
            _enumByName(NotifSlot.values, e, NotifSlot.morning),
        },
        kinds: {
          for (final e in (m['kinds'] as List? ?? d.kinds.map((k) => k.name)))
            _enumByName(NotifKind.values, e, NotifKind.action),
        },
        tone: _enumByName(NotifTone.values, m['tone'], d.tone),
        frequency:
            _enumByName(NotifFrequency.values, m['frequency'], d.frequency),
        restDays: {
          for (final e in (m['restDays'] as List? ?? const []))
            if (e is int && e >= 1 && e <= 7) e,
        },
      );
    } catch (_) {
      return const NotifPrefs();
    }
  }

  Future<void> savePrefs(NotifPrefs p) => _store.write(
        _prefsKey,
        jsonEncode({
          'slots': p.slots.map((e) => e.name).toList(),
          'kinds': p.kinds.map((e) => e.name).toList(),
          'tone': p.tone.name,
          'frequency': p.frequency.name,
          'restDays': p.restDays.toList()..sort(),
        }),
      );

  Future<GrowthState> loadGrowth() async {
    try {
      final raw = await _store.read(_growthKey);
      if (raw == null) return const GrowthState();
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final xp = m['totalXp'];
      final claimed = m['claimed'];
      return GrowthState(
        totalXp: xp is int && xp >= 0 ? xp : 0,
        claimed: claimed is List
            ? {for (final e in claimed) if (e is String) e}
            : <String>{},
      );
    } catch (_) {
      return const GrowthState();
    }
  }

  Future<void> saveGrowth(GrowthState g) => _store.write(
        _growthKey,
        jsonEncode({
          'totalXp': g.totalXp,
          'claimed': g.claimed.toList()..sort(),
        }),
      );
}
