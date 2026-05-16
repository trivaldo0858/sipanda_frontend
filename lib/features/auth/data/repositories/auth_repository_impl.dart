import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.login(
        username: username,
        password: password,
      );
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthEntity> loginOrangTua({
    required String nik,
    required String tglLahir,
    required String
    nikBalita, // MEMPERBAIKI ERROR: Tambahkan ini agar tidak melanggar kontrak interface
  }) async {
    try {
      // Kita tetap hanya mengirim 'nik' dan 'tglLahir' ke remote datasource sesuai API Laravel kamu
      final model = await remoteDataSource.loginOrangTua(
        nik: nik,
        tanggalLahir: tglLahir,
      );
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthEntity> loginGoogle({
    required String googleId,
    required String emailGoogle,
    required int idUser,
  }) async {
    try {
      final model = await remoteDataSource.loginGoogle(token: googleId);
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {
    try {
      await remoteDataSource.ubahPassword(
        passwordLama: passwordLama,
        passwordBaru: passwordBaru,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AnakLoginEntity?> getAnakLogin() async {
    return null;
  }

  @override
  Future<PenggunaEntity?> getPenggunaLokal() async {
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return false;
  }
}
