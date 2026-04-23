// lib/data/services/jadwal_service.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';
import '../models/jadwal_model.dart';
import '../models/laporan_model.dart';

class JadwalService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<PaginatedResponse<JadwalPosyanduModel>>> getAll({
    String? filter,
    int? idKader,
    int page = 1,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.jadwal, queryParameters: {
        'page':     page,
        'filter':   filter,
        'id_kader': idKader,
      }..removeWhere((_, v) => v == null));

      return ApiResponse.success(
        PaginatedResponse.fromJson(res.data['data'], JadwalPosyanduModel.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<JadwalPosyanduModel>> getById(int id) async {
    try {
      final res = await _dio.get(ApiConstants.jadwalDetail(id));
      return ApiResponse.success(JadwalPosyanduModel.fromJson(res.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<JadwalPosyanduModel>> create(JadwalPosyanduModel jadwal) async {
    try {
      final res = await _dio.post(ApiConstants.jadwal, data: jadwal.toJson());
      return ApiResponse.success(
        JadwalPosyanduModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<JadwalPosyanduModel>> update(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put(ApiConstants.jadwalDetail(id), data: data);
      return ApiResponse.success(
        JadwalPosyanduModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<bool>> delete(int id) async {
    try {
      final res = await _dio.delete(ApiConstants.jadwalDetail(id));
      return ApiResponse.success(true, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}