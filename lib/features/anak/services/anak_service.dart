// lib/features/anak/services/anak_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/anak_model.dart';

class AnakService {
  final Dio _dio = ApiClient.instance.dio;

  // ── GET LIST ANAK ─────────────────────────────────────
  Future<List<AnakModel>> getAnakList({String? search}) async {
    try {
      final res = await _dio.get(
        ApiConstants.anak,
        queryParameters: search != null ? {'search': search} : null,
      );
      final List data = res.data['data']['data'] as List? ??
          res.data['data'] as List? ?? [];
      return data.map((e) => AnakModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── GET DETAIL ANAK ───────────────────────────────────
  Future<AnakModel> getAnakDetail(String nikAnak) async {
    try {
      final res = await _dio.get(ApiConstants.anakDetail(nikAnak));
      return AnakModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── TAMBAH ANAK (KF-004) ──────────────────────────────
  Future<AnakModel> tambahAnak({
    required String nikAnak,
    required String nikOrangTua,
    required String namaAnak,
    required String namaIbu,
    required String tglLahir,
    required String jenisKelamin,
    required String namaAyah,
    String? noTelpIbu,
    String? alamat,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.anak,
        data: {
          'nik_anak':      nikAnak,
          'nik_orang_tua': nikOrangTua,
          'nama_anak':     namaAnak,
          'nama_ibu':      namaIbu,
          'tgl_lahir':     tglLahir,
          'jenis_kelamin': jenisKelamin,
          'nama_ayah':     namaAyah,
          if (noTelpIbu != null) 'no_telp_ibu': noTelpIbu,
          if (alamat != null) 'alamat': alamat,
        },
      );
      return AnakModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── UPDATE ANAK ───────────────────────────────────────
  Future<AnakModel> updateAnak({
    required String nikAnak,
    required String namaAnak,
    required String namaIbu,
    required String tglLahir,
    required String jenisKelamin,
    required String namaAyah,
    required String nikOrangTua,
  }) async {
    try {
      final res = await _dio.put(
        ApiConstants.anakUpdate(nikAnak),
        data: {
          'nama_anak':     namaAnak,
          'nama_ibu':      namaIbu,
          'tgl_lahir':     tglLahir,
          'jenis_kelamin': jenisKelamin,
          'nama_ayah':     namaAyah,
          'nik_orang_tua': nikOrangTua,
        },
      );
      return AnakModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── HAPUS ANAK ────────────────────────────────────────
  Future<void> hapusAnak(String nikAnak) async {
    try {
      await _dio.delete(ApiConstants.anakDelete(nikAnak));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}