import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geography_puzzle_king/models/ranking_model.dart';
import 'package:geography_puzzle_king/models/game_model.dart';

class RankingService {
  final SharedPreferences _prefs;

  RankingService(this._prefs);

  static const _keyGlobalRanking = 'global_ranking_v1';
  static const _maxGlobalEntries = 100;
  static const _maxPrefEntries = 50;

  // ─── グローバルランキング ───────────────────────────────────────

  List<RankingEntry> getGlobalRanking({int limit = 50}) {
    final json = _prefs.getString(_keyGlobalRanking);
    if (json == null || json.isEmpty) return [];

    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => RankingEntry.fromJson(e as Map<String, dynamic>))
          .toList()
          .take(limit)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> updateRankingData({
    required String userId,
    required int totalScore,
    required int clearedCount,
    required int playTime,
  }) async {
    final now = DateTime.now();
    final newEntry = RankingEntry(
      rank: 0,
      userId: userId,
      totalScore: totalScore,
      clearedPrefectures: clearedCount,
      playTime: playTime,
      recordedAt: now,
    );

    // グローバルランキング更新
    var ranking = getGlobalRanking(limit: _maxGlobalEntries);

    // 既存ユーザーのエントリを削除（新しいスコアでリランク）
    ranking.removeWhere((e) => e.userId == userId);

    // 新しいエントリを追加
    ranking.add(newEntry);

    // スコアの降順でソート
    ranking.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    // ランクを再付与
    ranking = ranking
        .asMap()
        .entries
        .map((e) => e.value.copyWith(rank: e.key + 1))
        .toList();

    // 上位100件のみ保持
    if (ranking.length > _maxGlobalEntries) {
      ranking = ranking.take(_maxGlobalEntries).toList();
    }

    final json = jsonEncode(ranking.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyGlobalRanking, json);
  }

  // ─── 都道府県別ランキング ────────────────────────────────────────

  String _prefRankingKey(String prefCode, String difficulty) =>
      'pref_ranking_${prefCode}_${difficulty}_v1';

  List<PrefectureRankingEntry> getPrefectureRanking(
    String prefCode,
    String difficulty,
  ) {
    final key = _prefRankingKey(prefCode, difficulty);
    final json = _prefs.getString(key);
    if (json == null || json.isEmpty) return [];

    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => PrefectureRankingEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> recordPrefectureScore({
    required String userId,
    required String prefCode,
    required String difficulty,
    required int score,
    required int clearTime,
  }) async {
    final key = _prefRankingKey(prefCode, difficulty);
    var ranking = getPrefectureRanking(prefCode, difficulty);

    // 既存エントリを更新or新規作成
    final existingIndex =
        ranking.indexWhere((e) => e.prefectureCode == prefCode);

    if (existingIndex >= 0) {
      final existing = ranking[existingIndex];
      ranking[existingIndex] = existing.copyWith(
        bestScore: score > existing.bestScore ? score : existing.bestScore,
        fastestClearTime: clearTime < existing.fastestClearTime
            ? clearTime
            : existing.fastestClearTime,
        playCount: existing.playCount + 1,
        lastClearedAt: DateTime.now(),
      );
    } else {
      ranking.add(PrefectureRankingEntry(
        prefectureCode: prefCode,
        difficulty: difficulty,
        rank: 0,
        bestScore: score,
        fastestClearTime: clearTime,
        playCount: 1,
        lastClearedAt: DateTime.now(),
      ));
    }

    // スコアの降順でソート
    ranking.sort((a, b) => b.bestScore.compareTo(a.bestScore));

    // ランクを再付与
    ranking = ranking
        .asMap()
        .entries
        .map((e) => e.value.copyWith(rank: e.key + 1))
        .toList();

    // 上位50件のみ保持
    if (ranking.length > _maxPrefEntries) {
      ranking = ranking.take(_maxPrefEntries).toList();
    }

    final json = jsonEncode(ranking.map((e) => e.toJson()).toList());
    await _prefs.setString(key, json);
  }

  // ─── ユーザー統計 ───────────────────────────────────────────────

  UserRankingStats? getUserStats(String userId) {
    final ranking = getGlobalRanking(limit: _maxGlobalEntries);
    final userEntry = ranking
        .where((e) => e.userId == userId)
        .isEmpty
        ? null
        : ranking.firstWhere((e) => e.userId == userId);

    if (userEntry == null) return null;

    // 都道府県別ランクマップを構築
    final prefRanks = <String, int>{};
    for (var i = 1; i <= 47; i++) {
      final code = i.toString().padLeft(2, '0');
      for (final diff in ['easy', 'normal', 'hard']) {
        final key = '$code\_$diff';
        final pref = getPrefectureRanking(code, diff);
        final rank = pref.indexWhere((e) => e.prefectureCode == code) + 1;
        if (rank > 0) prefRanks[key] = rank;
      }
    }

    return UserRankingStats(
      globalRank: userEntry.rank,
      totalScore: userEntry.totalScore,
      clearedCount: userEntry.clearedPrefectures,
      prefectureRanks: prefRanks,
      lastUpdated: userEntry.recordedAt,
    );
  }

  // ─── ユーティリティ ─────────────────────────────────────────────

  Future<void> clearAllRankings() async {
    await _prefs.remove(_keyGlobalRanking);
    for (var i = 1; i <= 47; i++) {
      final code = i.toString().padLeft(2, '0');
      for (final diff in ['easy', 'normal', 'hard']) {
        await _prefs.remove(_prefRankingKey(code, diff));
      }
    }
  }
}
