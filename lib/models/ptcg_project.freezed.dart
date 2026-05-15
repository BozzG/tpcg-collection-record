// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ptcg_project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TCGProject _$TCGProjectFromJson(Map<String, dynamic> json) {
  return _TCGProject.fromJson(json);
}

/// @nodoc
mixin _$TCGProject {
  int? get id => throw _privateConstructorUsedError; // 系统分配的id，可以为空
  String get name => throw _privateConstructorUsedError; // 项目名字
  String get description => throw _privateConstructorUsedError; // 项目描述
  List<TCGCard> get cards => throw _privateConstructorUsedError;

  /// Serializes this TCGProject to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TCGProject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TCGProjectCopyWith<TCGProject> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TCGProjectCopyWith<$Res> {
  factory $TCGProjectCopyWith(
          TCGProject value, $Res Function(TCGProject) then) =
      _$TCGProjectCopyWithImpl<$Res, TCGProject>;
  @useResult
  $Res call({int? id, String name, String description, List<TCGCard> cards});
}

/// @nodoc
class _$TCGProjectCopyWithImpl<$Res, $Val extends TCGProject>
    implements $TCGProjectCopyWith<$Res> {
  _$TCGProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TCGProject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = null,
    Object? cards = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      cards: null == cards
          ? _value.cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<TCGCard>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TCGProjectImplCopyWith<$Res>
    implements $TCGProjectCopyWith<$Res> {
  factory _$$TCGProjectImplCopyWith(
          _$TCGProjectImpl value, $Res Function(_$TCGProjectImpl) then) =
      __$$TCGProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String name, String description, List<TCGCard> cards});
}

/// @nodoc
class __$$TCGProjectImplCopyWithImpl<$Res>
    extends _$TCGProjectCopyWithImpl<$Res, _$TCGProjectImpl>
    implements _$$TCGProjectImplCopyWith<$Res> {
  __$$TCGProjectImplCopyWithImpl(
      _$TCGProjectImpl _value, $Res Function(_$TCGProjectImpl) _then)
      : super(_value, _then);

  /// Create a copy of TCGProject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = null,
    Object? cards = null,
  }) {
    return _then(_$TCGProjectImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      cards: null == cards
          ? _value._cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<TCGCard>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TCGProjectImpl implements _TCGProject {
  const _$TCGProjectImpl(
      {this.id,
      required this.name,
      required this.description,
      final List<TCGCard> cards = const []})
      : _cards = cards;

  factory _$TCGProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$TCGProjectImplFromJson(json);

  @override
  final int? id;
// 系统分配的id，可以为空
  @override
  final String name;
// 项目名字
  @override
  final String description;
// 项目描述
  final List<TCGCard> _cards;
// 项目描述
  @override
  @JsonKey()
  List<TCGCard> get cards {
    if (_cards is EqualUnmodifiableListView) return _cards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cards);
  }

  @override
  String toString() {
    return 'TCGProject(id: $id, name: $name, description: $description, cards: $cards)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TCGProjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._cards, _cards));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description,
      const DeepCollectionEquality().hash(_cards));

  /// Create a copy of TCGProject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TCGProjectImplCopyWith<_$TCGProjectImpl> get copyWith =>
      __$$TCGProjectImplCopyWithImpl<_$TCGProjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TCGProjectImplToJson(
      this,
    );
  }
}

abstract class _TCGProject implements TCGProject {
  const factory _TCGProject(
      {final int? id,
      required final String name,
      required final String description,
      final List<TCGCard> cards}) = _$TCGProjectImpl;

  factory _TCGProject.fromJson(Map<String, dynamic> json) =
      _$TCGProjectImpl.fromJson;

  @override
  int? get id; // 系统分配的id，可以为空
  @override
  String get name; // 项目名字
  @override
  String get description; // 项目描述
  @override
  List<TCGCard> get cards;

  /// Create a copy of TCGProject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TCGProjectImplCopyWith<_$TCGProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
