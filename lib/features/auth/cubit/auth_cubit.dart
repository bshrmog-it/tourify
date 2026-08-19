import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourify/features/auth/service/auth_service.dart';
import '../../../core/stroage/token_storage.dart';
import '../models/register_model.dart';
import '../models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();

  AuthCubit() : super(AuthInitial());

  Future<void> register(RegisterModel model) async {
    emit(AuthLoading());

    try {
      final response = await _authService.register(model);

      print("========== REGISTER SUCCESS ==========");
      print(response);
      print("======================================");

      final data = response['data'];
      final user = UserModel.fromJson(data['user'], roleFallback: model.role);

      final token = data['token'];

      if (model.role == 'agency') {
        emit(
          AuthRegisterPendingApproval(
            "تم إنشاء حساب المكتب بنجاح، بانتظار موافقة الإدارة لتفعيل الحساب",
          ),
        );
        return;
      }

      if (token != null) {
        await TokenStorage.saveToken(token);
      }

      emit(AuthSuccess(user: user, role: model.role, token: token ?? ''));
    } catch (e) {
      print("========== REGISTER ERROR ==========");

      if (e is DioException) {
        print("STATUS CODE: ${e.response?.statusCode}");
        print("RESPONSE DATA: ${e.response?.data}");
        print("RESPONSE HEADERS: ${e.response?.headers}");
        print("REQUEST URL: ${e.requestOptions.uri}");
      } else {
        print("ERROR: $e");
      }

      print("====================================");

      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final response = await _authService.login(
        username: username,
        password: password,
      );

      print("========== LOGIN SUCCESS ==========");
      print(response);
      print("===================================");

      final data = response['data'];

      final role = data['role']?.toString() ?? '';

      final user = UserModel.fromJson(data['user'], roleFallback: role);

      final token = data['token'];

      print("LOGIN ROLE: $role");
      print("LOGIN USER: ${data['user']}");
      print("LOGIN STATUS: ${user.status}");
      print("LOGIN TOKEN: $token");

      if (token != null) {
        await TokenStorage.saveToken(token);
      }

      emit(AuthSuccess(user: user, role: role, token: token ?? ''));
    } catch (e) {
      print("========== LOGIN ERROR ==========");

      if (e is DioException) {
        print("STATUS CODE: ${e.response?.statusCode}");
        print("RESPONSE DATA: ${e.response?.data}");
        print("RESPONSE HEADERS: ${e.response?.headers}");
        print("REQUEST URL: ${e.requestOptions.uri}");
      } else {
        print("ERROR: $e");
      }

      print("=================================");

      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
    emit(AuthInitial());
  }
}
