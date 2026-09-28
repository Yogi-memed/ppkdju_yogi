// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterModel _$CharacterModelFromJson(Map<String, dynamic> json) =>
    CharacterModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      status: json['status'] as String?,
      species: json['species'] as String?,
      gender: json['gender'] as String?,
      image: json['image'] as String?,
      origin: json['origin'] == null
          ? null
          : CharacterOrigin.fromJson(json['origin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CharacterModelToJson(CharacterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'species': instance.species,
      'gender': instance.gender,
      'image': instance.image,
      'origin': instance.origin,
    };

CharacterOrigin _$CharacterOriginFromJson(Map<String, dynamic> json) =>
    CharacterOrigin(name: json['name'] as String?);

Map<String, dynamic> _$CharacterOriginToJson(CharacterOrigin instance) =>
    <String, dynamic>{'name': instance.name};

CharacterResponse _$CharacterResponseFromJson(Map<String, dynamic> json) =>
    CharacterResponse(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CharacterResponseToJson(CharacterResponse instance) =>
    <String, dynamic>{'results': instance.results};
