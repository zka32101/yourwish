import 'package:freezed_annotation/freezed_annotation.dart';

part 'prefecture_record.freezed.dart';
part 'prefecture_record.g.dart';

@freezed
class PrefectureRecord with _$PrefectureRecord {
  const factory PrefectureRecord({
    required String prefectureCode,
    required int totalClears,
    required int currentLevel,
    required int currentExp,
    required DateTime firstClearedAt,
    required DateTime lastClearedAt,
    required int bestScore,
    String? highestDifficulty,
  }) = _PrefectureRecord;

  const PrefectureRecord._();

  int getNextLevelExpRequired() => currentLevel * 15;

  PrefectureRecord addExp(int exp) {
    int newExp = currentExp + exp;
    int newLevel = currentLevel;
    int nextRequired = getNextLevelExpRequired();

    while (newExp >= nextRequired && newLevel < 10) {
      newExp -= nextRequired;
      newLevel++;
      nextRequired = newLevel * 15;
    }

    return copyWith(currentLevel: newLevel, currentExp: newExp);
  }

  factory PrefectureRecord.fromJson(Map<String, dynamic> json) =>
      _$PrefectureRecordFromJson(json);
}
