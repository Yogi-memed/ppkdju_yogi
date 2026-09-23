import 'package:json_annotation/json_annotation.dart';

part 'character_model.g.dart';

@JsonSerializable()
class CharacterModel {
  final int? id;
  final String? name;
  final String? status;
  final String? species;
  final String? gender;
  final String? image;
  final CharacterOrigin? origin;

  CharacterModel({
    this.id,
    this.name,
    this.status,
    this.species,
    this.gender,
    this.image,
    this.origin,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterModelToJson(this);
}

@JsonSerializable()
class CharacterOrigin {
  final String? name;

  CharacterOrigin({this.name});

  factory CharacterOrigin.fromJson(Map<String, dynamic> json) =>
      _$CharacterOriginFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterOriginToJson(this);
}

@JsonSerializable()
class CharacterResponse {
  final List<CharacterModel>? results;

  CharacterResponse({this.results});

  factory CharacterResponse.fromJson(Map<String, dynamic> json) =>
      _$CharacterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterResponseToJson(this);
}
