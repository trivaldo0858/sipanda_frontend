// lib/features/auth/data/datasources/auth_remote_datasource.dart
//
// DATA LAYER — Remote Data Source
// ✅ Satu-satunya tempat yang boleh panggil API
// ✅ Hanya urusan HTTP request & parsing JSON → Model
// ✅ Lempar Exception kalau ada error

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String username,
    required String password,
  });

  Future<AuthModel> loginOrangTua({
    required String nikBalita,
    required String tglLahir,
  });

  Future<AuthModel> loginGoogle({
    required String googleId,
    required String emailGoogle,
    required int idUser,
  });

  Future<void> logout();

  Future<void> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  });
}

// ── Implementasi ──────────────────────────────────────────────────────
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  const AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await dio.post(ApiConstants.login, data: {
        'username': username,
        'password': password,
      });
      return AuthModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<AuthModel> loginOrangTua({
    required String nikBalita,
    required String tglLahir,
  }) async {
    try {
      final res = await dio.post(ApiConstants.loginOrangTua, data: {
        'nik_balita': nikBalita,
        'tgl_lahir':  tglLahir,
      });
      return AuthModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<AuthModel> loginGoogle({
    required String googleId,
    required String emailGoogle,
    required int idUser,
  }) async {
    try {
      final res = await dio.post(ApiConstants.loginGoogle, data: {
        'google_id':    googleId,
        'email_google': emailGoogle,
        'id_user':      idUser,
      });
      return AuthModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> ubahPassword({
    required String passwordLama,
    required String passwordBaru,
    required String passwordBaruConfirmation,
  }) async {
    try {
      await dio.post(ApiConstants.ubahPassword, data: {
        'password_lama':              passwordLama,
        'password_baru':              passwordBaru,
        'password_baru_confirmation': passwordBaruConfirmation,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}