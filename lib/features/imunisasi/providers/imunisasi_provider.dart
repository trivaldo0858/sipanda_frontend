// lib/features/imunisasi/providers/imunisasi_provider.dart

import 'package:flutter/material.dart';
import '../models/imunisasi_model.dart';
import '../services/imunisasi_service.dart';

enum ImunisasiStatus { initial, loading, loaded, saving, error }

class ImunisasiProvider extends ChangeNotifier {
  final ImunisasiService _service = ImunisasiService();

  ImunisasiStatus        _status       = ImunisasiStatus.initial;
  List<ImunisasiModel>   _list         = [];
  List<JenisVaksinModel> _jenisVaksin  = [];
  String?                _errorMessage;
  String?                _successMessage;

  ImunisasiStatus        get status         => _status;
  List<ImunisasiModel>   get list           => _list;
  List<JenisVaksinModel> get jenisVaksin    => _jenisVaksin;
  String?                get errorMessage   => _errorMessage;
  String?                get successMessage => _successMessage;
  bool get isLoading => _status == ImunisasiStatus.loading;
  bool get isSaving  => _status == ImunisasiStatus.saving;

  // ── Load jenis vaksin ──────────────────────────────────
  Future<void> loadJenisVaksin() async {
    if (_jenisVaksin.isNotEmpty) return;
    try {
      _jenisVaksin = await _service.getJenisVaksin();
      notifyListeners();
    } catch (e) {
      debugPrint('Error load jenis vaksin: $e');
    }
  }

  // ── Load list imunisasi ────────────────────────────────
  Future<void> loadList() async {
    _status = ImunisasiStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _list   = await _service.getList();
      _status = ImunisasiStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = ImunisasiStatus.error;
    }
    notifyListeners();
  }

  // ── Load riwayat per anak ──────────────────────────────
  Future<void> loadRiwayat(String nikAnak) async {
    _status = ImunisasiStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _list   = await _service.getRiwayat(nikAnak);
      _status = ImunisasiStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = ImunisasiStatus.error;
    }
    notifyListeners();
  }

  // ── Catat imunisasi ────────────────────────────────────
  Future<bool> catat({
    required String nikAnak,
    required int idVaksin,
    required String tglPemberian,
    String? catatan,
  }) async {
    _status         = ImunisasiStatus.saving;
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
    try {
      final imunisasi = await _service.catat(
        nikAnak:      nikAnak,
        idVaksin:     idVaksin,
        tglPemberian: tglPemberian,
        catatan:      catatan,
      );
      _list.insert(0, imunisasi);
      _successMessage = 'Imunisasi berhasil dicatat.';
      _status         = ImunisasiStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = ImunisasiStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Hapus ──────────────────────────────────────────────
  Future<bool> hapus(int idImunisasi) async {
    try {
      await _service.hapus(idImunisasi);
      _list.removeWhere((i) => i.idImunisasi == idImunisasi);
      _successMessage = 'Data imunisasi berhasil dihapus.';
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