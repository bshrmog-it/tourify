import 'package:dio/dio.dart';
import 'package:tourify/core/stroage/token_storage.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> _getHeaders() async {
    final token = await TokenStorage.getToken();

    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: await _getHeaders()),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'There was an error: ${e.response?.statusCode}',
      );
    }
  }

  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        options: Options(headers: await _getHeaders()),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'There was an error',
      );
    }
  }

  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.put(
        endpoint,
        data: data,
        options: Options(headers: await _getHeaders()),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'There was an error: ${e.response?.statusCode}',
      );
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await dio.delete(
        endpoint,
        options: Options(headers: await _getHeaders()),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'There was an error: ${e.response?.statusCode}',
      );
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.patch(
        endpoint,
        data: data,
        options: Options(headers: await _getHeaders()),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "There was an error");
    }
  }

  Future<dynamic> postForm(String endpoint, FormData formData) async {
    try {
      final response = await dio.post('$baseUrl$endpoint', data: formData);

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }
}
