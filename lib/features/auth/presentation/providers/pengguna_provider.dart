// lib/features/auth/presentation/providers/pengguna_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/models/pengguna_model.dart';
import '../../../../data/services/pengguna_service.dart';

class PenggunaProvider extends ChangeNotifier {
  final PenggunaService _service = PenggunaService();

  List<PenggunaModel> _list = [];
  PenggunaModel? _selected;
  bool _isLoading           = false;
  String? _errorMessage;
  int _currentPage          = 1;
  int _lastPage             = 1;

  // ── Getters ───────────────────────────────────────────────────────
  List<PenggunaModel> get list => _list;
  PenggunaModel? get selected  => _selected;
  bool get isLoading           => _isLoading;
  String? get errorMessage     => _errorMessage;
  bool get hasMore             => _currentPage < _lastPage;

  List<PenggunaModel> get listBidan =>
      _list.where((p) => p.role == 'Bidan').toList();
  List<PenggunaModel> get listKader =>
      _list.where((p) => p.role == 'Kader').toList();
  List<PenggunaModel> get listOrangTua =>
      _list.where((p) => p.role == 'OrangTua').toList();

  // ── Fetch semua pengguna ──────────────────────────────────────────
  Future<void> fetchAll({
    String? role,
    String? search,
    int? idPosyandu,
  }) async {
    _setLoading(true);
    _currentPage  = 1;
    _errorMessage = null;

    final result = await _service.getAll(
      role:       role,
      search:     search,
      idPosyandu: idPosyandu,
      page:       1,
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
  Future<void> loadMore({String? role, String? search}) async {
    if (!hasMore || _isLoading) return;
    _setLoading(true);

    final result = await _service.getAll(
      role:   role,
      search: search,
      page:   _currentPage + 1,
    );

    if (result.isSuccess) {
      _list.addAll(result.data!.data);
      _currentPage = result.data!.currentPage;
      _lastPage    = result.data!.lastPage;
    }

    _setLoading(false);
  }

  // ── Detail pengguna ───────────────────────────────────────────────
  Future<void> fetchDetail(int id) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _service.getById(id);

    if (result.isSuccess) {
      _selected = result.data;
    } else {
      _errorMessage = result.error;
    }

    _setLoading(false);
  }

  // ── Tambah pengguna ───────────────────────────────────────────────
  Future<bool> create(Map<String, dynamic> data) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _service.create(data);

    if (result.isSuccess) {
      _list.insert(0, result.data!);
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  // ── Update pengguna ───────────────────────────────────────────────
  Future<bool> update(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _service.update(id, data);

    if (result.isSuccess) {
      final idx = _list.indexWhere((p) => p.idUser == id);
      if (idx != -1) _list[idx] = result.data!;
      if (_selected?.idUser == id) _selected = result.data;
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  // ── Hapus pengguna ────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _service.delete(id);

    if (result.isSuccess) {
      _list.removeWhere((p) => p.idUser == id);
      if (_selected?.idUser == id) _selected = null;
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

  void clearSelected() {
    _selected = null;
    notifyListeners();
  }
}