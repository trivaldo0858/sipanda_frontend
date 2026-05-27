// lib/features/auth/services/auth_service.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/auth_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  // ── GET LIST POSYANDU (dropdown login Kader) ──────────
  Future<List<PosyanduItem>> getPosyanduList() async {
    try {
      final res = await _dio.get(ApiConstants.posyanduList);
      final List data = res.data['data'] as List;
      return data.map((e) => PosyanduItem.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── LOGIN KADER ────────────────────────────────────────
  Future<AuthUser> loginKader({
    required int idPosyandu,
    required String passwordKader,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.loginKader,
        data: {'id_posyandu': idPosyandu, 'password_kader': passwordKader},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final user = AuthUser.fromKaderResponse(data);
      await _saveSession(user);
      return user;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── LOGIN BIDAN ────────────────────────────────────────
  Future<AuthUser> loginBidan({
    required String username,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.loginBidan,
        data: {'username': username, 'password': password},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final user = AuthUser.fromBidanResponse(data);
      await _saveSession(user);
      return user;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── LOGIN ORANG TUA ────────────────────────────────────
  Future<AuthUser> loginOrangTua({
    required String nikAnak,
    required String tglLahir,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.loginOrangTua,
        data: {'nik_anak': nikAnak, 'tgl_lahir': tglLahir},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      final user = AuthUser.fromOrangTuaResponse(data);
      await _saveSession(user);
      return user;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
      // Tetap lanjutkan clear session meski request gagal
    } finally {
      await _clearSession();
    }
  }

  // ── CEK SESSION ────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_role');
  }

  // ── PRIVATE: Simpan session ────────────────────────────
  Future<void> _saveSession(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', user.token ?? '');
    await prefs.setString('auth_role', user.role);
    await prefs.setInt('auth_user_id', user.idUser);
    if (user.idPosyandu != null) {
      await prefs.setInt('auth_posyandu_id', user.idPosyandu!);
    }
  }

  // ── PRIVATE: Hapus session ─────────────────────────────
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_role');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_posyandu_id');
  }
}
