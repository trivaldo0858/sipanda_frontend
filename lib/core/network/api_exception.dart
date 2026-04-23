// lib/core/network/api_exception.dart

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  /// Parse DioException menjadi ApiException yang lebih ramah
  factory ApiException.fromDio(DioException e) {
    final response = e.response;

    if (response == null) {
      return ApiException(
        message: _networkErrorMessage(e.type),
        statusCode: null,
      );
    }

    final data = response.data;
    String message = 'Terjadi kesalahan.';
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? message;
      errors  = data['errors'] as Map<String, dynamic>?;

      // Gabungkan pesan validasi jika ada
      if (errors != null) {
        final validationMessages = errors.values
            .expand((e) => e is List ? e : [e])
            .join('\n');
        if (validationMessages.isNotEmpty) message = validationMessages;
      }
    }

    return ApiException(
      message: message,
      statusCode: response.statusCode,
      errors: errors,
    );
  }

  static String _networkErrorMessage(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout => 'Koneksi timeout. Periksa jaringan Anda.',
      DioExceptionType.receiveTimeout    => 'Server tidak merespons. Coba lagi.',
      DioExceptionType.connectionError   => 'Tidak dapat terhubung ke server.',
      _                                  => 'Terjadi kesalahan jaringan.',
    };
  }

  @override
  String toString() => message;
}