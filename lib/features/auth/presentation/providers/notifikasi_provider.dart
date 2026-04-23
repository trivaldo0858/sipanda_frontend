// lib/providers/notifikasi_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/models/notifikasi_model.dart';
import '../../../../data/services/notifikasi_service.dart';

class NotifikasiProvider extends ChangeNotifier {
  final NotifikasiService _service = NotifikasiService();

  List<NotifikasiModel> _list = [];
  int _unreadCount            = 0;
  bool _isLoading             = false;
  String? _errorMessage;
  int _currentPage            = 1;
  int _lastPage               = 1;

  // ── Getters ───────────────────────────────────────────────────────
  List<NotifikasiModel> get list => _list;
  int get unreadCount            => _unreadCount;
  bool get isLoading             => _isLoading;
  String? get errorMessage       => _errorMessage;
  bool get hasMore               => _currentPage < _lastPage;

  // ── Fetch notifikasi ──────────────────────────────────────────────
  Future<void> fetchAll({String? status, String? jenisNotif}) async {
    _setLoading(true);
    _currentPage = 1;

    final result = await _service.getAll(
      status:     status,
      jenisNotif: jenisNotif,
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
  Future<void> loadMore() async {
    if (!hasMore || _isLoading) return;
    _setLoading(true);

    final result = await _service.getAll(page: _currentPage + 1);

    if (result.isSuccess) {
      _list.addAll(result.data!.data);
      _currentPage = result.data!.currentPage;
      _lastPage    = result.data!.lastPage;
    }

    _setLoading(false);
  }

  // ── Ambil jumlah belum dibaca (untuk badge) ───────────────────────
  Future<void> fetchUnreadCount() async {
    final result = await _service.getUnreadCount();
    if (result.isSuccess) {
      _unreadCount = result.data!;
      notifyListeners();
    }
  }

  // ── Tandai satu sudah dibaca ──────────────────────────────────────
  Future<void> markRead(int id) async {
    await _service.markRead(id);

    final idx = _list.indexWhere((n) => n.idNotifikasi == id);
    if (idx != -1 && _list[idx].isBelumDibaca) {
      // Buat object baru dengan status updated
      final old = _list[idx];
      _list[idx] = NotifikasiModel(
        idNotifikasi: old.idNotifikasi,
        idUser:       old.idUser,
        nikAnak:      old.nikAnak,
        pesan:        old.pesan,
        tglKirim:     old.tglKirim,
        status:       'Sudah Dibaca',
        jenisNotif:   old.jenisNotif,
      );
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    }
  }

  // ── Tandai semua sudah dibaca ─────────────────────────────────────
  Future<void> markAllRead() async {
    await _service.markAllRead();

    _list = _list.map((n) => NotifikasiModel(
      idNotifikasi: n.idNotifikasi,
      idUser:       n.idUser,
      nikAnak:      n.nikAnak,
      pesan:        n.pesan,
      tglKirim:     n.tglKirim,
      status:       'Sudah Dibaca',
      jenisNotif:   n.jenisNotif,
    )).toList();

    _unreadCount = 0;
    notifyListeners();
  }

  // ── Hapus notifikasi ──────────────────────────────────────────────
  Future<bool> delete(int id) async {
    final notif = _list.firstWhere((n) => n.idNotifikasi == id);
    final result = await _service.delete(id);

    if (result.isSuccess) {
      _list.removeWhere((n) => n.idNotifikasi == id);
      if (notif.isBelumDibaca && _unreadCount > 0) _unreadCount--;
      notifyListeners();
      return true;
    }
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