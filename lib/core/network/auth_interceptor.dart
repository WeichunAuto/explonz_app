import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../../features/auth/data/models/auth_token_model.dart';

/// Handles automatic Bearer token injection and silent token refresh on 401.
///
/// Uses a separate [Dio] instance for the refresh call and retry to avoid
/// re-triggering this interceptor (which would cause an infinite 401 loop).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.readToken,
    required this.saveToken,
    required this.deleteToken,
  }) : _refreshDio = Dio(
         BaseOptions(
           baseUrl: AppConstants.baseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
           headers: {'Content-Type': 'application/json'},
         ),
       );

  final Future<AuthTokenModel?> Function() readToken;
  final Future<void> Function(AuthTokenModel) saveToken;
  final Future<void> Function() deleteToken;

  /// Isolated Dio — no interceptors, used for refresh + retry only.
  final Dio _refreshDio;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      handler.next(err);
      return;
    }

    final current = await readToken();
    if (current == null || current.toEntity().isRefreshTokenExpired) {
      await deleteToken();
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshResponse = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': current.refreshToken},
      );
      final newToken = AuthTokenModel.fromJson(refreshResponse.data!);
      await saveToken(newToken);

      // Retry the original request with the new access token.
      err.requestOptions.headers['Authorization'] =
          'Bearer ${newToken.accessToken}';
      final retryResponse = await _refreshDio.fetch<dynamic>(
        err.requestOptions,
      );
      handler.resolve(retryResponse);
    } catch (_) {
      await deleteToken();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
