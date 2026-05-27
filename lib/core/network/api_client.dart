// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  // Menggunakan konstruktor privat untuk pola Singleton
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,

        // ── DI SINI FITUR TIMEOUT-NYA DIALOKASIKAN ──────────────────────────
        // Mengamankan aplikasi agar jika koneksi ke backend VPS bermasalah/lambat,
        // aplikasi tidak akan stuck di loading putih selamanya, melainkan melempar error.
        connectTimeout: const Duration(
          seconds: 15,
        ), // Maksimal tunggu koneksi ke VPS (15 detik)
        receiveTimeout: const Duration(
          seconds: 15,
        ), // Maksimal tunggu kiriman data dari Laravel

        // ───────────────────────────────────────────────────────────────────
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Mendaftarkan fungsi interceptor untuk otentikasi otomatis dan logging terminal
    _dio.interceptors.addAll([_AuthInterceptor(), _LogInterceptor()]);
  }

  // Getter untuk membagikan objek Dio ke service-service lain (AuthService, AnakService, dll)
  Dio get dio => _dio;
}

// Interceptor untuk menyisipkan Token Bearer di setiap request secara otomatis
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Jika server merespons 401 (Unauthenticated), otomatis bersihkan session lokal
    if (err.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_role');
      await prefs.remove('auth_user');
    }
    handler.next(err);
  }
}

// Interceptor untuk memantau aktivitas keluar masuknya data di terminal debug
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API OK] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API ERR] ${err.response?.statusCode} ${err.message}');
    handler.next(err);
  }
}
