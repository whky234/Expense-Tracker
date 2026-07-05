import 'auth_event.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess({required this.message, required this.flowType});

  final String message;
  final AuthFlowType flowType;
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}
