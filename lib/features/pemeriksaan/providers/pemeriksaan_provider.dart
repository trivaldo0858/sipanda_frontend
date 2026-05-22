// lib/features/pemeriksaan/providers/pemeriksaan_provider.dart

import 'package:flutter/material.dart';
import '../models/pemeriksaan_model.dart';
import '../services/pemeriksaan_service.dart';

enum PemeriksaanStatus { initial, loading, loaded, saving, error }

class PemeriksaanProvider extends ChangeNotifier {
  final PemeriksaanService _service = PemeriksaanService();

  PemeriksaanStatus        _status       = PemeriksaanStatus.initial;
  List<PemeriksaanModel>   _list         = [];
  String?                  _errorMessage;
  String?                  _successMessage;

  PemeriksaanStatus      get status         => _status;
  List<PemeriksaanModel> get list           => _list;
  String?                get errorMessage   => _errorMessage;
  String?                get successMessage => _successMessage;
  bool get isLoading => _status == PemeriksaanStatus.loading;
  bool get isSaving  => _status == PemeriksaanStatus.saving;

  Future<void> loadList({String? nikAnak}) async {
    _status = PemeriksaanStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _list   = await _service.getList(nikAnak: nikAnak);
      _status = PemeriksaanStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = PemeriksaanStatus.error;
    }
    notifyListeners();
  }

  Future<bool> catat({
    required String nikAnak,
    required String tglPeriksa,
    required double beratBadan,
    required double tinggiBadan,
    required double lingkarKepala,
    String? keluhan,
    int? idJadwal,
  }) async {
    _status         = PemeriksaanStatus.saving;
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
    try {
      final p = await _service.catat(
        nikAnak:       nikAnak,
        tglPeriksa:    tglPeriksa,
        beratBadan:    beratBadan,
        tinggiBadan:   tinggiBadan,
        lingkarKepala: lingkarKepala,
        keluhan:       keluhan,
        idJadwal:      idJadwal,
      );
      _list.insert(0, p);
      _successMessage = 'Pemeriksaan berhasil dicatat.';
      _status         = PemeriksaanStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = PemeriksaanStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> hapus(int idPeriksa) async {
    try {
      await _service.hapus(idPeriksa);
      _list.removeWhere((p) => p.idPeriksa == idPeriksa);
      _successMessage = 'Data pemeriksaan berhasil dihapus.';
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