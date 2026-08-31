import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking_model.freezed.dart';
part 'ranking_model.g.dart';

// ─── グローバルランキングエントリ ────────────────────────────────────

@freezed
class RankingEntry with _$RankingEntry {
  const factory RankingEntry({
    required int rank,
    required String userId,
    required int totalScore,
    required int clearedPrefectures,
    required int playTime,
    required DateTime recordedAt,
  }) = _RankingEntry;

  factory RankingEntry.fromJson(Map<String, dynamic> json) =>
      _$RankingEntryFromJson(json);
}

// ─── 都道府県別ランキングエントリ ────────────────────────────────────

@freezed
class PrefectureRankingEntry with _$PrefectureRankingEntry {
  const factory PrefectureRankingEntry({
    required String prefectureCode,
    required String difficulty,
    required int rank,
    required int bestScore,
    required int fastestClearTime,
    required int playCount,
    required DateTime lastClearedAt,
  }) = _PrefectureRankingEntry;

  factory PrefectureRankingEntry.fromJson(Map<String, dynamic> json) =>
      _$PrefectureRankingEntryFromJson(json);
}

// ─── ユーザーランキング統計 ────────────────────────────────────────

@freezed
class UserRankingStats with _$UserRankingStats {
  const factory UserRankingStats({
    required int globalRank,
    required int totalScore,
    required int clearedCount,
    required Map<String, int> prefectureRanks,
    required DateTime lastUpdated,
  }) = _UserRankingStats;

  factory UserRankingStats.fromJson(Map<String, dynamic> json) =>
      _$UserRankingStatsFromJson(json);
}
