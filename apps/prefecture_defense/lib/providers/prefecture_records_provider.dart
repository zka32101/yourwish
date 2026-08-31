import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prefecture_record.dart';
import '../utils/prefecture_data.dart' show allPrefectures, getPrefectureByCode;

final prefectureRecordsProvider = AsyncNotifierProvider<
    PrefectureRecordsNotifier,
    Map<String, PrefectureRecord>>(
  PrefectureRecordsNotifier.new,
);

class PrefectureRecordsNotifier
    extends AsyncNotifier<Map<String, PrefectureRecord>> {
  late SharedPreferences _prefs;

  @override
  Future<Map<String, PrefectureRecord>> build() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      return await _loadFromPrefs();
    } catch (e) {
      print('Error initializing prefecture records: $e');
      return {};
    }
  }

  Future<Map<String, PrefectureRecord>> _loadFromPrefs() async {
    final records = <String, PrefectureRecord>{};

    for (final pref in allPrefectures) {
      final json = _prefs.getString('prefecture_record_${pref.code}');
      if (json != null) {
        try {
          records[pref.code] =
              PrefectureRecord.fromJson(jsonDecode(json) as Map<String, dynamic>);
        } catch (e) {
          print('Error loading prefecture record ${pref.code}: $e');
        }
      }
    }

    return records;
  }

  Future<void> recordClear(
    String prefectureCode,
    int score,
    String difficulty,
    int baseExp,
  ) async {
    final now = DateTime.now();
    final currentState = state.valueOrNull ?? {};
    final existing = currentState[prefectureCode];

    final updated = existing != null
        ? existing
            .copyWith(
              totalClears: existing.totalClears + 1,
              lastClearedAt: now,
              bestScore: score > existing.bestScore ? score : existing.bestScore,
              highestDifficulty: _getHighestDifficulty(
                existing.highestDifficulty,
                difficulty,
              ),
            )
            .addExp(baseExp)
        : PrefectureRecord(
            prefectureCode: prefectureCode,
            totalClears: 1,
            currentLevel: 1,
            currentExp: baseExp,
            firstClearedAt: now,
            lastClearedAt: now,
            bestScore: score,
            highestDifficulty: difficulty,
          );

    await _prefs.setString(
      'prefecture_record_$prefectureCode',
      jsonEncode(updated.toJson()),
    );

    state = AsyncValue.data({...currentState, prefectureCode: updated});
  }

  String? _getHighestDifficulty(String? current, String newOne) {
    if (current == null) return newOne;
    const order = ['Easy', 'Normal', 'Hard'];
    final currentIdx = order.indexOf(current);
    final newIdx = order.indexOf(newOne);
    return newIdx > currentIdx ? newOne : current;
  }

  int getTotalClears() {
    final currentState = state.valueOrNull ?? {};
    return currentState.values.fold(0, (sum, record) => sum + record.totalClears);
  }

  int getTotalClearedPrefectures() {
    final currentState = state.valueOrNull ?? {};
    return currentState.length;
  }

  double getAverageLevel() {
    final currentState = state.valueOrNull ?? {};
    if (currentState.isEmpty) return 0.0;
    final sum = currentState.values.fold<int>(0, (sum, record) => sum + record.currentLevel);
    return sum / currentState.length;
  }

  int getHighestScore() {
    final currentState = state.valueOrNull ?? {};
    if (currentState.isEmpty) return 0;
    return currentState.values.fold<int>(0, (max, record) => record.bestScore > max ? record.bestScore : max);
  }

  PrefectureRecord? getRecord(String prefectureCode) {
    final currentState = state.valueOrNull ?? {};
    return currentState[prefectureCode];
  }
}
