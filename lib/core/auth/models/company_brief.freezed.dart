// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_brief.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompanyBrief _$CompanyBriefFromJson(Map<String, dynamic> json) {
  return _CompanyBrief.fromJson(json);
}

/// @nodoc
mixin _$CompanyBrief {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this CompanyBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompanyBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanyBriefCopyWith<CompanyBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyBriefCopyWith<$Res> {
  factory $CompanyBriefCopyWith(
          CompanyBrief value, $Res Function(CompanyBrief) then) =
      _$CompanyBriefCopyWithImpl<$Res, CompanyBrief>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$CompanyBriefCopyWithImpl<$Res, $Val extends CompanyBrief>
    implements $CompanyBriefCopyWith<$Res> {
  _$CompanyBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompanyBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompanyBriefImplCopyWith<$Res>
    implements $CompanyBriefCopyWith<$Res> {
  factory _$$CompanyBriefImplCopyWith(
          _$CompanyBriefImpl value, $Res Function(_$CompanyBriefImpl) then) =
      __$$CompanyBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$CompanyBriefImplCopyWithImpl<$Res>
    extends _$CompanyBriefCopyWithImpl<$Res, _$CompanyBriefImpl>
    implements _$$CompanyBriefImplCopyWith<$Res> {
  __$$CompanyBriefImplCopyWithImpl(
      _$CompanyBriefImpl _value, $Res Function(_$CompanyBriefImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompanyBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$CompanyBriefImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyBriefImpl implements _CompanyBrief {
  const _$CompanyBriefImpl({required this.id, required this.name});

  factory _$CompanyBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyBriefImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'CompanyBrief(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of CompanyBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyBriefImplCopyWith<_$CompanyBriefImpl> get copyWith =>
      __$$CompanyBriefImplCopyWithImpl<_$CompanyBriefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyBriefImplToJson(
      this,
    );
  }
}

abstract class _CompanyBrief implements CompanyBrief {
  const factory _CompanyBrief(
      {required final int id, required final String name}) = _$CompanyBriefImpl;

  factory _CompanyBrief.fromJson(Map<String, dynamic> json) =
      _$CompanyBriefImpl.fromJson;

  @override
  int get id;
  @override
  String get name;

  /// Create a copy of CompanyBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanyBriefImplCopyWith<_$CompanyBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
