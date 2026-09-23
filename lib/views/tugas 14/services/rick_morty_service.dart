import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/character_model.dart';

part 'rick_morty_service.g.dart';

@RestApi()
abstract class RickMortyApi {
  factory RickMortyApi(Dio dio, {String? baseUrl}) = _RickMortyApi;

  @GET('character')
  Future<CharacterResponse> getCharacters({@Query('name') String? name});
}

class RickMortyService {
  final RickMortyApi api;

  RickMortyService(Dio dio) : api = RickMortyApi(dio);

  Future<List<CharacterModel>> fetchData({String? name}) async {
    final response = await api.getCharacters();

    return response.results ?? [];
  }
}
