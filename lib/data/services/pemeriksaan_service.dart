// lib/data/services/pemeriksaan_service.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';
import '../models/laporan_model.dart';
import '../models/pemeriksaan_model.dart';

class PemeriksaanService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<PaginatedResponse<PemeriksaanModel>>> getAll({
    String? nikAnak,
    int? idJadwal,
    String? tglDari,
    String? tglSampai,
    int page = 1,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.pemeriksaan, queryParameters: {
        'page':       page,
        'nik_anak':   nikAnak,
        'id_jadwal':  idJadwal,
        'tgl_dari':   tglDari,
        'tgl_sampai': tglSampai,
      }..removeWhere((_, v) => v == null));

      return ApiResponse.success(
        PaginatedResponse.fromJson(
          res.data['data'],
          PemeriksaanModel.fromJson,
        ),
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<PemeriksaanModel>> getById(int id) async {
    try {
      final res = await _dio.get(ApiConstants.pemeriksaanDetail(id));
      return ApiResponse.success(
        PemeriksaanModel.fromJson(res.data['data']),
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<PemeriksaanModel>> create(PemeriksaanModel p) async {
    try {
      final res = await _dio.post(
        ApiConstants.pemeriksaan,
        data: p.toJson(),
      );
      return ApiResponse.success(
        PemeriksaanModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<PemeriksaanModel>> update(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await _dio.put(
        ApiConstants.pemeriksaanDetail(id),
        data: data,
      );
      return ApiResponse.success(
        PemeriksaanModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<bool>> delete(int id) async {
    try {
      final res = await _dio.delete(ApiConstants.pemeriksaanDetail(id));
      return ApiResponse.success(true, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}