// lib/features/auth/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthStatus _status = AuthStatus.initial;
  AuthUser?  _user;
  String?    _errorMessage;

  // ── Getters ───────────────────────────────────────────
  AuthStatus get status       => _status;
  AuthUser?  get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool get isLoading          => _status == AuthStatus.loading;
  bool get isAuthenticated    => _status == AuthStatus.authenticated;

  // ── Daftar Posyandu untuk dropdown ────────────────────
  List<PosyanduItem> _posyanduList = [];
  bool _posyanduLoading = false;

  List<PosyanduItem> get posyanduList    => _posyanduList;
  bool               get posyanduLoading => _posyanduLoading;

  // ── Cek session saat app start ────────────────────────
  Future<void> checkSession() async {
    final loggedIn = await _service.isLoggedIn();
    if (loggedIn) {
      final role = await _service.getSavedRole();
      _user = AuthUser(
        idUser: 0,
        role: role ?? 'Kader',
      );
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Load daftar posyandu (dropdown Kader) ─────────────
  Future<void> loadPosyanduList() async {
    if (_posyanduList.isNotEmpty) return; // sudah ada, skip
    _posyanduLoading = true;
    notifyListeners();

    try {
      _posyanduList = await _service.getPosyanduList();
    } catch (_) {
      _posyanduList = [];
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
      _user   = await _service.loginKader(
        idPosyandu: idPosyandu,
        passwordKader: passwordKader,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
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
      _user   = await _service.loginBidan(
        username: username,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
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
      _user   = await _service.loginOrangTua(
        nikAnak: nikAnak,
        tglLahir: tglLahir,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────
  Future<void> logout() async {
    await _service.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    _posyanduList = [];
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────
  void _setLoading() {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status       = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}