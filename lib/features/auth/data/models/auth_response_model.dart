import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_response.dart';
import '../../domain/entities/auth_token.dart';
import 'auth_token_model.dart';
import 'user_model.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

/// Matches POST /auth/login, /auth/google, /auth/facebook responses.
/// [ASSUMED] Token fields and user object are returned in a single response.
@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,

    /// Unix timestamp in seconds.
    @JsonKey(name: 'access_token_expires_at') required int accessTokenExpiresAt,

    /// Unix timestamp in seconds.
    @JsonKey(name: 'refresh_token_expires_at')
    required int refreshTokenExpiresAt,

    /// [ASSUMED] User data is embedded in the login response.
    required UserModel user,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}

extension AuthResponseModelX on AuthResponseModel {
  AuthResponse toEntity() => AuthResponse(
    token: AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: DateTime.fromMillisecondsSinceEpoch(
        accessTokenExpiresAt * 1000,
      ),
      refreshTokenExpiresAt: DateTime.fromMillisecondsSinceEpoch(
        refreshTokenExpiresAt * 1000,
      ),
    ),
    user: user.toEntity(),
  );

  /// Extract only the token part for local storage.
  AuthTokenModel toTokenModel() => AuthTokenModel(
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessTokenExpiresAt: accessTokenExpiresAt,
    refreshTokenExpiresAt: refreshTokenExpiresAt,
  );
}
