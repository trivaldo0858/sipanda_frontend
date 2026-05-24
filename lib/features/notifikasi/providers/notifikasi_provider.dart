// lib/features/notifikasi/providers/notifikasi_provider.dart

import 'package:flutter/material.dart';
import '../models/notifikasi_model.dart';
import '../services/notifikasi_service.dart';

enum NotifikasiStatus { initial, loading, loaded, error }

class NotifikasiProvider extends ChangeNotifier {
  final NotifikasiService _service = NotifikasiService();

  NotifikasiStatus       _status       = NotifikasiStatus.initial;
  List<NotifikasiModel>  _list         = [];
  int                    _unreadCount  = 0;
  String?                _errorMessage;

  NotifikasiStatus      get status       => _status;
  List<NotifikasiModel> get list         => _list;
  int                   get unreadCount  => _unreadCount;
  String?               get errorMessage => _errorMessage;
  bool get isLoading => _status == NotifikasiStatus.loading;

  List<NotifikasiModel> get belumDibaca =>
      _list.where((n) => n.isBelumDibaca).toList();
  List<NotifikasiModel> get sudahDibaca =>
      _list.where((n) => !n.isBelumDibaca).toList();

  Future<void> loadList() async {
    _status = NotifikasiStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _list        = await _service.getList();
      _unreadCount = _list.where((n) => n.isBelumDibaca).length;
      _status      = NotifikasiStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status       = NotifikasiStatus.error;
    }
    notifyListeners();
  }

  Future<void> markRead(int idNotifikasi) async {
    try {
      await _service.markRead(idNotifikasi);
      final idx = _list.indexWhere(
          (n) => n.idNotifikasi == idNotifikasi);
      if (idx != -1) {
        _list[idx] = NotifikasiModel(
          idNotifikasi: _list[idx].idNotifikasi,
          idUser:       _list[idx].idUser,
          nikAnak:      _list[idx].nikAnak,
          pesan:        _list[idx].pesan,
          tglKirim:     _list[idx].tglKirim,
          status:       'Sudah Dibaca',
          jenisNotif:   _list[idx].jenisNotif,
        );
        _unreadCount = _list.where((n) => n.isBelumDibaca).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error markRead: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
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
    } catch (e) {
      debugPrint('Error markAllRead: $e');
    }
  }

  Future<bool> delete(int idNotifikasi) async {
    try {
      await _service.delete(idNotifikasi);
      _list.removeWhere((n) => n.idNotifikasi == idNotifikasi);
      _unreadCount = _list.where((n) => n.isBelumDibaca).length;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error delete notif: $e');
      return false;
    }
  }
}