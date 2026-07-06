import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_token.dart';
import 'user.dart';

part 'auth_response.freezed.dart';

/// Aggregates the login response from the server (token + user in one payload).
/// Used by all login endpoints: /auth/login, /auth/google, /auth/facebook.
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({required AuthToken token, required User user}) =
      _AuthResponse;
}
