import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_token.dart';

part 'auth_token_model.freezed.dart';
part 'auth_token_model.g.dart';

/// Used exclusively for POST /auth/refresh responses (token only, no user).
/// Also used internally for local storage.
@freezed
abstract class AuthTokenModel with _$AuthTokenModel {
  const factory AuthTokenModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,

    /// Unix timestamp in seconds — confirmed by Backend (TQ3).
    @JsonKey(name: 'access_token_expires_at') required int accessTokenExpiresAt,

    /// Unix timestamp in seconds — confirmed by Backend (TQ3).
    @JsonKey(name: 'refresh_token_expires_at')
    required int refreshTokenExpiresAt,
  }) = _AuthTokenModel;

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);
}

extension AuthTokenModelX on AuthTokenModel {
  AuthToken toEntity() => AuthToken(
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessTokenExpiresAt: DateTime.fromMillisecondsSinceEpoch(
      accessTokenExpiresAt * 1000,
    ),
    refreshTokenExpiresAt: DateTime.fromMillisecondsSinceEpoch(
      refreshTokenExpiresAt * 1000,
    ),
  );
}
