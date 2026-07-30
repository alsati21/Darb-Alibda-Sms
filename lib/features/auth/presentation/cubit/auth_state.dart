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
  const AuthSuccess({required this.payload});

  final Map<String, dynamic> payload;
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}

class AuthValidationFailure extends AuthState {
  const AuthValidationFailure(this.errors, {this.message});

  final Map<String, dynamic> errors;
  final String? message;
}