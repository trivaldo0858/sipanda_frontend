// lib/features/auth/providers/auth_provider.dart
//
// PERBAIKAN:
// - Implements ChangeNotifier (sudah) — bisa dipakai sebagai refreshListenable di GoRouter
// - checkSession() hanya dipanggil SATU KALI dari SplashScreen
// - Error message lebih informatif (ApiException sudah di-parse)
// - Tambah clearPosyanduCache() saat logout

import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final dynamic _service = AuthService();

  AuthStatus _status = AuthStatus.initial;
  AuthUser? _user;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────
  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Daftar Posyandu untuk dropdown ────────────────────
  List<PosyanduItem> _posyanduList = [];
  bool _posyanduLoading = false;

  List<PosyanduItem> get posyanduList => _posyanduList;
  bool get posyanduLoading => _posyanduLoading;

  Future<void> checkSession() async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      // Pengecekan aman
      _user = await _service.checkSession();
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      // AMANKAN DI SINI: Jika ada NoSuchMethodError lagi, paksa aplikasi lepas dari status loading
      debugPrint('[AuthProvider] Terjadi kesalahan checkSession: $e');
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = e.toString();
    } finally {
      notifyListeners(); // MENJAMIN SCREEN LOADING LEPAS DAN MASUK KE LOGIN FORM
    }
  }

  // ── Load daftar posyandu (dropdown Kader) ─────────────
  Future<void> loadPosyanduList() async {
    if (_posyanduList.isNotEmpty) return; // sudah ada, skip
    _posyanduLoading = true;
    notifyListeners();

    try {
      _posyanduList = await _service.getPosyanduList();
    } catch (e) {
      _posyanduList = [];
      debugPrint('[AuthProvider] loadPosyanduList error: $e');
    } finally {
      _posyanduLoading = false;
      notifyListeners();
    }
  }

  // ── Login Kader ───────────────────────────────────────
  Future<bool> loginKader({
    required int idPosyandu,
    required String passwordKader,
  }) async {
    _setLoading();
    try {
      _user = await _service.loginKader(
        idPosyandu: idPosyandu,
        passwordKader: passwordKader,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ── Login Bidan ───────────────────────────────────────
  Future<bool> loginBidan({
    required String username,
    required String password,
  }) async {
    _setLoading();
    try {
      _user = await _service.loginBidan(username: username, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ── Login Orang Tua ───────────────────────────────────
  Future<bool> loginOrangTua({
    required String nikAnak,
    required String tglLahir,
  }) async {
    _setLoading();
    try {
      _user = await _service.loginOrangTua(
        nikAnak: nikAnak,
        tglLahir: tglLahir,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────
  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _posyanduList = []; // clear cache posyandu
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Ubah error exception menjadi pesan yang user-friendly
  String _friendlyError(Object e) {
    final msg = e.toString();
    // Hapus prefix "Exception: " jika ada
    if (msg.startsWith('Exception: ')) {
      return msg.substring('Exception: '.length);
    }
    return msg;
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
