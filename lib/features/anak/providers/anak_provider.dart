// lib/features/anak/providers/anak_provider.dart

import 'package:flutter/material.dart';
import '../models/anak_model.dart';
import '../services/anak_service.dart';

enum AnakStatus { initial, loading, loaded, saving, error }

class AnakProvider extends ChangeNotifier {
  final AnakService _service = AnakService();

  AnakStatus      _status         = AnakStatus.initial;
  List<AnakModel> _anakList       = [];
  AnakModel?      _selectedAnak;
  String?         _errorMessage;
  String?         _successMessage;

  AnakStatus      get status         => _status;
  List<AnakModel> get anakList       => _anakList;
  AnakModel?      get selectedAnak   => _selectedAnak;
  String?         get errorMessage   => _errorMessage;
  String?         get successMessage => _successMessage;
  bool get isLoading => _status == AnakStatus.loading;
  bool get isSaving  => _status == AnakStatus.saving;

  Future<void> loadAnakList({String? search}) async {
    _status = AnakStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _anakList = await _service.getAnakList(search: search);
      _status   = AnakStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = AnakStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadAnakDetail(String nikAnak) async {
    _status = AnakStatus.loading;
    notifyListeners();
    try {
      _selectedAnak = await _service.getAnakDetail(nikAnak);
      _status       = AnakStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = AnakStatus.error;
    }
    notifyListeners();
  }

  Future<bool> tambahAnak({
    required String nikAnak,
    required String nikOrangTua,
    required String namaAnak,
    required String namaIbu,
    required String tglLahir,
    required String jenisKelamin,
    required String namaAyah,
    String? noTelpIbu,
    String? alamat,
  }) async {
    _status         = AnakStatus.saving;
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
    try {
      final anak = await _service.tambahAnak(
        nikAnak:      nikAnak,
        nikOrangTua:  nikOrangTua,
        namaAnak:     namaAnak,
        namaIbu:      namaIbu,
        tglLahir:     tglLahir,
        jenisKelamin: jenisKelamin,
        namaAyah:     namaAyah,
        noTelpIbu:    noTelpIbu,
        alamat:       alamat,
      );
      _anakList.insert(0, anak);
      _successMessage = 'Data balita berhasil ditambahkan. Akun Orang Tua otomatis dibuat.';
      _status         = AnakStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = AnakStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAnak({
    required String nikAnak,
    required String namaAnak,
    required String namaIbu,
    required String tglLahir,
    required String jenisKelamin,
    required String namaAyah,
    required String nikOrangTua,
  }) async {
    _status         = AnakStatus.saving;
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
    try {
      final updated = await _service.updateAnak(
        nikAnak:      nikAnak,
        namaAnak:     namaAnak,
        namaIbu:      namaIbu,
        tglLahir:     tglLahir,
        jenisKelamin: jenisKelamin,
        namaAyah:     namaAyah,
        nikOrangTua:  nikOrangTua,
      );
      final idx = _anakList.indexWhere((a) => a.nikAnak == nikAnak);
      if (idx != -1) _anakList[idx] = updated;
      _selectedAnak   = updated;
      _successMessage = 'Data balita berhasil diperbarui.';
      _status         = AnakStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = AnakStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> hapusAnak(String nikAnak) async {
    _errorMessage   = null;
    _successMessage = null;
    try {
      await _service.hapusAnak(nikAnak);
      _anakList.removeWhere((a) => a.nikAnak == nikAnak);
      _successMessage = 'Data balita berhasil dihapus.';
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