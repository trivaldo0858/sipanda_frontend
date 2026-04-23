// lib/providers/validasi_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/services/validasi_service.dart';

class ValidasiProvider extends ChangeNotifier {
  final ValidasiService _service = ValidasiService();

  Map<String, dynamic>? _data;
  bool _isLoading       = false;
  String? _errorMessage;

  Map<String, dynamic>? get data    => _data;
  bool get isLoading                => _isLoading;
  String? get errorMessage          => _errorMessage;

  List get pemeriksaanMenunggu =>
      (_data?['pemeriksaan'] as List?) ?? [];

  List get imunisasiMenunggu =>
      (_data?['imunisasi'] as List?) ?? [];

  int get totalMenunggu =>
      (_data?['total'] as int?) ?? 0;

  Future<void> fetchMenungguValidasi() async {
    _setLoading(true);
    final result = await _service.getMenungguValidasi();
    if (result.isSuccess) {
      _data = result.data;
    } else {
      _errorMessage = result.error;
    }
    _setLoading(false);
  }

  Future<bool> setujuiPemeriksaan(int id, {String? catatan}) async {
    return _validasi(() => _service.validasiPemeriksaan(
      id:             id,
      statusValidasi: 'Disetujui',
      catatanValidasi: catatan,
    ));
  }

  Future<bool> tolakPemeriksaan(int id, {required String catatan}) async {
    return _validasi(() => _service.validasiPemeriksaan(
      id:              id,
      statusValidasi:  'Ditolak',
      catatanValidasi: catatan,
    ));
  }

  Future<bool> setujuiImunisasi(int id, {String? catatan}) async {
    return _validasi(() => _service.validasiImunisasi(
      id:             id,
      statusValidasi: 'Disetujui',
      catatanValidasi: catatan,
    ));
  }

  Future<bool> tolakImunisasi(int id, {required String catatan}) async {
    return _validasi(() => _service.validasiImunisasi(
      id:              id,
      statusValidasi:  'Ditolak',
      catatanValidasi: catatan,
    ));
  }

  Future<bool> _validasi(Future<dynamic> Function() action) async {
    _setLoading(true);
    try {
      final result = await action();
      if (result.isSuccess == true) {
        await fetchMenungguValidasi(); // refresh list
        _setLoading(false);
        return true;
      }
      _errorMessage = result.error?.toString();
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}