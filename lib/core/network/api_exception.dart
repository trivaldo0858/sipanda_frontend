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

  factory ApiException.fromDio(DioException e) {
    final response = e.response;

    if (response == null) {
      return ApiException(
        message: _networkErrorMessage(e.type),
        statusCode: null,
      );
    }

    final data = response.data;
    String msg = 'Terjadi kesalahan.';
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      msg    = data['message'] as String? ?? msg;
      errors = data['errors'] as Map<String, dynamic>?;

      // Gabungkan pesan validasi jika ada
      if (errors != null) {
        final validationMessages = errors.values
            .expand((e) => e is List ? e : [e])
            .join('\n');
        if (validationMessages.isNotEmpty) msg = validationMessages;
      }
    }

    return ApiException(
      message: msg,
      statusCode: response.statusCode,
      errors: errors,
    );
  }

  /// Cek apakah error ini karena unauthenticated
  bool get isUnauthorized => statusCode == 401;

  /// Cek apakah error validasi (422)
  bool get isValidation => statusCode == 422;

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