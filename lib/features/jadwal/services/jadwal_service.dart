// lib/features/jadwal/services/jadwal_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/jadwal_model.dart';

class JadwalService {
  final Dio _dio = ApiClient.instance.dio;

  // ── GET LIST JADWAL ───────────────────────────────────
  Future<List<JadwalModel>> getList({String? filter}) async {
    try {
      final res = await _dio.get(
        ApiConstants.jadwal,
        queryParameters: filter != null ? {'filter': filter} : null,
      );
      final List data = res.data['data']['data'] as List? ??
          res.data['data'] as List? ?? [];
      return data.map((e) => JadwalModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── BUAT JADWAL BARU (KF-008) ─────────────────────────
  Future<JadwalModel> buat({
    required String tglKegiatan,
    required String lokasi,
    String? agenda,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.jadwal,
        data: {
          'tgl_kegiatan': tglKegiatan,
          'lokasi':       lokasi,
          if (agenda != null && agenda.isNotEmpty) 'agenda': agenda,
        },
      );
      return JadwalModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── UPDATE JADWAL ─────────────────────────────────────
  Future<JadwalModel> update({
    required int idJadwal,
    required String tglKegiatan,
    required String lokasi,
    String? agenda,
  }) async {
    try {
      final res = await _dio.put(
        ApiConstants.jadwalUpdate(idJadwal),
        data: {
          'tgl_kegiatan': tglKegiatan,
          'lokasi':       lokasi,
          'agenda':       agenda,
        },
      );
      return JadwalModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── HAPUS JADWAL ──────────────────────────────────────
  Future<void> hapus(int idJadwal) async {
    try {
      await _dio.delete(ApiConstants.jadwalDelete(idJadwal));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}