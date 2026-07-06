import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/models/auth_token_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_facebook_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Kick off the async session restore and return immediately.
    Future.microtask(_restoreSession);
    return const AuthState.initial();
  }

  /// On app restart: reads the local token and fetches the user from the server
  /// if the refresh token is still valid.
  Future<void> _restoreSession() async {
    final local = ref.read(authLocalDatasourceProvider);
    final token = await local.readToken();

    if (token == null || token.toEntity().isRefreshTokenExpired) {
      state = const AuthState.unauthenticated();
      return;
    }

    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await GetCurrentUserUseCase(repository).call();

    state = result.fold(
      (_) => const AuthState.unauthenticated(),
      AuthState.authenticated,
    );
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await LoginWithEmailUseCase(
      repository,
    ).call(LoginWithEmailParams(email: email, password: password));
    state = result.fold(
      AuthState.error,
      (response) => AuthState.authenticated(response.user),
    );
  }

  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await LoginWithGoogleUseCase(repository).call();
    state = result.fold(
      (failure) => failure is CancelledFailure
          ? const AuthState.unauthenticated()
          : AuthState.error(failure),
      (response) => AuthState.authenticated(response.user),
    );
  }

  Future<void> loginWithFacebook() async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await LoginWithFacebookUseCase(repository).call();
    state = result.fold(
      (failure) => failure is CancelledFailure
          ? const AuthState.unauthenticated()
          : AuthState.error(failure),
      (response) => AuthState.authenticated(response.user),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState.unauthenticated();
  }

  void clearError() => state = const AuthState.unauthenticated();
}
