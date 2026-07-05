enum AuthFlowType { signup, login, google }

abstract class AuthEvent {
  const AuthEvent();
}

class SignupSubmitted extends AuthEvent {
  const SignupSubmitted({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String email;
  final String password;
  final String confirmPassword;
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested({required this.source});

  final AuthFlowType source;
}
