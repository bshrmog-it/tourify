import 'package:dio/dio.dart';
import '../../../core/network/api_service.dart';
import '../models/register_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> register(RegisterModel model) async {
    final formData = await model.toFormData();
    final response = await _apiService.postForm('/register', formData);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final formData = FormData.fromMap({
      'username': username,
      'password': password,
    });
    final response = await _apiService.postForm('/login', formData);
    return response as Map<String, dynamic>;
  }
}
