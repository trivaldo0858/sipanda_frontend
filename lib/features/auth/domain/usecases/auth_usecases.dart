// lib/features/auth/domain/usecases/auth_usecases.dart
//
// DOMAIN LAYER — Use Cases
// ✅ Setiap use case = satu aksi bisnis yang spesifik
// ✅ Hanya memanggil repository, tidak tahu soal API atau UI
// ✅ Mudah di-test secara terpisah

import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

// ── Use Case 1: Login Kader/Bidan ─────────────────────────────────────
class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<AuthEntity> call({
    required String username,
    required String password,
  }) {
    return repository.login(
      username: username,
      password: password,
    );
  }
}

// ── Use Case 2: Login Orang Tua ───────────────────────────────────────
class LoginOrangTuaUseCase {
  final AuthRepository repository;
  const LoginOrangTuaUseCase(this.repository);

  Future<AuthEntity> call({
    required String nikBalita,
    required String tglLahir,
  }) {
    return repository.loginOrangTua(
      nikBalita: nikBalita,
      tglLahir:  tglLahir,
    );
  }
}

// ── Use Case 3: Login Google ──────────────────────────────────────────
class LoginGoogleUseCase {
  final AuthRepository repository;
  const LoginGoogleUseCase(this.repository);

  Future<AuthEntity> call({
    required String googleId,
    required String emailGoogle,
    required int idUser,
  }) {
    return repository.loginGoogle(
      googleId:    googleId,
      emailGoogle: emailGoogle,
      idUser:      idUser,
    );
  }
}

// ── Use Case 4: Logout ────────────────────────────────────────────────
class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<void> call() => repository.logout();
}

// ── Use Case 5: Cek Status Login ─────────────────────────────────────
class CheckLoginUseCase {
  final AuthRepository repository;
  const CheckLoginUseCase(this.repository);

  Future<bool> call() => repository.isLoggedIn();
}

// ── Use Case 6: Ambil Data Pengguna Lokal ─────────────────────────────
class GetPenggunaLokalUseCase {
  final AuthRepository repository;
  const GetPenggunaLokalUseCase(this.repository);

  Future<PenggunaEntity?> call() => repository.getPenggunaLokal();
}

// ── Use Case 7: Ambil Data Anak Login ────────────────────────────────
class GetAnakLoginUseCase {
  final AuthRepository repository;
  const GetAnakLoginUseCase(this.repository);

  Future<AnakLoginEntity?> call() => repository.getAnakLogin();
}

// ── Use Case 8: Ubah Password ─────────────────────────────────────────
class UbahPasswordUseCase {
  final AuthRepository repository;
  const UbahPasswordUseCase(this.repository);

  Future<void> call({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) {
    return repository.ubahPassword(
      passwordLama:             passwordLama,
      passwordBaru:             passwordBaru,
      passwordBaruConfirmation: passwordBaruConfirmation,
    );
  }
}