// lib/data/services/imunisasi_service.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';
import '../models/imunisasi_model.dart';
import '../models/laporan_model.dart';

class ImunisasiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<PaginatedResponse<ImunisasiModel>>> getAll({
    String? nikAnak,
    int? idVaksin,
    int page = 1,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.imunisasi, queryParameters: {
        'page':      page,
        'nik_anak':  nikAnak,
        'id_vaksin': idVaksin,
      }..removeWhere((_, v) => v == null));

      return ApiResponse.success(
        PaginatedResponse.fromJson(res.data['data'], ImunisasiModel.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<ImunisasiModel>> getById(int id) async {
    try {
      final res = await _dio.get(ApiConstants.imunisasiDetail(id));
      return ApiResponse.success(ImunisasiModel.fromJson(res.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<ImunisasiModel>> create(ImunisasiModel imunisasi) async {
    try {
      final res = await _dio.post(ApiConstants.imunisasi, data: imunisasi.toJson());
      return ApiResponse.success(
        ImunisasiModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<ImunisasiModel>> update(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put(ApiConstants.imunisasiDetail(id), data: data);
      return ApiResponse.success(
        ImunisasiModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<bool>> delete(int id) async {
    try {
      final res = await _dio.delete(ApiConstants.imunisasiDetail(id));
      return ApiResponse.success(true, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}

// ── Jenis Vaksin ──────────────────────────────────────────────────────
class JenisVaksinService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<List<JenisVaksinModel>>> getAll() async {
    try {
      final res = await _dio.get(ApiConstants.vaksin);
      final list = (res.data['data'] as List)
          .map((e) => JenisVaksinModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<JenisVaksinModel>> create(JenisVaksinModel v) async {
    try {
      final res = await _dio.post(ApiConstants.vaksin, data: v.toJson());
      return ApiResponse.success(
        JenisVaksinModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<bool>> delete(int id) async {
    try {
      final res = await _dio.delete(ApiConstants.vaksinDetail(id));
      return ApiResponse.success(true, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}