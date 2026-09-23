import 'package:dio/dio.dart';

Dio createRickMortyClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://rickandmortyapi.com/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
}
