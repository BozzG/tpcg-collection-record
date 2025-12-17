// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ptcg_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PTCGCard _$PTCGCardFromJson(Map<String, dynamic> json) {
  return _PTCGCard.fromJson(json);
}

/// @nodoc
mixin _$PTCGCard {
  int? get id => throw _privateConstructorUsedError; // 系统分配的id，可以为空
  int get projectId => throw _privateConstructorUsedError; // 所属项目Id
  int get pokedexNumber => throw _privateConstructorUsedError; // 宝可梦图鉴编号
  String get name => throw _privateConstructorUsedError; // 卡片名字
  String get issueNumber => throw _privateConstructorUsedError; // 卡片发行编号
  String get issueDate => throw _privateConstructorUsedError; // 发行时间
  String get grade => throw _privateConstructorUsedError; // 评级
  String get acquiredDate => throw _privateConstructorUsedError; // 入手时间
  double get acquiredPrice => throw _privateConstructorUsedError; // 入手价格
  double get currentPrice => throw _privateConstructorUsedError; // 当前成交价
  String? get frontImage => throw _privateConstructorUsedError; // 正面图
  String? get backImage => throw _privateConstructorUsedError; // 背面图
  String? get gradeImage => throw _privateConstructorUsedError;

  /// Serializes this PTCGCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PTCGCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PTCGCardCopyWith<PTCGCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PTCGCardCopyWith<$Res> {
  factory $PTCGCardCopyWith(PTCGCard value, $Res Function(PTCGCard) then) =
      _$PTCGCardCopyWithImpl<$Res, PTCGCard>;
  @useResult
  $Res call(
      {int? id,
      int projectId,
      int pokedexNumber,
      String name,
      String issueNumber,
      String issueDate,
      String grade,
      String acquiredDate,
      double acquiredPrice,
      double currentPrice,
      String? frontImage,
      String? backImage,
      String? gradeImage});
}

/// @nodoc
class _$PTCGCardCopyWithImpl<$Res, $Val extends PTCGCard>
    implements $PTCGCardCopyWith<$Res> {
  _$PTCGCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PTCGCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? projectId = null,
    Object? pokedexNumber = null,
    Object? name = null,
    Object? issueNumber = null,
    Object? issueDate = null,
    Object? grade = null,
    Object? acquiredDate = null,
    Object? acquiredPrice = null,
    Object? currentPrice = null,
    Object? frontImage = freezed,
    Object? backImage = freezed,
    Object? gradeImage = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as int,
      pokedexNumber: null == pokedexNumber
          ? _value.pokedexNumber
          : pokedexNumber // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      issueNumber: null == issueNumber
          ? _value.issueNumber
          : issueNumber // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as String,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String,
      acquiredDate: null == acquiredDate
          ? _value.acquiredDate
          : acquiredDate // ignore: cast_nullable_to_non_nullable
              as String,
      acquiredPrice: null == acquiredPrice
          ? _value.acquiredPrice
          : acquiredPrice // ignore: cast_nullable_to_non_nullable
              as double,
      currentPrice: null == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
      frontImage: freezed == frontImage
          ? _value.frontImage
          : frontImage // ignore: cast_nullable_to_non_nullable
              as String?,
      backImage: freezed == backImage
          ? _value.backImage
          : backImage // ignore: cast_nullable_to_non_nullable
              as String?,
      gradeImage: freezed == gradeImage
          ? _value.gradeImage
          : gradeImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PTCGCardImplCopyWith<$Res>
    implements $PTCGCardCopyWith<$Res> {
  factory _$$PTCGCardImplCopyWith(
          _$PTCGCardImpl value, $Res Function(_$PTCGCardImpl) then) =
      __$$PTCGCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int projectId,
      int pokedexNumber,
      String name,
      String issueNumber,
      String issueDate,
      String grade,
      String acquiredDate,
      double acquiredPrice,
      double currentPrice,
      String? frontImage,
      String? backImage,
      String? gradeImage});
}

