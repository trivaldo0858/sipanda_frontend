// lib/features/auth/data/repositories/auth_repository_impl.dart
//
// DATA LAYER — Repository Implementation
// ✅ Implementasi nyata dari kontrak AuthRepository (Domain Layer)
// ✅ Menggabungkan Remote DataSource + Local DataSource
// ✅ Domain Layer tidak tahu detail implementasi ini

import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource  localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ── Login Kader/Bidan ───────────────────────────────────────────
  @override
  Future<AuthEntity> login({
    required String username,
    required String password,
  }) async {
    final model = await remoteDataSource.login(
      username: username,
      password: password,
    );
    // Simpan session ke lokal
    await _simpanSession(model);
    return model;
  }

  // ── Login Orang Tua ─────────────────────────────────────────────
  @override
  Future<AuthEntity> loginOrangTua({
    required String nikBalita,
    required String tglLahir,
  }) async {
    final model = await remoteDataSource.loginOrangTua(
      nikBalita: nikBalita,
      tglLahir:  tglLahir,
    );
    await _simpanSession(model);

    // Simpan data anak login khusus OrangTua
    // Data anak_login datang dari response API
    // (sudah di-handle di AuthModel.fromJson via field tambahan)
    return model;
  }

  // ── Login Google ────────────────────────────────────────────────
  @override
  Future<AuthEntity> loginGoogle({
    required String googleId,
    required String emailGoogle,
    required int idUser,
  }) async {
    final model = await remoteDataSource.loginGoogle(
      googleId:    googleId,
      emailGoogle: emailGoogle,
      idUser:      idUser,
    );
    await _simpanSession(model);
    return model;
  }

  // ── Logout ──────────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Tetap hapus session lokal meski request gagal
    } finally {
      await localDataSource.hapusSession();
    }
  }

  // ── Ubah Password ───────────────────────────────────────────────
  @override
  Future<void> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) {
    return remoteDataSource.ubahPassword(
      passwordLama:             passwordLama,
      passwordBaru:             passwordBaru,
      passwordBaruConfirmation: passwordBaruConfirmation,
    );
  }

  // ── Cek status login ────────────────────────────────────────────
  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    return token != null;
  }

  // ── Ambil pengguna lokal ────────────────────────────────────────
  @override
  Future<PenggunaEntity?> getPenggunaLokal() {
    return localDataSource.getPengguna();
  }

  // ── Ambil anak login lokal ──────────────────────────────────────
  @override
  Future<AnakLoginEntity?> getAnakLogin() {
    return localDataSource.getAnakLogin();
  }

  // ── Helper simpan session ───────────────────────────────────────
  Future<void> _simpanSession(AuthModel model) async {
    await localDataSource.simpanToken(model.token);
    await localDataSource.simpanPengguna(
      model.pengguna as PenggunaModel,
    );
  }
}