// lib/features/dashboard/providers/dashboard_provider.dart

import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  DashboardStatus _status = DashboardStatus.initial;
  String?         _errorMessage;

  DashboardKader? _kaderData;
  DashboardBidan? _bidanData;
  DashboardOrtu?  _ortuData;

  DashboardStatus get status       => _status;
  String?         get errorMessage => _errorMessage;
  DashboardKader? get kaderData    => _kaderData;
  DashboardBidan? get bidanData    => _bidanData;
  DashboardOrtu?  get ortuData     => _ortuData;
  bool get isLoading               => _status == DashboardStatus.loading;

  Future<void> loadKader() async {
    _status = DashboardStatus.loading;
    notifyListeners();
    try {
      _kaderData = await _service.getDashboardKader();
      _status    = DashboardStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = DashboardStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadBidan() async {
    _status = DashboardStatus.loading;
    notifyListeners();
    try {
      _bidanData = await _service.getDashboardBidan();
      _status    = DashboardStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = DashboardStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadOrtu() async {
    _status = DashboardStatus.loading;
    notifyListeners();
    try {
      _ortuData = await _service.getDashboardOrtu();
      // Debug
      if (_ortuData != null && _ortuData!.daftarAnak.isNotEmpty) {
        final anak = _ortuData!.daftarAnak.first;
        debugPrint('DEBUG nama_anak: ${anak.namaAnak}');
        debugPrint('DEBUG berat_terakhir: ${anak.beratTerakhir}');
        debugPrint('DEBUG tinggi_terakhir: ${anak.tinggiTerakhir}');
      } else {
        debugPrint('DEBUG daftar_anak kosong');
      }
      _status = DashboardStatus.loaded;
    } catch (e) {
      debugPrint('DEBUG error loadOrtu: $e');
      _errorMessage = e.toString();
      _status       = DashboardStatus.error;
    }
    notifyListeners();
  }

  void refresh(String role) {
    switch (role) {
      case 'Kader':    loadKader(); break;
      case 'Bidan':    loadBidan(); break;
      case 'OrangTua': loadOrtu();  break;
    }
  }
}