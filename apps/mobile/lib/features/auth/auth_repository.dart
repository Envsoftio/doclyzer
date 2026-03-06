class RegisterResult {
  const RegisterResult({
    required this.userId,
    required this.requiresVerification,
    required this.nextStep,
  });

  final String userId;
  final bool requiresVerification;
  final String nextStep;
}

class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.tokenType,
  });

  final String accessToken;
  final String tokenType;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<RegisterResult> register({
    required String email,
    required String password,
  });

  Future<LoginResult> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> requestPasswordReset({required String email});

  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  });
}
