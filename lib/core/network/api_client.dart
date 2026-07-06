import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constants.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import 'auth_interceptor.dart';

part 'api_client.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final local = ref.read(authLocalDatasourceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(
      readToken: local.readToken,
      saveToken: local.saveToken,
      deleteToken: local.deleteToken,
    ),
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
      compact: true,
    ),
  ]);

  return dio;
}
