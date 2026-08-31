// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_level_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerLevelImpl _$$PlayerLevelImplFromJson(Map<String, dynamic> json) =>
    _$PlayerLevelImpl(
      currentLevel: (json['currentLevel'] as num).toInt(),
      totalExp: (json['totalExp'] as num).toInt(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$PlayerLevelImplToJson(_$PlayerLevelImpl instance) =>
    <String, dynamic>{
      'currentLevel': instance.currentLevel,
      'totalExp': instance.totalExp,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
