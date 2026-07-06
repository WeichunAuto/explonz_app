import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/social_auth_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this._remote,
    required this._local,
    required this._social,
  });

  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;
  final SocialAuthDatasource _social;

  @override
  FutureEither<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.loginWithEmail(
        email: email,
        password: password,
      );
      await _local.saveToken(model.toTokenModel());
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  FutureEither<AuthResponse> loginWithGoogle() async {
    try {
      final idToken = await _social.signInWithGoogle();
      if (idToken == null) return const Left(Failure.cancelled());
      final model = await _remote.loginWithGoogle(idToken: idToken);
      await _local.saveToken(model.toTokenModel());
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  FutureEither<AuthResponse> loginWithFacebook() async {
    try {
      final accessToken = await _social.signInWithFacebook();
      if (accessToken == null) return const Left(Failure.cancelled());
      final model = await _remote.loginWithFacebook(accessToken: accessToken);
      await _local.saveToken(model.toTokenModel());
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  FutureEither<AuthToken> refreshToken() async {
    try {
      final current = await _local.readToken();
      if (current == null) return const Left(Failure.unauthorized());
      final model = await _remote.refreshToken(
        refreshToken: current.refreshToken,
      );
      await _local.saveToken(model);
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  FutureEither<User> getCurrentUser() async {
    try {
      final model = await _remote.getCurrentUser();
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  bool get isLoggedIn {
    // Synchronous check is not possible with async secure storage;
    // AuthNotifier.build() calls readToken() and handles the async check.
    // This getter is kept for interface compliance.
    return false;
  }

  @override
  FutureEitherVoid logout() async {
    try {
      await _local.deleteToken();
      return const Right(unit);
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  remote: ref.read(authRemoteDatasourceProvider),
  local: ref.read(authLocalDatasourceProvider),
  social: ref.read(socialAuthDatasourceProvider),
);
