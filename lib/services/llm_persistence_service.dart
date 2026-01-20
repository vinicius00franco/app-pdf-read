import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart' as api;

abstract class ILlmPersistenceService {
  Future<void> persistResponse(Map<String, dynamic> payload);
}

class LlmPersistenceService implements ILlmPersistenceService {
  final Dio _dio = Dio(BaseOptions(baseUrl: api.baseUrl));

  @override
  Future<void> persistResponse(Map<String, dynamic> payload) async {
    final url = api.ApiEndpoints.llmPersist;
    await _dio.post(url, data: jsonEncode(payload), options: Options(headers: {'Content-Type': 'application/json'}));
  }
}