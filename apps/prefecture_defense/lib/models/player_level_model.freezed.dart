// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_level_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlayerLevel _$PlayerLevelFromJson(Map<String, dynamic> json) {
  return _PlayerLevel.fromJson(json);
}

/// @nodoc
mixin _$PlayerLevel {
  int get currentLevel => throw _privateConstructorUsedError;
  int get totalExp => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this PlayerLevel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerLevel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerLevelCopyWith<PlayerLevel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerLevelCopyWith<$Res> {
  factory $PlayerLevelCopyWith(
    PlayerLevel value,
    $Res Function(PlayerLevel) then,
  ) = _$PlayerLevelCopyWithImpl<$Res, PlayerLevel>;
  @useResult
  $Res call({int currentLevel, int totalExp, DateTime lastUpdated});
}

/// @nodoc
class _$PlayerLevelCopyWithImpl<$Res, $Val extends PlayerLevel>
    implements $PlayerLevelCopyWith<$Res> {
  _$PlayerLevelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerLevel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = null,
    Object? totalExp = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _value.copyWith(
            currentLevel: null == currentLevel
                ? _value.currentLevel
                : currentLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            totalExp: null == totalExp
                ? _value.totalExp
                : totalExp // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$PlayerLevelImplCopyWith<$Res>
    implements $PlayerLevelCopyWith<$Res> {
  factory _$$PlayerLevelImplCopyWith(
    _$PlayerLevelImpl value,
    $Res Function(_$PlayerLevelImpl) then,
  ) = __$$PlayerLevelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int currentLevel, int totalExp, DateTime lastUpdated});
}

/// @nodoc
class __$$PlayerLevelImplCopyWithImpl<$Res>
    extends _$PlayerLevelCopyWithImpl<$Res, _$PlayerLevelImpl>
    implements _$$PlayerLevelImplCopyWith<$Res> {
  __$$PlayerLevelImplCopyWithImpl(
    _$PlayerLevelImpl _value,
    $Res Function(_$PlayerLevelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerLevel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = null,
    Object? totalExp = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _$PlayerLevelImpl(
        currentLevel: null == currentLevel
            ? _value.currentLevel
            : currentLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        totalExp: null == totalExp
            ? _value.totalExp
            : totalExp // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$PlayerLevelImpl implements _PlayerLevel {
  const _$PlayerLevelImpl({
    required this.currentLevel,
    required this.totalExp,
    required this.lastUpdated,
  });

  factory _$PlayerLevelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerLevelImplFromJson(json);

  @override
  final int currentLevel;
  @override
  final int totalExp;
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'PlayerLevel(currentLevel: $currentLevel, totalExp: $totalExp, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerLevelImpl &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.totalExp, totalExp) ||
                other.totalExp == totalExp) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, currentLevel, totalExp, lastUpdated);

  /// Create a copy of PlayerLevel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerLevelImplCopyWith<_$PlayerLevelImpl> get copyWith =>
      __$$PlayerLevelImplCopyWithImpl<_$PlayerLevelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerLevelImplToJson(this);
  }
}

abstract class _PlayerLevel implements PlayerLevel {
  const factory _PlayerLevel({
    required final int currentLevel,
    required final int totalExp,
    required final DateTime lastUpdated,
  }) = _$PlayerLevelImpl;

  factory _PlayerLevel.fromJson(Map<String, dynamic> json) =
      _$PlayerLevelImpl.fromJson;

  @override
  int get currentLevel;
  @override
  int get totalExp;
  @override
  DateTime get lastUpdated;

  /// Create a copy of PlayerLevel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerLevelImplCopyWith<_$PlayerLevelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
