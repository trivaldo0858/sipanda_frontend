// lib/providers/dashboard_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  Map<String, dynamic>? _data;
  bool _isLoading       = false;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────
  Map<String, dynamic>? get data => _data;
  bool get isLoading             => _isLoading;
  String? get errorMessage       => _errorMessage;

  // Helper getter per role
  int get totalAnak =>
      (_data?['total_anak'] as int?) ?? 0;

  int get totalPemeriksaanBulan =>
      (_data?['total_pemeriksaan_bulan'] as int?) ?? 0;

  int get totalImunisasiBulan =>
      (_data?['total_imunisasi_bulan'] as int?) ?? 0;

  int get totalPengguna =>
      (_data?['total_pengguna'] as int?) ?? 0;

  int get notifBelumBaca =>
      (_data?['notif_belum_baca'] as int?) ?? 0;

  List get jadwalMendatang =>
      (_data?['jadwal_mendatang'] as List?) ?? [];

  List get pemeriksaanTerbaru =>
      (_data?['pemeriksaan_terbaru'] as List?) ?? [];

  List get anakList =>
      (_data?['anak'] as List?) ?? [];

  // ── Fetch dashboard ───────────────────────────────────────────────
  Future<void> fetch() async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.getDashboard();

    if (result.isSuccess) {
      _data = result.data;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}