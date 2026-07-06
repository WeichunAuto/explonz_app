import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../models/auth_token_model.dart';

part 'auth_local_datasource.g.dart';

abstract interface class AuthLocalDatasource {
  Future<void> saveToken(AuthTokenModel token);
  Future<AuthTokenModel?> readToken();
  Future<void> deleteToken();
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunchDone();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  const AuthLocalDatasourceImpl({
    required FlutterSecureStorage secureStorage,
    required this._prefs,
  }) : _storage = secureStorage;

  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;

  @override
  Future<void> saveToken(AuthTokenModel token) async {
    final json = jsonEncode(token.toJson());
    await _storage.write(key: AppConstants.tokenKey, value: json);
  }

  @override
  Future<AuthTokenModel?> readToken() async {
    final json = await _storage.read(key: AppConstants.tokenKey);
    if (json == null) return null;
    return AuthTokenModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteToken() => _storage.delete(key: AppConstants.tokenKey);

  @override
  Future<bool> isFirstLaunch() async =>
      _prefs.getBool(AppConstants.isFirstLaunchKey) ?? true;

  @override
  Future<void> setFirstLaunchDone() =>
      _prefs.setBool(AppConstants.isFirstLaunchKey, false);
}

@Riverpod(keepAlive: true)
AuthLocalDatasource authLocalDatasource(Ref ref) => AuthLocalDatasourceImpl(
  secureStorage: const FlutterSecureStorage(),
  prefs: ref.read(sharedPreferencesProvider),
);
