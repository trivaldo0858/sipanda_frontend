// lib/features/auth/data/datasources/auth_local_datasource.dart
//
// DATA LAYER — Local Data Source
// ✅ Urusan simpan/ambil data lokal (SharedPreferences)
// ✅ Dipisah dari Remote agar mudah diganti/di-test

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';

abstract class AuthLocalDataSource {
  Future<void> simpanToken(String token);
  Future<void> simpanPengguna(PenggunaModel pengguna);
  Future<void> simpanAnakLogin(AnakLoginModel anak);
  Future<String?> getToken();
  Future<PenggunaModel?> getPengguna();
  Future<AnakLoginModel?> getAnakLogin();
  Future<void> hapusSession();
}

// ── Implementasi ──────────────────────────────────────────────────────
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // Key konstanta agar tidak typo
  static const _keyToken     = 'auth_token';
  static const _keyPengguna  = 'auth_user';
  static const _keyAnakLogin = 'anak_login';

  @override
  Future<void> simpanToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  @override
  Future<void> simpanPengguna(PenggunaModel pengguna) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPengguna, jsonEncode(pengguna.toJson()));
  }

  @override
  Future<void> simpanAnakLogin(AnakLoginModel anak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAnakLogin, jsonEncode(anak.toJson()));
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  @override
  Future<PenggunaModel?> getPengguna() async {
    final prefs = await SharedPreferences.getInstance();
    final json  = prefs.getString(_keyPengguna);
    if (json == null) return null;
    return PenggunaModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<AnakLoginModel?> getAnakLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final json  = prefs.getString(_keyAnakLogin);
    if (json == null) return null;
    return AnakLoginModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> hapusSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyToken),
      prefs.remove(_keyPengguna),
      prefs.remove(_keyAnakLogin),
    ]);
  }
}