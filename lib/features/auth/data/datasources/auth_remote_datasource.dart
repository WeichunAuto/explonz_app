import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

abstract interface class AuthRemoteDatasource {
  Future<AuthResponseModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> loginWithGoogle({required String idToken});

  Future<AuthResponseModel> loginWithFacebook({required String accessToken});

  Future<AuthTokenModel> refreshToken({required String refreshToken});

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  const AuthRemoteDatasourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<AuthResponseModel> loginWithEmail({
    required String email,
    required String password,
  }) => _post('/auth/login', {
    'email': email,
    'password': password,
  }, AuthResponseModel.fromJson);

  @override
  Future<AuthResponseModel> loginWithGoogle({required String idToken}) =>
      _post('/auth/google', {'id_token': idToken}, AuthResponseModel.fromJson);

  @override
  Future<AuthResponseModel> loginWithFacebook({required String accessToken}) =>
      _post('/auth/facebook', {
        'access_token': accessToken,
      }, AuthResponseModel.fromJson);

  @override
  Future<AuthTokenModel> refreshToken({required String refreshToken}) => _post(
    '/auth/refresh',
    {'refresh_token': refreshToken},
    AuthTokenModel.fromJson,
  );

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/users/me');
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> _post<T>(
    String path,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      print("data = $response.data!['data']");
      return fromJson(response.data!["data"]);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Failure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Failure.network(message: e.message ?? 'Network error');
    }
    final statusCode = e.response?.statusCode;
    // print("response is : ");
    // print(e.response?.data?["msg"]);
    // print("statusCode = $statusCode");
    // // String msg = e.response?['msg'];
    // print("message = $e.message");
    if (statusCode == 401) {
      return const Failure.unauthorized();
    }
    return Failure.server(
      message: e.response?.data?["msg"],
      statusCode: statusCode,
    );
  }
}

@Riverpod(keepAlive: true)
AuthRemoteDatasource authRemoteDatasource(Ref ref) =>
    AuthRemoteDatasourceImpl(ref.read(dioProvider));
