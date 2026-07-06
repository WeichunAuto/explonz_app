import '../../../../core/utils/typedef.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class LoginWithFacebookUseCase {
  const LoginWithFacebookUseCase(this._repository);
  final AuthRepository _repository;

  FutureEither<AuthResponse> call() => _repository.loginWithFacebook();
}
