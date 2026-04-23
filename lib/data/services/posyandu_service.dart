// lib/data/services/posyandu_service.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';
import '../models/laporan_model.dart';
import '../models/posyandu_model.dart';

class PosyanduService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<PaginatedResponse<PosyanduModel>>> getAll({
    String? search,
    String? status,
    int page = 1,
  }) async {
    try {
      final res = await _dio.get('/posyandu', queryParameters: {
        'page':   page,
        'search': search,
        'status': status,
      }..removeWhere((_, v) => v == null));

      return ApiResponse.success(
        PaginatedResponse.fromJson(res.data['data'], PosyanduModel.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<PosyanduModel>> getById(int id) async {
    try {
      final res = await _dio.get('/posyandu/$id');
      return ApiResponse.success(PosyanduModel.fromJson(res.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<PosyanduModel>> create(PosyanduModel posyandu) async {
    try {
      final res = await _dio.post('/posyandu', data: posyandu.toJson());
      return ApiResponse.success(
        PosyanduModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<PosyanduModel>> update(
      int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/posyandu/$id', data: data);
      return ApiResponse.success(
        PosyanduModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<bool>> delete(int id) async {
    try {
      final res = await _dio.delete('/posyandu/$id');
      return ApiResponse.success(true, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}