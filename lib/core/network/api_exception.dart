// lib/core/network/api_exception.dart

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, this.statusCode, this.errors});

  /// Parse dari DioException — handle semua format response Laravel
  factory ApiException.fromDio(DioException e) {
    final response = e.response;

    // Tidak ada response (timeout, no internet, dll)
    if (response == null) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => ApiException(
          message: 'Koneksi timeout. Periksa jaringan Anda.',
          statusCode: null,
        ),
        DioExceptionType.connectionError => ApiException(
          message:
              'Tidak dapat terhubung ke server. Pastikan server aktif dan IP benar.',
          statusCode: null,
        ),
        _ => ApiException(
          message: e.message ?? 'Terjadi kesalahan jaringan.',
          statusCode: null,
        ),
      };
    }

    final statusCode = response.statusCode;
    final data = response.data;

    // ── Ekstrak pesan error dari response Laravel ──────────────────
    String message = _extractMessage(data, statusCode);
    Map<String, dynamic>? errors = _extractErrors(data);

    return ApiException(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Ambil pesan utama dari berbagai format response Laravel
  static String _extractMessage(dynamic data, int? statusCode) {
    if (data == null) return _defaultMessage(statusCode);

    if (data is Map<String, dynamic>) {
      // Format: { "message": "...", "errors": {...} }  ← Laravel validation (422)
      // Format: { "success": false, "message": "..." } ← Custom response
      final msg = data['message'];
      if (msg != null && msg.toString().isNotEmpty) {
        // Jika ada errors, ambil error pertama sebagai pesan utama
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstField = errors.values.first;
          if (firstField is List && firstField.isNotEmpty) {
            return firstField.first.toString();
          }
        }
        return msg.toString();
      }
    }

    if (data is String && data.isNotEmpty) return data;

    return _defaultMessage(statusCode);
  }

  /// Ambil map errors dari response Laravel validation
  static Map<String, dynamic>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) return errors;
    }
    return null;
  }

  static String _defaultMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Permintaan tidak valid.',
      401 => 'Sesi habis. Silakan login kembali.',
      403 => 'Anda tidak memiliki akses.',
      404 => 'Data tidak ditemukan.',
      422 => 'Data yang dimasukkan tidak valid.',
      429 => 'Terlalu banyak permintaan. Coba lagi nanti.',
      500 => 'Terjadi kesalahan pada server.',
      503 => 'Server sedang tidak tersedia.',
      _ => 'Terjadi kesalahan (${statusCode ?? "unknown"}).',
    };
  }

  @override
  String toString() => message;
}
