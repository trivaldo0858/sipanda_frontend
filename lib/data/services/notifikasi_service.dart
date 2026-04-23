// lib/data/services/notifikasi_service.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';
import '../models/laporan_model.dart';
import '../models/notifikasi_model.dart';

class NotifikasiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<PaginatedResponse<NotifikasiModel>>> getAll({
    String? status,
    String? jenisNotif,
    int page = 1,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.notifikasi, queryParameters: {
        'page':        page,
        'status':      status,
        'jenis_notif': jenisNotif,
      }..removeWhere((_, v) => v == null));

      return ApiResponse.success(
        PaginatedResponse.fromJson(res.data['data'], NotifikasiModel.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiConstants.notifikasi);
      return ApiResponse.success(res.data['unread_count'] as int);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<bool>> markRead(int id) async {
    try {
      await _dio.post(ApiConstants.notifRead(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<bool>> markAllRead() async {
    try {
      await _dio.post(ApiConstants.notifMarkAllRead);
      return ApiResponse.success(true, message: 'Semua notifikasi ditandai dibaca.');
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<bool>> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.notifDelete(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}