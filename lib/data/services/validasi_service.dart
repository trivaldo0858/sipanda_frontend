// lib/data/services/validasi_service.dart

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';

class ValidasiService {
  final Dio _dio = ApiClient.instance.dio;

  /// Ambil semua data yang menunggu validasi
  Future<ApiResponse<Map<String, dynamic>>> getMenungguValidasi() async {
    try {
      final res = await _dio.get('/validasi');
      return ApiResponse.success(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  /// Validasi pemeriksaan — setujui atau tolak
  Future<ApiResponse<bool>> validasiPemeriksaan({
    required int id,
    required String statusValidasi,
    String? catatanValidasi,
  }) async {
    try {
      await _dio.patch('/validasi/pemeriksaan/$id', data: {
        'status_validasi':   statusValidasi,
        'catatan_validasi':  catatanValidasi,
      }..removeWhere((_, v) => v == null));
      return ApiResponse.success(
        true,
        message: 'Pemeriksaan berhasil $statusValidasi.',
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  /// Validasi imunisasi — setujui atau tolak
  Future<ApiResponse<bool>> validasiImunisasi({
    required int id,
    required String statusValidasi,
    String? catatanValidasi,
  }) async {
    try {
      await _dio.patch('/validasi/imunisasi/$id', data: {
        'status_validasi':   statusValidasi,
        'catatan_validasi':  catatanValidasi,
      }..removeWhere((_, v) => v == null));
      return ApiResponse.success(
        true,
        message: 'Imunisasi berhasil $statusValidasi.',
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }
}