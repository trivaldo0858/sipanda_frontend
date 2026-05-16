import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String username,
    required String password,
  });

  Future<AuthModel> loginOrangTua({
    required String nik,
    required String tanggalLahir,
  });

  Future<AuthModel> loginGoogle({required String token});

  Future<void> logout();

  Future<void> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );
      return AuthModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthModel> loginOrangTua({
    required String nik,
    required String tanggalLahir,
  }) async {
    try {
      // Mengirimkan parameter nik dan tanggal_lahir ke API Auth backend Laravel
      final response = await dio.post(
        '/login-ortu', // Sesuaikan dengan endpoint API Login Orang Tua di Laravel kamu
        data: {
          'nik': nik,
          'password': tanggalLahir, // Di backend biasanya password default ortu adalah tgl_lahir
        },
      );
      return AuthModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthModel> loginGoogle({required String token}) async {
    try {
      final response = await dio.post('/auth/google', data: {'token': token});
      return AuthModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/logout');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    try {
      await dio.post(
        '/ubah-password',
        data: {
          'password_lama': passwordLama,
          'password_baru': passwordBaru,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}