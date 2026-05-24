import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/network/api_client.dart';

final Provider<AuthApi> authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(
    dio: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

class AuthApi {
  const AuthApi({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _dio.post<void>(
      '/auth/register',
      data: <String, String>{
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/auth/login',
      data: <String, String>{
        'email': email,
        'password': password,
      },
    );

    final String? accessToken = _readToken(
      response.data,
      keys: const <String>[
        'accessToken',
        'access_token',
        'token',
        'jwt',
      ],
    );
    final String? refreshToken = _readToken(
      response.data,
      keys: const <String>[
        'refreshToken',
        'refresh_token',
      ],
    );

    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('Login response did not include a JWT.');
    }

    await _secureStorage.write(
      key: authTokenStorageKey,
      value: accessToken,
    );

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(
        key: refreshTokenStorageKey,
        value: refreshToken,
      );
    }
  }

  String? _readToken(
    Object? data, {
    required List<String> keys,
  }) {
    if (data is! Map) {
      return null;
    }

    for (final String key in keys) {
      final Object? value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    const List<String> nestedKeys = <String>[
      'data',
      'tokens',
      'auth',
    ];

    for (final String nestedKey in nestedKeys) {
      final String? nestedToken = _readToken(data[nestedKey], keys: keys);
      if (nestedToken != null) {
        return nestedToken;
      }
    }

    return null;
  }
}
