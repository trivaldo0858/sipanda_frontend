// lib/core/network/api_exception.dart
//
// Pastikan file ini ada — AuthService melempar ApiException.fromDio()
// Error message yang ditampilkan di LoginScreen berasal dari sini.

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  /// Parse error dari DioException menjadi pesan yang ramah pengguna
  factory ApiException.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException(
        message:
            'Koneksi timeout. Pastikan server berjalan dan IP sudah benar.',
        statusCode: null,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi dan IP di api_constants.dart.',
        statusCode: null,
      );
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Laravel mengembalikan errors dalam format {errors: {field: [msg]}} atau {message: '...'}
    if (data is Map<String, dynamic>) {
      // Validasi error (422)
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return ApiException(
            message: firstError.first.toString(),
            statusCode: statusCode,
          );
        }
      }
      // Pesan umum
      if (data['message'] != null) {
        return ApiException(
          message: data['message'].toString(),
          statusCode: statusCode,
        );
      }
    }

    return ApiException(
      message: 'Terjadi kesalahan (${statusCode ?? 'unknown'}). Coba lagi.',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}
