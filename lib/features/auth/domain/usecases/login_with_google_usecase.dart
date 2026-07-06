import '../../../../core/utils/typedef.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  const LoginWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  FutureEither<AuthResponse> call() => _repository.loginWithGoogle();
}
