import '../../../../core/utils/typedef.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailParams {
  const LoginWithEmailParams({required this.email, required this.password});
  final String email;
  final String password;
}

class LoginWithEmailUseCase {
  const LoginWithEmailUseCase(this._repository);
  final AuthRepository _repository;

  FutureEither<AuthResponse> call(LoginWithEmailParams params) => _repository
      .loginWithEmail(email: params.email, password: params.password);
}
