// lib/features/imunisasi/services/imunisasi_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/imunisasi_model.dart';

class ImunisasiService {
  final Dio _dio = ApiClient.instance.dio;

  // ── GET JENIS VAKSIN ──────────────────────────────────
  Future<List<JenisVaksinModel>> getJenisVaksin() async {
    try {
      final res = await _dio.get(ApiConstants.imunisasiJenisVaksin);
      final List data = res.data['data'] as List? ?? [];
      return data.map((e) => JenisVaksinModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── GET RIWAYAT IMUNISASI per anak ────────────────────
  Future<List<ImunisasiModel>> getRiwayat(String nikAnak) async {
    try {
      final res = await _dio.get(
          ApiConstants.imunisasiRiwayat(nikAnak));
      final List data = res.data['data'] as List? ?? [];
      return data.map((e) => ImunisasiModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── GET LIST IMUNISASI (semua) ─────────────────────────
  Future<List<ImunisasiModel>> getList() async {
    try {
      final res = await _dio.get(ApiConstants.imunisasi);
      final List data = res.data['data']['data'] as List? ??
          res.data['data'] as List? ?? [];
      return data.map((e) => ImunisasiModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── CATAT IMUNISASI (KF-006) ──────────────────────────
  Future<ImunisasiModel> catat({
    required String nikAnak,
    required int idVaksin,
    required String tglPemberian,
    String? catatan,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.imunisasi,
        data: {
          'nik_anak':      nikAnak,
          'id_vaksin':     idVaksin,
          'tgl_pemberian': tglPemberian,
          if (catatan != null && catatan.isNotEmpty)
            'catatan': catatan,
        },
      );
      return ImunisasiModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── HAPUS ─────────────────────────────────────────────
  Future<void> hapus(int idImunisasi) async {
    try {
      await _dio.delete(ApiConstants.imunisasiDelete(idImunisasi));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}