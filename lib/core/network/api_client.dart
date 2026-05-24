import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String authTokenStorageKey = 'auth_token';

const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

final Provider<FlutterSecureStorage> secureStorageProvider =
    Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

final Provider<Dio> apiClientProvider = Provider<Dio>((ref) {
  final String baseUrl = _apiBaseUrl.trim();

  if (baseUrl.isEmpty) {
    throw StateError(
      'Missing API_BASE_URL. Run with '
      '--dart-define=API_BASE_URL=https://api.example.com',
    );
  }

  final FlutterSecureStorage secureStorage = ref.watch(secureStorageProvider);
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const <String, String>{
        Headers.acceptHeader: Headers.jsonContentType,
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(secureStorage));

  return dio;
});

class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await _secureStorage.read(key: authTokenStorageKey);
    final String? normalizedToken = token?.trim();

    if (normalizedToken != null && normalizedToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $normalizedToken';
    }

    handler.next(options);
  }
}
