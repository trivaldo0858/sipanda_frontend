// lib/data/services/anak_service.dart

import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/api_response.dart';
import '../models/anak_model.dart';
import '../models/laporan_model.dart';

class AnakService {
  final Dio _dio = ApiClient.instance.dio;

  // ── List Anak ─────────────────────────────────────────────────────
  Future<ApiResponse<PaginatedResponse<AnakModel>>> getAll({
    String? search,
    int page = 1,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.anak, queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
      });

      final paginated = PaginatedResponse.fromJson(
        res.data['data'],
        AnakModel.fromJson,
      );
      return ApiResponse.success(paginated);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Detail Anak ───────────────────────────────────────────────────
  Future<ApiResponse<AnakModel>> getByNik(String nik) async {
    try {
      final res = await _dio.get(ApiConstants.anakDetail(nik));
      return ApiResponse.success(AnakModel.fromJson(res.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Tambah Anak ───────────────────────────────────────────────────
  Future<ApiResponse<AnakModel>> create(AnakModel anak) async {
    try {
      final res = await _dio.post(ApiConstants.anak, data: anak.toJson());
      return ApiResponse.success(
        AnakModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Update Anak ───────────────────────────────────────────────────
  Future<ApiResponse<AnakModel>> update(String nik, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put(ApiConstants.anakDetail(nik), data: data);
      return ApiResponse.success(
        AnakModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Hapus Anak ────────────────────────────────────────────────────
  Future<ApiResponse<bool>> delete(String nik) async {
    try {
      final res = await _dio.delete(ApiConstants.anakDetail(nik));
      return ApiResponse.success(true, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Grafik Perkembangan ───────────────────────────────────────────
  Future<ApiResponse<List<PerkembanganItem>>> getPerkembangan(String nik) async {
    try {
      final res = await _dio.get(ApiConstants.anakPerkembangan(nik));
      final list = (res.data['data']['pemeriksaan'] as List)
          .map((e) => PerkembanganItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}