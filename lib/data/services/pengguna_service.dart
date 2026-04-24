// lib/data/services/pengguna_service.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';
import '../models/laporan_model.dart';
import '../models/pengguna_model.dart';

class PenggunaService {
  final Dio _dio = ApiClient.instance.dio;

  // ── List pengguna ─────────────────────────────────────────────────
  Future<ApiResponse<PaginatedResponse<PenggunaModel>>> getAll({
    String? role,
    String? search,
    int? idPosyandu,
    int page = 1,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.pengguna, queryParameters: {
        'page':         page,
        'role':         role,
        'search':       search,
        'id_posyandu':  idPosyandu,
      }..removeWhere((_, v) => v == null));

      return ApiResponse.success(
        PaginatedResponse.fromJson(
          res.data['data'],
          PenggunaModel.fromJson,
        ),
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Detail pengguna ───────────────────────────────────────────────
  Future<ApiResponse<PenggunaModel>> getById(int id) async {
    try {
      final res = await _dio.get(ApiConstants.penggunaDetail(id));
      return ApiResponse.success(
        PenggunaModel.fromJson(res.data['data']),
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Tambah pengguna ───────────────────────────────────────────────
  Future<ApiResponse<PenggunaModel>> create(
      Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.pengguna, data: data);
      return ApiResponse.success(
        PenggunaModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Update pengguna ───────────────────────────────────────────────
  Future<ApiResponse<PenggunaModel>> update(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _dio.put(
        ApiConstants.penggunaDetail(id),
        data: data,
      );
      return ApiResponse.success(
        PenggunaModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Hapus pengguna ────────────────────────────────────────────────
  Future<ApiResponse<bool>> delete(int id) async {
    try {
      final res = await _dio.delete(ApiConstants.penggunaDetail(id));
      return ApiResponse.success(true, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}