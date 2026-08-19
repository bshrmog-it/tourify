import '../models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// لما يسجل مكتب سياحي جديد ولازم يستنى موافقة الأدمن
class AuthRegisterPendingApproval extends AuthState {
  final String message;
  AuthRegisterPendingApproval(this.message);
}

class AuthSuccess extends AuthState {
  final UserModel user;
  final String role;
  final String token;

  AuthSuccess({required this.user, required this.role, required this.token});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
