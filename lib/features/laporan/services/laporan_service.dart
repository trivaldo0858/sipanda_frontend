// lib/features/laporan/services/laporan_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/laporan_model.dart';

class LaporanService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<LaporanModel>> getLaporanList() async {
    try {
      final res = await _dio.get('/laporan');
      final List data = res.data['data']['data'] as List? ?? res.data['data'] as List? ?? [];
      return data.map((e) => LaporanModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<LaporanModel> buatLaporan({
    required String jenis,
    required String periodeAwal,
    required String periodeAkhir,
  }) async {
    try {
      final res = await _dio.post('/laporan', data: {
        'jenis_laporan': jenis,
        'periode_awal':  periodeAwal,
        'periode_akhir': periodeAkhir,
      });
      return LaporanModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<LaporanModel> getDetail(int id) async {
    try {
      final res = await _dio.get('/laporan/$id');
      return LaporanModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> hapusLaporan(int id) async {
    try {
      await _dio.delete('/laporan/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}