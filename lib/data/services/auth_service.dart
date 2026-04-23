// lib/data/services/auth_service.dart
// VERSI TERBARU — ganti file lama dengan ini

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/api_response.dart';
import '../models/pengguna_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  // ── Login Kader / Bidan ───────────────────────────────────────────
  Future<ApiResponse<AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await _dio.post(ApiConstants.login, data: {
        'username': username,
        'password': password,
      });
      final authResponse = AuthResponse.fromJson(res.data['data']);
      await _simpanSession(authResponse);
      return ApiResponse.success(authResponse, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Login Orang Tua — NIK Balita + Tanggal Lahir ──────────────────
  Future<ApiResponse<AuthResponse>> loginOrangTua({
    required String nikBalita,
    required String tglLahir, // format: 'yyyy-MM-dd'
  }) async {
    try {
      final res = await _dio.post(ApiConstants.loginOrangTua, data: {
        'nik_balita': nikBalita,
        'tgl_lahir':  tglLahir,
      });

      final authResponse = AuthResponse.fromJson(res.data['data']);
      await _simpanSession(authResponse);

      // Simpan juga data anak yang dipakai login (untuk ditampilkan di home)
      final anakLogin = res.data['data']['anak_login'];
      if (anakLogin != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('anak_login', jsonEncode(anakLogin));
      }

      return ApiResponse.success(authResponse, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Login Google ──────────────────────────────────────────────────
  Future<ApiResponse<AuthResponse>> loginGoogle({
    required String googleId,
    required String emailGoogle,
    required int idUser,
  }) async {
    try {
      final res = await _dio.post(ApiConstants.loginGoogle, data: {
        'google_id':    googleId,
        'email_google': emailGoogle,
        'id_user':      idUser,
      });
      final authResponse = AuthResponse.fromJson(res.data['data']);
      await _simpanSession(authResponse);
      return ApiResponse.success(authResponse, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────
  Future<ApiResponse<bool>> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
      await _hapusSession();
      return ApiResponse.success(true, message: 'Logout berhasil.');
    } on DioException catch (e) {
      await _hapusSession();
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Data user login ───────────────────────────────────────────────
  Future<ApiResponse<PenggunaModel>> getMe() async {
    try {
      final res = await _dio.get(ApiConstants.me);
      return ApiResponse.success(PenggunaModel.fromJson(res.data['data']));
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Ubah Password ─────────────────────────────────────────────────
  Future<ApiResponse<bool>> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {
    try {
      final res = await _dio.post(ApiConstants.ubahPassword, data: {
        'password_lama':              passwordLama,
        'password_baru':              passwordBaru,
        'password_baru_confirmation': passwordBaruConfirmation,
      });
      return ApiResponse.success(true, message: res.data['message']);
    } on DioException catch (e) {
      return ApiResponse.error(ApiException.fromDio(e).message);
    }
  }

  // ── Session helpers ───────────────────────────────────────────────
  Future<void> _simpanSession(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', authResponse.token);
    await prefs.setString('auth_user', jsonEncode({
      'id_user':  authResponse.pengguna.idUser,
      'username': authResponse.pengguna.username,
      'role':     authResponse.pengguna.role,
    }));
  }

  Future<void> _hapusSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    await prefs.remove('anak_login');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  Future<PenggunaModel?> getPenggunaTersimpan() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('auth_user');
    if (userJson == null) return null;
    return PenggunaModel.fromJson(jsonDecode(userJson));
  }

  Future<Map<String, dynamic>?> getAnakLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('anak_login');
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }
}