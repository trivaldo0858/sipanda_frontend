// lib/providers/pemeriksaan_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/models/pemeriksaan_model.dart';
import '../../../../data/services/pemeriksaan_service.dart';

class PemeriksaanProvider extends ChangeNotifier {
  final PemeriksaanService _service = PemeriksaanService();

  List<PemeriksaanModel> _list = [];
  PemeriksaanModel? _selected;
  bool _isLoading      = false;
  String? _errorMessage;
  int _currentPage     = 1;
  int _lastPage        = 1;

  // ── Getters ───────────────────────────────────────────────────────
  List<PemeriksaanModel> get list => _list;
  PemeriksaanModel? get selected  => _selected;
  bool get isLoading              => _isLoading;
  String? get errorMessage        => _errorMessage;
  bool get hasMore                => _currentPage < _lastPage;

  // ── Fetch list ────────────────────────────────────────────────────
  Future<void> fetchAll({
    String? nikAnak,
    int? idJadwal,
    String? tglDari,
    String? tglSampai,
  }) async {
    _setLoading(true);
    _currentPage = 1;

    final result = await _service.getAll(
      nikAnak:   nikAnak,
      idJadwal:  idJadwal,
      tglDari:   tglDari,
      tglSampai: tglSampai,
      page:      1,
    );

    if (result.isSuccess) {
      _list        = result.data!.data;
      _currentPage = result.data!.currentPage;
      _lastPage    = result.data!.lastPage;
    } else {
      _errorMessage = result.error;
    }

    _setLoading(false);
  }

  // ── Load more ─────────────────────────────────────────────────────
  Future<void> loadMore({String? nikAnak}) async {
    if (!hasMore || _isLoading) return;
    _setLoading(true);

    final result = await _service.getAll(
      nikAnak: nikAnak,
      page:    _currentPage + 1,
    );

    if (result.isSuccess) {
      _list.addAll(result.data!.data);
      _currentPage = result.data!.currentPage;
      _lastPage    = result.data!.lastPage;
    }

    _setLoading(false);
  }

  // ── Detail ────────────────────────────────────────────────────────
  Future<void> fetchDetail(int id) async {
    _setLoading(true);
    final result = await _service.getById(id);
    if (result.isSuccess) {
      _selected = result.data;
    } else {
      _errorMessage = result.error;
    }
    _setLoading(false);
  }

  // ── Catat pemeriksaan baru ────────────────────────────────────────
  Future<bool> create(PemeriksaanModel p) async {
    _setLoading(true);
    final result = await _service.create(p);

    if (result.isSuccess) {
      _list.insert(0, result.data!);
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  // ── Update ────────────────────────────────────────────────────────
  Future<bool> update(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    final result = await _service.update(id, data);

    if (result.isSuccess) {
      final idx = _list.indexWhere((p) => p.idPemeriksaan == id);
      if (idx != -1) _list[idx] = result.data!;
      if (_selected?.idPemeriksaan == id) _selected = result.data;
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  // ── Hapus ─────────────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    _setLoading(true);
    final result = await _service.delete(id);

    if (result.isSuccess) {
      _list.removeWhere((p) => p.idPemeriksaan == id);
      if (_selected?.idPemeriksaan == id) _selected = null;
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
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