/// @nodoc
class __$$PTCGCardImplCopyWithImpl<$Res>
    extends _$PTCGCardCopyWithImpl<$Res, _$PTCGCardImpl>
    implements _$$PTCGCardImplCopyWith<$Res> {
  __$$PTCGCardImplCopyWithImpl(
      _$PTCGCardImpl _value, $Res Function(_$PTCGCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of PTCGCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? projectId = null,
    Object? pokedexNumber = null,
    Object? name = null,
    Object? issueNumber = null,
    Object? issueDate = null,
    Object? grade = null,
    Object? acquiredDate = null,
    Object? acquiredPrice = null,
    Object? currentPrice = null,
    Object? frontImage = freezed,
    Object? backImage = freezed,
    Object? gradeImage = freezed,
  }) {
    return _then(_$PTCGCardImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as int,
      pokedexNumber: null == pokedexNumber
          ? _value.pokedexNumber
          : pokedexNumber // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      issueNumber: null == issueNumber
          ? _value.issueNumber
          : issueNumber // ignore: cast_nullable_to_non_nullable
              as String,
      issueDate: null == issueDate
          ? _value.issueDate
          : issueDate // ignore: cast_nullable_to_non_nullable
              as String,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as String,
      acquiredDate: null == acquiredDate
          ? _value.acquiredDate
          : acquiredDate // ignore: cast_nullable_to_non_nullable
              as String,
      acquiredPrice: null == acquiredPrice
          ? _value.acquiredPrice
          : acquiredPrice // ignore: cast_nullable_to_non_nullable
              as double,
      currentPrice: null == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
      frontImage: freezed == frontImage
          ? _value.frontImage
          : frontImage // ignore: cast_nullable_to_non_nullable
              as String?,
      backImage: freezed == backImage
          ? _value.backImage
          : backImage // ignore: cast_nullable_to_non_nullable
              as String?,
      gradeImage: freezed == gradeImage
          ? _value.gradeImage
          : gradeImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PTCGCardImpl implements _PTCGCard {
  const _$PTCGCardImpl(
      {this.id,
      required this.projectId,
      required this.pokedexNumber,
      required this.name,
      required this.issueNumber,
      required this.issueDate,
      required this.grade,
      required this.acquiredDate,
      required this.acquiredPrice,
      required this.currentPrice,
      this.frontImage,
      this.backImage,
      this.gradeImage});

  factory _$PTCGCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$PTCGCardImplFromJson(json);

  @override
  final int? id;
// 系统分配的id，可以为空
  @override
  final int projectId;
// 所属项目Id
  @override
  final int pokedexNumber;
// 宝可梦图鉴编号
  @override
  final String name;
// 卡片名字
  @override
  final String issueNumber;
// 卡片发行编号
  @override
  final String issueDate;
// 发行时间
  @override
  final String grade;
// 评级
  @override
  final String acquiredDate;
// 入手时间
  @override
  final double acquiredPrice;
// 入手价格
  @override
  final double currentPrice;
// 当前成交价
  @override
  final String? frontImage;
// 正面图
  @override
  final String? backImage;
// 背面图
  @override
  final String? gradeImage;

  @override
  String toString() {
    return 'PTCGCard(id: $id, projectId: $projectId, pokedexNumber: $pokedexNumber, name: $name, issueNumber: $issueNumber, issueDate: $issueDate, grade: $grade, acquiredDate: $acquiredDate, acquiredPrice: $acquiredPrice, currentPrice: $currentPrice, frontImage: $frontImage, backImage: $backImage, gradeImage: $gradeImage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PTCGCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.pokedexNumber, pokedexNumber) ||
                other.pokedexNumber == pokedexNumber) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.issueNumber, issueNumber) ||
                other.issueNumber == issueNumber) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.acquiredDate, acquiredDate) ||
                other.acquiredDate == acquiredDate) &&
            (identical(other.acquiredPrice, acquiredPrice) ||
                other.acquiredPrice == acquiredPrice) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.frontImage, frontImage) ||
                other.frontImage == frontImage) &&
            (identical(other.backImage, backImage) ||
                other.backImage == backImage) &&
            (identical(other.gradeImage, gradeImage) ||
                other.gradeImage == gradeImage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      projectId,
      pokedexNumber,
      name,
      issueNumber,
      issueDate,
      grade,
      acquiredDate,
      acquiredPrice,
      currentPrice,
      frontImage,
      backImage,
      gradeImage);

  /// Create a copy of PTCGCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PTCGCardImplCopyWith<_$PTCGCardImpl> get copyWith =>
      __$$PTCGCardImplCopyWithImpl<_$PTCGCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PTCGCardImplToJson(
      this,
    );
  }
}

abstract class _PTCGCard implements PTCGCard {
  const factory _PTCGCard(
      {final int? id,
      required final int projectId,
      required final int pokedexNumber,
      required final String name,
      required final String issueNumber,
      required final String issueDate,
      required final String grade,
      required final String acquiredDate,
      required final double acquiredPrice,
      required final double currentPrice,
      final String? frontImage,
      final String? backImage,
      final String? gradeImage}) = _$PTCGCardImpl;

  factory _PTCGCard.fromJson(Map<String, dynamic> json) =
      _$PTCGCardImpl.fromJson;

  @override
  int? get id; // 系统分配的id，可以为空
  @override
  int get projectId; // 所属项目Id
  @override
  int get pokedexNumber; // 宝可梦图鉴编号
  @override
  String get name; // 卡片名字
  @override
  String get issueNumber; // 卡片发行编号
  @override
  String get issueDate; // 发行时间
  @override
  String get grade; // 评级
  @override
  String get acquiredDate; // 入手时间
  @override
  double get acquiredPrice; // 入手价格
  @override
  double get currentPrice; // 当前成交价
  @override
  String? get frontImage; // 正面图
  @override
  String? get backImage; // 背面图
  @override
  String? get gradeImage;

  /// Create a copy of PTCGCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PTCGCardImplCopyWith<_$PTCGCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
