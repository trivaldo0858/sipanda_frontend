// lib/providers/imunisasi_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/models/imunisasi_model.dart';
import '../../../../data/services/imunisasi_service.dart';

class ImunisasiProvider extends ChangeNotifier {
  final ImunisasiService _service      = ImunisasiService();
  final JenisVaksinService _vaksinService = JenisVaksinService();

  List<ImunisasiModel> _list       = [];
  List<JenisVaksinModel> _vaksinList = [];
  ImunisasiModel? _selected;

  bool _isLoading      = false;
  String? _errorMessage;
  int _currentPage     = 1;
  int _lastPage        = 1;

  // ── Getters ───────────────────────────────────────────────────────
  List<ImunisasiModel> get list        => _list;
  List<JenisVaksinModel> get vaksinList => _vaksinList;
  ImunisasiModel? get selected         => _selected;
  bool get isLoading                   => _isLoading;
  String? get errorMessage             => _errorMessage;
  bool get hasMore                     => _currentPage < _lastPage;

  // ── Fetch imunisasi ───────────────────────────────────────────────
  Future<void> fetchAll({String? nikAnak, int? idVaksin}) async {
    _setLoading(true);
    _currentPage = 1;

    final result = await _service.getAll(
      nikAnak:  nikAnak,
      idVaksin: idVaksin,
      page:     1,
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

  // ── Fetch semua jenis vaksin ──────────────────────────────────────
  Future<void> fetchVaksin() async {
    if (_vaksinList.isNotEmpty) return; // sudah ada, skip
    final result = await _vaksinService.getAll();
    if (result.isSuccess) {
      _vaksinList = result.data!;
      notifyListeners();
    }
  }

  // ── Catat imunisasi ───────────────────────────────────────────────
  Future<bool> create(ImunisasiModel imunisasi) async {
    _setLoading(true);
    final result = await _service.create(imunisasi);

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
      final idx = _list.indexWhere((i) => i.idImunisasi == id);
      if (idx != -1) _list[idx] = result.data!;
      if (_selected?.idImunisasi == id) _selected = result.data;
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
      _list.removeWhere((i) => i.idImunisasi == id);
      if (_selected?.idImunisasi == id) _selected = null;
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