import '../../../../core/utils/typedef.dart';
import '../entities/auth_response.dart';
import '../entities/auth_token.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  /// Email + Password login. Returns token + user in one response.
  FutureEither<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  });

  /// Google OAuth login/register (includes silent account merge when email matches).
  FutureEither<AuthResponse> loginWithGoogle();

  /// Facebook OAuth login/register (includes silent account merge when email matches).
  FutureEither<AuthResponse> loginWithFacebook();

  /// Silently refresh the access token using the refresh token.
  /// Response does not include user data.
  FutureEither<AuthToken> refreshToken();

  /// Fetch the current user from the server.
  /// Called on app restart when a local token exists but user is not cached.
  FutureEither<User> getCurrentUser();

  /// Synchronous local check: true if a non-expired refresh token exists.
  bool get isLoggedIn;

  /// Clear all local tokens (logout).
  FutureEitherVoid logout();
}
