// lib/data/services/laporan_service.dart

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';
import '../models/laporan_model.dart';

class LaporanService {
  final Dio _dio = ApiClient.instance.dio;

  Future<ApiResponse<PaginatedResponse<LaporanModel>>> getAll({
    String? jenisLaporan,
    int page = 1,
  }) async {
    try {
      final res = await _dio.get(ApiConstants.laporan, queryParameters: {
        'page':          page,
        'jenis_laporan': jenisLaporan,
      }..removeWhere((_, v) => v == null));

      return ApiResponse.success(
        PaginatedResponse.fromJson(res.data['data'], LaporanModel.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<LaporanModel>> getById(int id) async {
    try {
      final res = await _dio.get(ApiConstants.laporanDetail(id));
      return ApiResponse.success(LaporanModel.fromJson(res.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<LaporanModel>> generate({
    required String jenisLaporan,
    required String periodeAwal,
    required String periodeAkhir,
  }) async {
    try {
      final res = await _dio.post(ApiConstants.laporan, data: {
        'jenis_laporan': jenisLaporan,
        'periode_awal':  periodeAwal,
        'periode_akhir': periodeAkhir,
      });
      return ApiResponse.success(
        LaporanModel.fromJson(res.data['data']),
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<bool>> delete(int id) async {
    try {
      final res = await _dio.delete(ApiConstants.laporanDetail(id));
      return ApiResponse.success(true, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  Future<ApiResponse<String>> downloadPdf(
    int id,
    String namaFile, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final dir      = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$namaFile.pdf';

      await _dio.download(
        ApiConstants.laporanExportPdf(id),
        filePath,
        onReceiveProgress: onProgress,
        options: Options(responseType: ResponseType.bytes),
      );

      return ApiResponse.success(filePath, message: 'PDF berhasil diunduh.');
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    } catch (e) {
      return ApiResponse.error('Gagal menyimpan file: $e');
    }
  }

  Future<ApiResponse<String>> downloadExcel(
    int id,
    String namaFile, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final dir      = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$namaFile.xlsx';

      await _dio.download(
        ApiConstants.laporanExportExcel(id),
        filePath,
        onReceiveProgress: onProgress,
        options: Options(responseType: ResponseType.bytes),
      );

      return ApiResponse.success(filePath, message: 'Excel berhasil diunduh.');
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    } catch (e) {
      return ApiResponse.error('Gagal menyimpan file: $e');
    }
  }
}