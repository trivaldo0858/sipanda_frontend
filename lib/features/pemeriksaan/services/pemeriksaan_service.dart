// lib/features/pemeriksaan/services/pemeriksaan_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/pemeriksaan_model.dart';

class PemeriksaanService {
  final Dio _dio = ApiClient.instance.dio;

  // ── GET LIST ──────────────────────────────────────────
  Future<List<PemeriksaanModel>> getList({String? nikAnak}) async {
    try {
      final res = await _dio.get(
        ApiConstants.pemeriksaan,
        queryParameters: nikAnak != null ? {'nik_anak': nikAnak} : null,
      );
      final List data = res.data['data']['data'] as List? ??
          res.data['data'] as List? ?? [];
      return data.map((e) => PemeriksaanModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── CATAT PEMERIKSAAN (KF-005) ────────────────────────
  Future<PemeriksaanModel> catat({
    required String nikAnak,
    required String tglPeriksa,
    required double beratBadan,
    required double tinggiBadan,
    required double lingkarKepala,
    String? keluhan,
    int? idJadwal,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.pemeriksaan,
        data: {
          'nik_anak':       nikAnak,
          'tgl_periksa':    tglPeriksa,
          'berat_badan':    beratBadan,
          'tinggi_badan':   tinggiBadan,
          'lingkar_kepala': lingkarKepala,
          if (keluhan != null && keluhan.isNotEmpty) 'keluhan': keluhan,
          if (idJadwal != null) 'id_jadwal': idJadwal,
        },
      );
      return PemeriksaanModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── HAPUS ─────────────────────────────────────────────
  Future<void> hapus(int idPeriksa) async {
    try {
      await _dio.delete(ApiConstants.pemeriksaanDelete(idPeriksa));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}