// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase           _loginUseCase;
  final LoginOrangTuaUseCase   _loginOrangTuaUseCase;
  final LoginGoogleUseCase     _loginGoogleUseCase;
  final LogoutUseCase          _logoutUseCase;
  final CheckLoginUseCase      _checkLoginUseCase;
  final GetPenggunaLokalUseCase _getPenggunaLokalUseCase;
  final GetAnakLoginUseCase    _getAnakLoginUseCase;
  final UbahPasswordUseCase    _ubahPasswordUseCase;

  AuthProvider(
    this._loginUseCase,
    this._loginOrangTuaUseCase,
    this._loginGoogleUseCase,
    this._logoutUseCase,
    this._checkLoginUseCase,
    this._getPenggunaLokalUseCase,
    this._getAnakLoginUseCase,
    this._ubahPasswordUseCase,
  );

  // ── State ─────────────────────────────────────────────────────────
  AuthStatus _status           = AuthStatus.unknown;
  PenggunaEntity? _pengguna;
  AnakLoginEntity? _anakLogin;
  bool _isLoading              = false;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────
  AuthStatus get status            => _status;
  PenggunaEntity? get pengguna     => _pengguna;
  AnakLoginEntity? get anakLogin   => _anakLogin;
  bool get isLoading               => _isLoading;
  String? get errorMessage         => _errorMessage;
  bool get isAuthenticated         => _status == AuthStatus.authenticated;
  bool get isSuperAdmin            => _pengguna?.isSuperAdmin ?? false;
  bool get isBidan                 => _pengguna?.isBidan ?? false;
  bool get isKader                 => _pengguna?.isKader ?? false;
  bool get isOrangTua              => _pengguna?.isOrangTua ?? false;

  // ── Cek session ───────────────────────────────────────────────────
  Future<void> checkSession() async {
    final loggedIn = await _checkLoginUseCase();
    if (loggedIn) {
      _pengguna  = await _getPenggunaLokalUseCase();
      _anakLogin = await _getAnakLoginUseCase();
      _status    = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login Kader/Bidan ─────────────────────────────────────────────
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final result = await _loginUseCase(
        username: username,
        password: password,
      );
      _pengguna = result.pengguna;
      _status   = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // ── Login Orang Tua ───────────────────────────────────────────────
  Future<bool> loginOrangTua({
    required String nikBalita,
    required String tglLahir,
  }) async {
    _setLoading(true);
    try {
      final result = await _loginOrangTuaUseCase(
        nikBalita: nikBalita,
        tglLahir:  tglLahir,
      );
      _pengguna  = result.pengguna;
      _anakLogin = await _getAnakLoginUseCase();
      _status    = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // ── Login Google ──────────────────────────────────────────────────
  Future<bool> loginGoogle({
    required String googleId,
    required String emailGoogle,
    required int idUser,
  }) async {
    _setLoading(true);
    try {
      final result = await _loginGoogleUseCase(
        googleId:    googleId,
        emailGoogle: emailGoogle,
        idUser:      idUser,
      );
      _pengguna = result.pengguna;
      _status   = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────
  Future<void> logout() async {
    _setLoading(true);
    await _logoutUseCase();
    _pengguna  = null;
    _anakLogin = null;
    _status    = AuthStatus.unauthenticated;
    _setLoading(false);
  }

  // ── Ubah Password ─────────────────────────────────────────────────
  Future<bool> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {
    _setLoading(true);
    try {
      await _ubahPasswordUseCase(
        passwordLama:             passwordLama,
        passwordBaru:             passwordBaru,
        passwordBaruConfirmation: passwordBaruConfirmation,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}