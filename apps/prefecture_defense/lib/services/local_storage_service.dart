import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geography_puzzle_king/models/game_model.dart';

class LocalStorageService {
  static const _keyStats   = 'game_stats_v1';
  static const _keyHistory = 'game_history_v1';

  final SharedPreferences _prefs;
  LocalStorageService(this._prefs);

  // ── 統計 ───────────────────────────────────────────────────────────────

  GameStats loadStats() {
    final raw = _prefs.getString(_keyStats);
    if (raw == null) return _emptyStats();
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return GameStats(
        totalGamesPlayed:        m['totalGamesPlayed']        as int? ?? 0,
        totalClearedPrefectures: m['totalClearedPrefectures'] as int? ?? 0,
        totalScore:              m['totalScore']              as int? ?? 0,
        totalPlayTime:           m['totalPlayTime']           as int? ?? 0,
        totalMistakes:           m['totalMistakes']           as int? ?? 0,
        difficultyClearedCount: Map<String, int>.from(
          (m['difficultyClearedCount'] as Map? ?? {})
              .map((k, v) => MapEntry(k as String, v as int)),
        ),
      );
    } catch (_) {
      return _emptyStats();
    }
  }

  Future<void> saveStats(GameStats s) async {
    await _prefs.setString(_keyStats, jsonEncode({
      'totalGamesPlayed':        s.totalGamesPlayed,
      'totalClearedPrefectures': s.totalClearedPrefectures,
      'totalScore':              s.totalScore,
      'totalPlayTime':           s.totalPlayTime,
      'totalMistakes':           s.totalMistakes,
      'difficultyClearedCount':  s.difficultyClearedCount,
    }));
  }

  // ── 履歴 ───────────────────────────────────────────────────────────────

  List<GameSession> loadHistory() {
    final raw = _prefs.getString(_keyHistory);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((item) {
        final m = item as Map<String, dynamic>;
        return GameSession(
          gameId:         m['gameId']         as String,
          prefectureCode: m['prefectureCode'] as String,
          difficulty:     m['difficulty']     as String,
          score:          m['score']          as int,
          clearTime:      m['clearTime']      as int,
          mistakes:       m['mistakes']       as int,
          isCleared:      m['isCleared']      as bool,
          earnedExp:      m['earnedExp']      as int,
          timestamp: DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(List<GameSession> history) async {
    final recent = history.length > 200 ? history.sublist(history.length - 200) : history;
    final list = recent.map((s) => {
      'gameId':         s.gameId,
      'prefectureCode': s.prefectureCode,
      'difficulty':     s.difficulty,
      'score':          s.score,
      'clearTime':      s.clearTime,
      'mistakes':       s.mistakes,
      'isCleared':      s.isCleared,
      'earnedExp':      s.earnedExp,
      'timestamp':      s.timestamp.millisecondsSinceEpoch,
    }).toList();
    await _prefs.setString(_keyHistory, jsonEncode(list));
  }

  // ── ベストスコア（県×難度別） ───────────────────────────────────────────

  int? getBestScore(String prefCode, String difficulty) {
    return _prefs.getInt('best_${prefCode}_$difficulty');
  }

  Future<void> updateBestScore(String prefCode, String difficulty, int score) async {
    final key = 'best_${prefCode}_$difficulty';
    final existing = _prefs.getInt(key) ?? 0;
    if (score > existing) {
      await _prefs.setInt(key, score);
    }
  }

  // ── クリア済みフラグ（県×難度） ────────────────────────────────────────

  bool isCleared(String prefCode, String difficulty) {
    return _prefs.getBool('cleared_${prefCode}_$difficulty') ?? false;
  }

  Future<void> setCleared(String prefCode, String difficulty) async {
    await _prefs.setBool('cleared_${prefCode}_$difficulty', true);
  }

  // ── 地方決戦クリアフラグ ───────────────────────────────────────────────

  bool isRegionCleared(String regionCode) {
    return _prefs.getBool('region_cleared_$regionCode') ?? false;
  }

  Future<void> setRegionCleared(String regionCode) async {
    await _prefs.setBool('region_cleared_$regionCode', true);
  }

  // ── 歴史ステージ ───────────────────────────────────────────────────────

  bool isHistoryStageCleared(String histCode) {
    return _prefs.getBool('history_cleared_$histCode') ?? false;
  }

  Future<void> setHistoryStageCleared(String histCode) async {
    await _prefs.setBool('history_cleared_$histCode', true);
  }

  // ── helpers ────────────────────────────────────────────────────────────

  static GameStats _emptyStats() => const GameStats(
    totalGamesPlayed:        0,
    totalClearedPrefectures: 0,
    totalScore:              0,
    totalPlayTime:           0,
    totalMistakes:           0,
    difficultyClearedCount:  {},
  );
}
