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

PTCGProject _$PTCGProjectFromJson(Map<String, dynamic> json) {
  return _PTCGProject.fromJson(json);
}

/// @nodoc
mixin _$PTCGProject {
  int? get id => throw _privateConstructorUsedError; // 系统分配的id，可以为空
  String get name => throw _privateConstructorUsedError; // 项目名字
  String get description => throw _privateConstructorUsedError; // 项目描述
  List<PTCGCard> get cards => throw _privateConstructorUsedError;

  /// Serializes this PTCGProject to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PTCGProject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PTCGProjectCopyWith<PTCGProject> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PTCGProjectCopyWith<$Res> {
  factory $PTCGProjectCopyWith(
          PTCGProject value, $Res Function(PTCGProject) then) =
      _$PTCGProjectCopyWithImpl<$Res, PTCGProject>;
  @useResult
  $Res call({int? id, String name, String description, List<PTCGCard> cards});
}

/// @nodoc
class _$PTCGProjectCopyWithImpl<$Res, $Val extends PTCGProject>
    implements $PTCGProjectCopyWith<$Res> {
  _$PTCGProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PTCGProject
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
              as List<PTCGCard>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PTCGProjectImplCopyWith<$Res>
    implements $PTCGProjectCopyWith<$Res> {
  factory _$$PTCGProjectImplCopyWith(
          _$PTCGProjectImpl value, $Res Function(_$PTCGProjectImpl) then) =
      __$$PTCGProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String name, String description, List<PTCGCard> cards});
}

/// @nodoc
class __$$PTCGProjectImplCopyWithImpl<$Res>
    extends _$PTCGProjectCopyWithImpl<$Res, _$PTCGProjectImpl>
    implements _$$PTCGProjectImplCopyWith<$Res> {
  __$$PTCGProjectImplCopyWithImpl(
      _$PTCGProjectImpl _value, $Res Function(_$PTCGProjectImpl) _then)
      : super(_value, _then);

  /// Create a copy of PTCGProject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = null,
    Object? cards = null,
  }) {
    return _then(_$PTCGProjectImpl(
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
              as List<PTCGCard>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PTCGProjectImpl implements _PTCGProject {
  const _$PTCGProjectImpl(
      {this.id,
      required this.name,
      required this.description,
      final List<PTCGCard> cards = const []})
      : _cards = cards;

  factory _$PTCGProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$PTCGProjectImplFromJson(json);

  @override
  final int? id;
// 系统分配的id，可以为空
  @override
  final String name;
// 项目名字
  @override
  final String description;
// 项目描述
  final List<PTCGCard> _cards;
// 项目描述
  @override
  @JsonKey()
  List<PTCGCard> get cards {
    if (_cards is EqualUnmodifiableListView) return _cards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cards);
  }

  @override
  String toString() {
    return 'PTCGProject(id: $id, name: $name, description: $description, cards: $cards)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PTCGProjectImpl &&
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

  /// Create a copy of PTCGProject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PTCGProjectImplCopyWith<_$PTCGProjectImpl> get copyWith =>
      __$$PTCGProjectImplCopyWithImpl<_$PTCGProjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PTCGProjectImplToJson(
      this,
    );
  }
}

abstract class _PTCGProject implements PTCGProject {
  const factory _PTCGProject(
      {final int? id,
      required final String name,
      required final String description,
      final List<PTCGCard> cards}) = _$PTCGProjectImpl;

  factory _PTCGProject.fromJson(Map<String, dynamic> json) =
      _$PTCGProjectImpl.fromJson;

  @override
  int? get id; // 系统分配的id，可以为空
  @override
  String get name; // 项目名字
  @override
  String get description; // 项目描述
  @override
  List<PTCGCard> get cards;

  /// Create a copy of PTCGProject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PTCGProjectImplCopyWith<_$PTCGProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
