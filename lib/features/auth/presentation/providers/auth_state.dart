import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  /// Initial state before the local token check completes on app start.
  const factory AuthState.initial() = AuthInitial;

  /// Token exists locally; fetching user from the server.
  const factory AuthState.loading() = AuthLoading;

  /// Successfully authenticated with a valid user.
  const factory AuthState.authenticated(User user) = AuthAuthenticated;

  /// No valid token — user must log in.
  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  /// A login attempt failed with a recoverable error.
  const factory AuthState.error(Failure failure) = AuthError;
}
