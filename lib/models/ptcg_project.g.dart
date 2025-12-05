// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ptcg_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PTCGProjectImpl _$$PTCGProjectImplFromJson(Map<String, dynamic> json) =>
    _$PTCGProjectImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      cards: (json['cards'] as List<dynamic>?)
              ?.map((e) => PTCGCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PTCGProjectImplToJson(_$PTCGProjectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'cards': instance.cards,
    };
