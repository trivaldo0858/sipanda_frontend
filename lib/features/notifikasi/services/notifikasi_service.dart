// lib/features/notifikasi/services/notifikasi_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/notifikasi_model.dart';

class NotifikasiService {
  final Dio _dio = ApiClient.instance.dio;

  // ── GET LIST NOTIFIKASI ───────────────────────────────
  Future<List<NotifikasiModel>> getList() async {
    try {
      final res = await _dio.get(ApiConstants.notifikasi);
      final List data = res.data['data']['data'] as List? ??
          res.data['data'] as List? ?? [];
      return data.map((e) => NotifikasiModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── GET UNREAD COUNT ──────────────────────────────────
  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get(ApiConstants.notifUnreadCount);
      return res.data['data']['unread_count'] as int? ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── MARK READ ─────────────────────────────────────────
  Future<void> markRead(int idNotifikasi) async {
    try {
      await _dio.post(ApiConstants.notifRead(idNotifikasi));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── MARK ALL READ ─────────────────────────────────────
  Future<void> markAllRead() async {
    try {
      await _dio.post(ApiConstants.notifMarkAllRead);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── DELETE ────────────────────────────────────────────
  Future<void> delete(int idNotifikasi) async {
    try {
      await _dio.delete(ApiConstants.notifDelete(idNotifikasi));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}