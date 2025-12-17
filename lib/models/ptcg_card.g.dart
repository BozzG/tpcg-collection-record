// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ptcg_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PTCGCardImpl _$$PTCGCardImplFromJson(Map<String, dynamic> json) =>
    _$PTCGCardImpl(
      id: (json['id'] as num?)?.toInt(),
      projectId: (json['projectId'] as num).toInt(),
      pokedexNumber: (json['pokedexNumber'] as num).toInt(),
      name: json['name'] as String,
      issueNumber: json['issueNumber'] as String,
      issueDate: json['issueDate'] as String,
      grade: json['grade'] as String,
      acquiredDate: json['acquiredDate'] as String,
      acquiredPrice: (json['acquiredPrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      frontImage: json['frontImage'] as String?,
      backImage: json['backImage'] as String?,
      gradeImage: json['gradeImage'] as String?,
    );

Map<String, dynamic> _$$PTCGCardImplToJson(_$PTCGCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'pokedexNumber': instance.pokedexNumber,
      'name': instance.name,
      'issueNumber': instance.issueNumber,
      'issueDate': instance.issueDate,
      'grade': instance.grade,
      'acquiredDate': instance.acquiredDate,
      'acquiredPrice': instance.acquiredPrice,
      'currentPrice': instance.currentPrice,
      'frontImage': instance.frontImage,
      'backImage': instance.backImage,
      'gradeImage': instance.gradeImage,
    };
