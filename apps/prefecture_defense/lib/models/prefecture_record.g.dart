// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefecture_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrefectureRecordImpl _$$PrefectureRecordImplFromJson(
  Map<String, dynamic> json,
) => _$PrefectureRecordImpl(
  prefectureCode: json['prefectureCode'] as String,
  totalClears: (json['totalClears'] as num).toInt(),
  currentLevel: (json['currentLevel'] as num).toInt(),
  currentExp: (json['currentExp'] as num).toInt(),
  firstClearedAt: DateTime.parse(json['firstClearedAt'] as String),
  lastClearedAt: DateTime.parse(json['lastClearedAt'] as String),
  bestScore: (json['bestScore'] as num).toInt(),
  highestDifficulty: json['highestDifficulty'] as String?,
);

Map<String, dynamic> _$$PrefectureRecordImplToJson(
  _$PrefectureRecordImpl instance,
) => <String, dynamic>{
  'prefectureCode': instance.prefectureCode,
  'totalClears': instance.totalClears,
  'currentLevel': instance.currentLevel,
  'currentExp': instance.currentExp,
  'firstClearedAt': instance.firstClearedAt.toIso8601String(),
  'lastClearedAt': instance.lastClearedAt.toIso8601String(),
  'bestScore': instance.bestScore,
  'highestDifficulty': instance.highestDifficulty,
};
