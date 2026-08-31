// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RankingEntryImpl _$$RankingEntryImplFromJson(Map<String, dynamic> json) =>
    _$RankingEntryImpl(
      rank: (json['rank'] as num).toInt(),
      userId: json['userId'] as String,
      totalScore: (json['totalScore'] as num).toInt(),
      clearedPrefectures: (json['clearedPrefectures'] as num).toInt(),
      playTime: (json['playTime'] as num).toInt(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$$RankingEntryImplToJson(_$RankingEntryImpl instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'userId': instance.userId,
      'totalScore': instance.totalScore,
      'clearedPrefectures': instance.clearedPrefectures,
      'playTime': instance.playTime,
      'recordedAt': instance.recordedAt.toIso8601String(),
    };

_$PrefectureRankingEntryImpl _$$PrefectureRankingEntryImplFromJson(
  Map<String, dynamic> json,
) => _$PrefectureRankingEntryImpl(
  prefectureCode: json['prefectureCode'] as String,
  difficulty: json['difficulty'] as String,
  rank: (json['rank'] as num).toInt(),
  bestScore: (json['bestScore'] as num).toInt(),
  fastestClearTime: (json['fastestClearTime'] as num).toInt(),
  playCount: (json['playCount'] as num).toInt(),
  lastClearedAt: DateTime.parse(json['lastClearedAt'] as String),
);

Map<String, dynamic> _$$PrefectureRankingEntryImplToJson(
  _$PrefectureRankingEntryImpl instance,
) => <String, dynamic>{
  'prefectureCode': instance.prefectureCode,
  'difficulty': instance.difficulty,
  'rank': instance.rank,
  'bestScore': instance.bestScore,
  'fastestClearTime': instance.fastestClearTime,
  'playCount': instance.playCount,
  'lastClearedAt': instance.lastClearedAt.toIso8601String(),
};

_$UserRankingStatsImpl _$$UserRankingStatsImplFromJson(
  Map<String, dynamic> json,
) => _$UserRankingStatsImpl(
  globalRank: (json['globalRank'] as num).toInt(),
  totalScore: (json['totalScore'] as num).toInt(),
  clearedCount: (json['clearedCount'] as num).toInt(),
  prefectureRanks: Map<String, int>.from(json['prefectureRanks'] as Map),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$$UserRankingStatsImplToJson(
  _$UserRankingStatsImpl instance,
) => <String, dynamic>{
  'globalRank': instance.globalRank,
  'totalScore': instance.totalScore,
  'clearedCount': instance.clearedCount,
  'prefectureRanks': instance.prefectureRanks,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
