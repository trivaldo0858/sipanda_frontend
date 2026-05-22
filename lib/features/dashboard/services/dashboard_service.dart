// lib/features/dashboard/services/dashboard_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final Dio _dio = ApiClient.instance.dio;

  Future<DashboardKader> getDashboardKader() async {
    try {
      final res = await _dio.get(ApiConstants.dashboard);
      return DashboardKader.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DashboardBidan> getDashboardBidan() async {
    try {
      final res = await _dio.get(ApiConstants.dashboard);
      return DashboardBidan.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DashboardOrtu> getDashboardOrtu() async {
    try {
      final res = await _dio.get(ApiConstants.dashboard);
      return DashboardOrtu.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}