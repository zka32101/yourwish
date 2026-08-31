// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ranking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RankingEntry _$RankingEntryFromJson(Map<String, dynamic> json) {
  return _RankingEntry.fromJson(json);
}

/// @nodoc
mixin _$RankingEntry {
  int get rank => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  int get clearedPrefectures => throw _privateConstructorUsedError;
  int get playTime => throw _privateConstructorUsedError;
  DateTime get recordedAt => throw _privateConstructorUsedError;

  /// Serializes this RankingEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RankingEntryCopyWith<RankingEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankingEntryCopyWith<$Res> {
  factory $RankingEntryCopyWith(
    RankingEntry value,
    $Res Function(RankingEntry) then,
  ) = _$RankingEntryCopyWithImpl<$Res, RankingEntry>;
  @useResult
  $Res call({
    int rank,
    String userId,
    int totalScore,
    int clearedPrefectures,
    int playTime,
    DateTime recordedAt,
  });
}

/// @nodoc
class _$RankingEntryCopyWithImpl<$Res, $Val extends RankingEntry>
    implements $RankingEntryCopyWith<$Res> {
  _$RankingEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? userId = null,
    Object? totalScore = null,
    Object? clearedPrefectures = null,
    Object? playTime = null,
    Object? recordedAt = null,
  }) {
    return _then(
      _value.copyWith(
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            clearedPrefectures: null == clearedPrefectures
                ? _value.clearedPrefectures
                : clearedPrefectures // ignore: cast_nullable_to_non_nullable
                      as int,
            playTime: null == playTime
                ? _value.playTime
                : playTime // ignore: cast_nullable_to_non_nullable
                      as int,
            recordedAt: null == recordedAt
                ? _value.recordedAt
                : recordedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RankingEntryImplCopyWith<$Res>
    implements $RankingEntryCopyWith<$Res> {
  factory _$$RankingEntryImplCopyWith(
    _$RankingEntryImpl value,
    $Res Function(_$RankingEntryImpl) then,
  ) = __$$RankingEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int rank,
    String userId,
    int totalScore,
    int clearedPrefectures,
    int playTime,
    DateTime recordedAt,
  });
}

/// @nodoc
class __$$RankingEntryImplCopyWithImpl<$Res>
    extends _$RankingEntryCopyWithImpl<$Res, _$RankingEntryImpl>
    implements _$$RankingEntryImplCopyWith<$Res> {
  __$$RankingEntryImplCopyWithImpl(
    _$RankingEntryImpl _value,
    $Res Function(_$RankingEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? userId = null,
    Object? totalScore = null,
    Object? clearedPrefectures = null,
    Object? playTime = null,
    Object? recordedAt = null,
  }) {
    return _then(
      _$RankingEntryImpl(
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        clearedPrefectures: null == clearedPrefectures
            ? _value.clearedPrefectures
            : clearedPrefectures // ignore: cast_nullable_to_non_nullable
                  as int,
        playTime: null == playTime
            ? _value.playTime
            : playTime // ignore: cast_nullable_to_non_nullable
                  as int,
        recordedAt: null == recordedAt
            ? _value.recordedAt
            : recordedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RankingEntryImpl implements _RankingEntry {
  const _$RankingEntryImpl({
    required this.rank,
    required this.userId,
    required this.totalScore,
    required this.clearedPrefectures,
    required this.playTime,
    required this.recordedAt,
  });

  factory _$RankingEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RankingEntryImplFromJson(json);

  @override
  final int rank;
  @override
  final String userId;
  @override
  final int totalScore;
  @override
  final int clearedPrefectures;
  @override
  final int playTime;
  @override
  final DateTime recordedAt;

  @override
  String toString() {
    return 'RankingEntry(rank: $rank, userId: $userId, totalScore: $totalScore, clearedPrefectures: $clearedPrefectures, playTime: $playTime, recordedAt: $recordedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingEntryImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.clearedPrefectures, clearedPrefectures) ||
                other.clearedPrefectures == clearedPrefectures) &&
            (identical(other.playTime, playTime) ||
                other.playTime == playTime) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rank,
    userId,
    totalScore,
    clearedPrefectures,
    playTime,
    recordedAt,
  );

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RankingEntryImplCopyWith<_$RankingEntryImpl> get copyWith =>
      __$$RankingEntryImplCopyWithImpl<_$RankingEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RankingEntryImplToJson(this);
  }
}

abstract class _RankingEntry implements RankingEntry {
  const factory _RankingEntry({
    required final int rank,
    required final String userId,
    required final int totalScore,
    required final int clearedPrefectures,
    required final int playTime,
    required final DateTime recordedAt,
  }) = _$RankingEntryImpl;

  factory _RankingEntry.fromJson(Map<String, dynamic> json) =
      _$RankingEntryImpl.fromJson;

  @override
  int get rank;
  @override
  String get userId;
  @override
  int get totalScore;
  @override
  int get clearedPrefectures;
  @override
  int get playTime;
  @override
  DateTime get recordedAt;

  /// Create a copy of RankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingEntryImplCopyWith<_$RankingEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PrefectureRankingEntry _$PrefectureRankingEntryFromJson(
  Map<String, dynamic> json,
) {
  return _PrefectureRankingEntry.fromJson(json);
}

/// @nodoc
mixin _$PrefectureRankingEntry {
  String get prefectureCode => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  int get bestScore => throw _privateConstructorUsedError;
  int get fastestClearTime => throw _privateConstructorUsedError;
  int get playCount => throw _privateConstructorUsedError;
  DateTime get lastClearedAt => throw _privateConstructorUsedError;

  /// Serializes this PrefectureRankingEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrefectureRankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrefectureRankingEntryCopyWith<PrefectureRankingEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrefectureRankingEntryCopyWith<$Res> {
  factory $PrefectureRankingEntryCopyWith(
    PrefectureRankingEntry value,
    $Res Function(PrefectureRankingEntry) then,
  ) = _$PrefectureRankingEntryCopyWithImpl<$Res, PrefectureRankingEntry>;
  @useResult
  $Res call({
    String prefectureCode,
    String difficulty,
    int rank,
    int bestScore,
    int fastestClearTime,
    int playCount,
    DateTime lastClearedAt,
  });
}

/// @nodoc
class _$PrefectureRankingEntryCopyWithImpl<
  $Res,
  $Val extends PrefectureRankingEntry
>
    implements $PrefectureRankingEntryCopyWith<$Res> {
  _$PrefectureRankingEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrefectureRankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prefectureCode = null,
    Object? difficulty = null,
    Object? rank = null,
    Object? bestScore = null,
    Object? fastestClearTime = null,
    Object? playCount = null,
    Object? lastClearedAt = null,
  }) {
    return _then(
      _value.copyWith(
            prefectureCode: null == prefectureCode
                ? _value.prefectureCode
                : prefectureCode // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            bestScore: null == bestScore
                ? _value.bestScore
                : bestScore // ignore: cast_nullable_to_non_nullable
                      as int,
            fastestClearTime: null == fastestClearTime
                ? _value.fastestClearTime
                : fastestClearTime // ignore: cast_nullable_to_non_nullable
                      as int,
            playCount: null == playCount
                ? _value.playCount
                : playCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastClearedAt: null == lastClearedAt
                ? _value.lastClearedAt
                : lastClearedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrefectureRankingEntryImplCopyWith<$Res>
    implements $PrefectureRankingEntryCopyWith<$Res> {
  factory _$$PrefectureRankingEntryImplCopyWith(
    _$PrefectureRankingEntryImpl value,
    $Res Function(_$PrefectureRankingEntryImpl) then,
  ) = __$$PrefectureRankingEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String prefectureCode,
    String difficulty,
    int rank,
    int bestScore,
    int fastestClearTime,
    int playCount,
    DateTime lastClearedAt,
  });
}

/// @nodoc
class __$$PrefectureRankingEntryImplCopyWithImpl<$Res>
    extends
        _$PrefectureRankingEntryCopyWithImpl<$Res, _$PrefectureRankingEntryImpl>
    implements _$$PrefectureRankingEntryImplCopyWith<$Res> {
  __$$PrefectureRankingEntryImplCopyWithImpl(
    _$PrefectureRankingEntryImpl _value,
    $Res Function(_$PrefectureRankingEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PrefectureRankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prefectureCode = null,
    Object? difficulty = null,
    Object? rank = null,
    Object? bestScore = null,
    Object? fastestClearTime = null,
    Object? playCount = null,
    Object? lastClearedAt = null,
  }) {
    return _then(
      _$PrefectureRankingEntryImpl(
        prefectureCode: null == prefectureCode
            ? _value.prefectureCode
            : prefectureCode // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        bestScore: null == bestScore
            ? _value.bestScore
            : bestScore // ignore: cast_nullable_to_non_nullable
                  as int,
        fastestClearTime: null == fastestClearTime
            ? _value.fastestClearTime
            : fastestClearTime // ignore: cast_nullable_to_non_nullable
                  as int,
        playCount: null == playCount
            ? _value.playCount
            : playCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastClearedAt: null == lastClearedAt
            ? _value.lastClearedAt
            : lastClearedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrefectureRankingEntryImpl implements _PrefectureRankingEntry {
  const _$PrefectureRankingEntryImpl({
    required this.prefectureCode,
    required this.difficulty,
    required this.rank,
    required this.bestScore,
    required this.fastestClearTime,
    required this.playCount,
    required this.lastClearedAt,
  });

  factory _$PrefectureRankingEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrefectureRankingEntryImplFromJson(json);

  @override
  final String prefectureCode;
  @override
  final String difficulty;
  @override
  final int rank;
  @override
  final int bestScore;
  @override
  final int fastestClearTime;
  @override
  final int playCount;
  @override
  final DateTime lastClearedAt;

  @override
  String toString() {
    return 'PrefectureRankingEntry(prefectureCode: $prefectureCode, difficulty: $difficulty, rank: $rank, bestScore: $bestScore, fastestClearTime: $fastestClearTime, playCount: $playCount, lastClearedAt: $lastClearedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrefectureRankingEntryImpl &&
            (identical(other.prefectureCode, prefectureCode) ||
                other.prefectureCode == prefectureCode) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.bestScore, bestScore) ||
                other.bestScore == bestScore) &&
            (identical(other.fastestClearTime, fastestClearTime) ||
                other.fastestClearTime == fastestClearTime) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount) &&
            (identical(other.lastClearedAt, lastClearedAt) ||
                other.lastClearedAt == lastClearedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    prefectureCode,
    difficulty,
    rank,
    bestScore,
    fastestClearTime,
    playCount,
    lastClearedAt,
  );

  /// Create a copy of PrefectureRankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrefectureRankingEntryImplCopyWith<_$PrefectureRankingEntryImpl>
  get copyWith =>
      __$$PrefectureRankingEntryImplCopyWithImpl<_$PrefectureRankingEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PrefectureRankingEntryImplToJson(this);
  }
}

abstract class _PrefectureRankingEntry implements PrefectureRankingEntry {
  const factory _PrefectureRankingEntry({
    required final String prefectureCode,
    required final String difficulty,
    required final int rank,
    required final int bestScore,
    required final int fastestClearTime,
    required final int playCount,
    required final DateTime lastClearedAt,
  }) = _$PrefectureRankingEntryImpl;

  factory _PrefectureRankingEntry.fromJson(Map<String, dynamic> json) =
      _$PrefectureRankingEntryImpl.fromJson;

  @override
  String get prefectureCode;
  @override
  String get difficulty;
  @override
  int get rank;
  @override
  int get bestScore;
  @override
  int get fastestClearTime;
  @override
  int get playCount;
  @override
  DateTime get lastClearedAt;

  /// Create a copy of PrefectureRankingEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrefectureRankingEntryImplCopyWith<_$PrefectureRankingEntryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UserRankingStats _$UserRankingStatsFromJson(Map<String, dynamic> json) {
  return _UserRankingStats.fromJson(json);
}

/// @nodoc
mixin _$UserRankingStats {
  int get globalRank => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  int get clearedCount => throw _privateConstructorUsedError;
  Map<String, int> get prefectureRanks => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this UserRankingStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserRankingStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserRankingStatsCopyWith<UserRankingStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserRankingStatsCopyWith<$Res> {
  factory $UserRankingStatsCopyWith(
    UserRankingStats value,
    $Res Function(UserRankingStats) then,
  ) = _$UserRankingStatsCopyWithImpl<$Res, UserRankingStats>;
  @useResult
  $Res call({
    int globalRank,
    int totalScore,
    int clearedCount,
    Map<String, int> prefectureRanks,
    DateTime lastUpdated,
  });
}

/// @nodoc
class _$UserRankingStatsCopyWithImpl<$Res, $Val extends UserRankingStats>
    implements $UserRankingStatsCopyWith<$Res> {
  _$UserRankingStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserRankingStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalRank = null,
    Object? totalScore = null,
    Object? clearedCount = null,
    Object? prefectureRanks = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _value.copyWith(
            globalRank: null == globalRank
                ? _value.globalRank
                : globalRank // ignore: cast_nullable_to_non_nullable
                      as int,
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            clearedCount: null == clearedCount
                ? _value.clearedCount
                : clearedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            prefectureRanks: null == prefectureRanks
                ? _value.prefectureRanks
                : prefectureRanks // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserRankingStatsImplCopyWith<$Res>
    implements $UserRankingStatsCopyWith<$Res> {
  factory _$$UserRankingStatsImplCopyWith(
    _$UserRankingStatsImpl value,
    $Res Function(_$UserRankingStatsImpl) then,
  ) = __$$UserRankingStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int globalRank,
    int totalScore,
    int clearedCount,
    Map<String, int> prefectureRanks,
    DateTime lastUpdated,
  });
}

/// @nodoc
class __$$UserRankingStatsImplCopyWithImpl<$Res>
    extends _$UserRankingStatsCopyWithImpl<$Res, _$UserRankingStatsImpl>
    implements _$$UserRankingStatsImplCopyWith<$Res> {
  __$$UserRankingStatsImplCopyWithImpl(
    _$UserRankingStatsImpl _value,
    $Res Function(_$UserRankingStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserRankingStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalRank = null,
    Object? totalScore = null,
    Object? clearedCount = null,
    Object? prefectureRanks = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _$UserRankingStatsImpl(
        globalRank: null == globalRank
            ? _value.globalRank
            : globalRank // ignore: cast_nullable_to_non_nullable
                  as int,
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        clearedCount: null == clearedCount
            ? _value.clearedCount
            : clearedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        prefectureRanks: null == prefectureRanks
            ? _value._prefectureRanks
            : prefectureRanks // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserRankingStatsImpl implements _UserRankingStats {
  const _$UserRankingStatsImpl({
    required this.globalRank,
    required this.totalScore,
    required this.clearedCount,
    required final Map<String, int> prefectureRanks,
    required this.lastUpdated,
  }) : _prefectureRanks = prefectureRanks;

  factory _$UserRankingStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserRankingStatsImplFromJson(json);

  @override
  final int globalRank;
  @override
  final int totalScore;
  @override
  final int clearedCount;
  final Map<String, int> _prefectureRanks;
  @override
  Map<String, int> get prefectureRanks {
    if (_prefectureRanks is EqualUnmodifiableMapView) return _prefectureRanks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_prefectureRanks);
  }

  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'UserRankingStats(globalRank: $globalRank, totalScore: $totalScore, clearedCount: $clearedCount, prefectureRanks: $prefectureRanks, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserRankingStatsImpl &&
            (identical(other.globalRank, globalRank) ||
                other.globalRank == globalRank) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.clearedCount, clearedCount) ||
                other.clearedCount == clearedCount) &&
            const DeepCollectionEquality().equals(
              other._prefectureRanks,
              _prefectureRanks,
            ) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    globalRank,
    totalScore,
    clearedCount,
    const DeepCollectionEquality().hash(_prefectureRanks),
    lastUpdated,
  );

  /// Create a copy of UserRankingStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserRankingStatsImplCopyWith<_$UserRankingStatsImpl> get copyWith =>
      __$$UserRankingStatsImplCopyWithImpl<_$UserRankingStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserRankingStatsImplToJson(this);
  }
}

abstract class _UserRankingStats implements UserRankingStats {
  const factory _UserRankingStats({
    required final int globalRank,
    required final int totalScore,
    required final int clearedCount,
    required final Map<String, int> prefectureRanks,
    required final DateTime lastUpdated,
  }) = _$UserRankingStatsImpl;

  factory _UserRankingStats.fromJson(Map<String, dynamic> json) =
      _$UserRankingStatsImpl.fromJson;

  @override
  int get globalRank;
  @override
  int get totalScore;
  @override
  int get clearedCount;
  @override
  Map<String, int> get prefectureRanks;
  @override
  DateTime get lastUpdated;

  /// Create a copy of UserRankingStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserRankingStatsImplCopyWith<_$UserRankingStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
