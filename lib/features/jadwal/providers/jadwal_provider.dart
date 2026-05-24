// lib/features/jadwal/providers/jadwal_provider.dart

import 'package:flutter/material.dart';
import '../models/jadwal_model.dart';
import '../services/jadwal_service.dart';

enum JadwalStatus { initial, loading, loaded, saving, error }

class JadwalProvider extends ChangeNotifier {
  final JadwalService _service = JadwalService();

  JadwalStatus      _status       = JadwalStatus.initial;
  List<JadwalModel> _list         = [];
  String?           _errorMessage;
  String?           _successMessage;

  JadwalStatus      get status         => _status;
  List<JadwalModel> get list           => _list;
  String?           get errorMessage   => _errorMessage;
  String?           get successMessage => _successMessage;
  bool get isLoading => _status == JadwalStatus.loading;
  bool get isSaving  => _status == JadwalStatus.saving;

  // Filter
  List<JadwalModel> get upcoming =>
      _list.where((j) => j.isUpcoming).toList();
  List<JadwalModel> get past =>
      _list.where((j) => j.isPast).toList();

  Future<void> loadList({String? filter}) async {
    _status = JadwalStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _list   = await _service.getList(filter: filter);
      _status = JadwalStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = JadwalStatus.error;
    }
    notifyListeners();
  }

  Future<bool> buat({
    required String tglKegiatan,
    required String lokasi,
    String? agenda,
  }) async {
    _status         = JadwalStatus.saving;
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
    try {
      final jadwal = await _service.buat(
        tglKegiatan: tglKegiatan,
        lokasi:      lokasi,
        agenda:      agenda,
      );
      _list.insert(0, jadwal);
      _successMessage = 'Jadwal berhasil dibuat & notifikasi dikirim ke Orang Tua.';
      _status         = JadwalStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = JadwalStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> update({
    required int idJadwal,
    required String tglKegiatan,
    required String lokasi,
    String? agenda,
  }) async {
    _status         = JadwalStatus.saving;
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
    try {
      final updated = await _service.update(
        idJadwal:    idJadwal,
        tglKegiatan: tglKegiatan,
        lokasi:      lokasi,
        agenda:      agenda,
      );
      final idx = _list.indexWhere((j) => j.idJadwal == idJadwal);
      if (idx != -1) _list[idx] = updated;
      _successMessage = 'Jadwal berhasil diperbarui.';
      _status         = JadwalStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = JadwalStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> hapus(int idJadwal) async {
    try {
      await _service.hapus(idJadwal);
      _list.removeWhere((j) => j.idJadwal == idJadwal);
      _successMessage = 'Jadwal berhasil dihapus.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
  }
}