// lib/features/auth/presentation/providers/posyandu_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/models/posyandu_model.dart';
import '../../../../data/services/posyandu_service.dart';

class PosyanduProvider extends ChangeNotifier {
  final PosyanduService _service = PosyanduService();

  List<PosyanduModel> _list = [];
  PosyanduModel? _selected;
  bool _isLoading           = false;
  String? _errorMessage;
  int _currentPage          = 1;
  int _lastPage             = 1;

  List<PosyanduModel> get list => _list;
  PosyanduModel? get selected  => _selected;
  bool get isLoading           => _isLoading;
  String? get errorMessage     => _errorMessage;
  bool get hasMore             => _currentPage < _lastPage;
  List<PosyanduModel> get listAktif =>
      _list.where((p) => p.isAktif).toList();

  Future<void> fetchAll({String? search, String? status}) async {
    _setLoading(true);
    _currentPage  = 1;
    _errorMessage = null;

    final result = await _service.getAll(
      search: search,
      status: status,
      page:   1,
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

  Future<bool> create(PosyanduModel posyandu) async {
    _setLoading(true);
    final result = await _service.create(posyandu);
    if (result.isSuccess) {
      _list.insert(0, result.data!);
      _setLoading(false);
      return true;
    }
    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    final result = await _service.update(id, data);
    if (result.isSuccess) {
      final idx = _list.indexWhere((p) => p.idPosyandu == id);
      if (idx != -1) _list[idx] = result.data!;
      if (_selected?.idPosyandu == id) _selected = result.data;
      _setLoading(false);
      return true;
    }
    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  Future<bool> delete(int id) async {
    _setLoading(true);
    final result = await _service.delete(id);
    if (result.isSuccess) {
      _list.removeWhere((p) => p.idPosyandu == id);
      if (_selected?.idPosyandu == id) _selected = null;
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