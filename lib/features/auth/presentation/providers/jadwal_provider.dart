// lib/providers/jadwal_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/models/jadwal_model.dart';
import '../../../../data/services/jadwal_service.dart';

class JadwalProvider extends ChangeNotifier {
  final JadwalService _service = JadwalService();

  List<JadwalPosyanduModel> _list     = [];
  List<JadwalPosyanduModel> _upcoming = [];
  JadwalPosyanduModel? _selected;

  bool _isLoading   = false;
  String? _errorMessage;
  int _currentPage  = 1;
  int _lastPage     = 1;

  // ── Getters ───────────────────────────────────────────────────────
  List<JadwalPosyanduModel> get list     => _list;
  List<JadwalPosyanduModel> get upcoming => _upcoming;
  JadwalPosyanduModel? get selected      => _selected;
  bool get isLoading                     => _isLoading;
  String? get errorMessage               => _errorMessage;
  bool get hasMore                       => _currentPage < _lastPage;

  // ── Fetch semua jadwal ────────────────────────────────────────────
  Future<void> fetchAll({String? filter, int? idKader}) async {
    _setLoading(true);
    _currentPage = 1;

    final result = await _service.getAll(
      filter:  filter,
      idKader: idKader,
      page:    1,
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

  // ── Fetch jadwal mendatang saja (untuk dashboard & notif) ─────────
  Future<void> fetchUpcoming() async {
    final result = await _service.getAll(filter: 'upcoming', page: 1);
    if (result.isSuccess) {
      _upcoming = result.data!.data;
      notifyListeners();
    }
  }

  // ── Load more ─────────────────────────────────────────────────────
  Future<void> loadMore({String? filter}) async {
    if (!hasMore || _isLoading) return;
    _setLoading(true);

    final result = await _service.getAll(
      filter: filter,
      page:   _currentPage + 1,
    );

    if (result.isSuccess) {
      _list.addAll(result.data!.data);
      _currentPage = result.data!.currentPage;
      _lastPage    = result.data!.lastPage;
    }

    _setLoading(false);
  }

  // ── Detail jadwal ─────────────────────────────────────────────────
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

  // ── Buat jadwal baru ──────────────────────────────────────────────
  Future<bool> create(JadwalPosyanduModel jadwal) async {
    _setLoading(true);
    final result = await _service.create(jadwal);

    if (result.isSuccess) {
      _list.insert(0, result.data!);
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  // ── Update jadwal ─────────────────────────────────────────────────
  Future<bool> update(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    final result = await _service.update(id, data);

    if (result.isSuccess) {
      final idx = _list.indexWhere((j) => j.idJadwal == id);
      if (idx != -1) _list[idx] = result.data!;
      if (_selected?.idJadwal == id) _selected = result.data;
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  // ── Hapus jadwal ──────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    _setLoading(true);
    final result = await _service.delete(id);

    if (result.isSuccess) {
      _list.removeWhere((j) => j.idJadwal == id);
      if (_selected?.idJadwal == id) _selected = null;
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