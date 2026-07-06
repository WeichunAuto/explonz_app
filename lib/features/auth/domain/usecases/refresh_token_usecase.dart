import '../../../../core/utils/typedef.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repository);
  final AuthRepository _repository;

  FutureEither<AuthToken> call() => _repository.refreshToken();
}
