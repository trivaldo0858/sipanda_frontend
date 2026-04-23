// lib/features/auth/domain/repositories/auth_repository.dart
//
// DOMAIN LAYER — Repository Interface (Kontrak)
// ✅ Hanya mendefinisikan "apa yang bisa dilakukan"
// ✅ Tidak tahu bagaimana cara melakukannya (itu urusan Data Layer)
// ✅ Menggunakan Either<Failure, Success> untuk handle error

import '../entities/auth_entity.dart';

/// Kontrak repository auth.
/// Data Layer WAJIB mengimplementasikan semua method ini.
abstract class AuthRepository {
  /// Login untuk Kader dan Bidan menggunakan username & password
  Future<AuthEntity> login({
    required String username,
    required String password,
  });

  /// Login untuk Orang Tua menggunakan NIK Balita + Tanggal Lahir
  Future<AuthEntity> loginOrangTua({
    required String nikBalita,
    required String tglLahir,
  });

  /// Login menggunakan akun Google
  Future<AuthEntity> loginGoogle({
    required String googleId,
    required String emailGoogle,
    required int idUser,
  });

  /// Logout dan hapus session
  Future<void> logout();

  /// Ambil data pengguna yang sedang login
  Future<PenggunaEntity?> getPenggunaLokal();

  /// Ambil data anak yang dipakai login (khusus OrangTua)
  Future<AnakLoginEntity?> getAnakLogin();

  /// Cek apakah pengguna sudah login
  Future<bool> isLoggedIn();

  /// Ubah password
  Future<void> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  });
}