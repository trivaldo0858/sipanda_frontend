// lib/data/services/dashboard_service.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';

class DashboardService {
  final Dio _dio = ApiClient.instance.dio;

  /// Mengembalikan Map berisi data dashboard.
  /// Struktur berbeda per role: Bidan, Kader, atau OrangTua.
  /// Parsing lanjut dilakukan di layer Provider/UI.
  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    try {
      final res = await _dio.get(ApiConstants.dashboard);
      return ApiResponse.success(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}