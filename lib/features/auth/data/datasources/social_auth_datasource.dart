import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'social_auth_datasource.g.dart';

abstract interface class SocialAuthDatasource {
  /// Launches Google Sign-In. Returns the ID token, or null if cancelled.
  Future<String?> signInWithGoogle();

  /// Launches Facebook Login. Returns the access token, or null if cancelled.
  Future<String?> signInWithFacebook();
}

/// Stub implementation — Google/Facebook SDKs are not integrated yet.
/// Returns null (treated as user-cancelled) so the auth flow stays intact.
class SocialAuthDatasourceImpl implements SocialAuthDatasource {
  const SocialAuthDatasourceImpl();

  @override
  Future<String?> signInWithGoogle() async => null;

  @override
  Future<String?> signInWithFacebook() async => null;
}

@Riverpod(keepAlive: true)
SocialAuthDatasource socialAuthDatasource(Ref ref) =>
    const SocialAuthDatasourceImpl();
