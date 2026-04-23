// lib/features/auth/presentation/providers/anak_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/models/anak_model.dart';
import '../../../../data/services/anak_service.dart';

class AnakProvider extends ChangeNotifier {
  final AnakService _anakService = AnakService();

  List<AnakModel> _anakList            = [];
  AnakModel? _selectedAnak;
  List<PerkembanganItem> _perkembangan = [];

  bool _isLoading       = false;
  bool _isLoadingDetail = false;
  String? _errorMessage;
  int _currentPage      = 1;
  bool _hasMore         = false;

  List<AnakModel> get anakList             => _anakList;
  AnakModel? get selectedAnak              => _selectedAnak;
  List<PerkembanganItem> get perkembangan  => _perkembangan;
  bool get isLoading                       => _isLoading;
  bool get isLoadingDetail                 => _isLoadingDetail;
  String? get errorMessage                 => _errorMessage;
  bool get hasMore                         => _hasMore;

  Future<void> fetchAll({String? search}) async {
    _isLoading    = true;
    _errorMessage = null;
    _currentPage  = 1;
    notifyListeners();

    final result = await _anakService.getAll(search: search, page: 1);

    if (result.isSuccess) {
      _anakList    = result.data!.data;
      _currentPage = result.data!.currentPage;
      _hasMore     = result.data!.hasNextPage;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore({String? search}) async {
    if (!_hasMore || _isLoading) return;
    _isLoading = true;
    notifyListeners();

    final result = await _anakService.getAll(
      search: search,
      page:   _currentPage + 1,
    );

    if (result.isSuccess) {
      _anakList.addAll(result.data!.data);
      _currentPage = result.data!.currentPage;
      _hasMore     = result.data!.hasNextPage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDetail(String nik) async {
    _isLoadingDetail = true;
    _errorMessage    = null;
    notifyListeners();

    final result = await _anakService.getByNik(nik);

    if (result.isSuccess) {
      _selectedAnak = result.data;
    } else {
      _errorMessage = result.error;
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  Future<bool> create(AnakModel anak) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _anakService.create(anak);

    if (result.isSuccess) {
      _anakList.insert(0, result.data!);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = result.error;
    _isLoading    = false;
    notifyListeners();
    return false;
  }

  Future<bool> update(String nik, Map<String, dynamic> data) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _anakService.update(nik, data);

    if (result.isSuccess) {
      final idx = _anakList.indexWhere((a) => a.nikAnak == nik);
      if (idx != -1) _anakList[idx] = result.data!;
      if (_selectedAnak?.nikAnak == nik) _selectedAnak = result.data;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = result.error;
    _isLoading    = false;
    notifyListeners();
    return false;
  }

  Future<bool> delete(String nik) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _anakService.delete(nik);

    if (result.isSuccess) {
      _anakList.removeWhere((a) => a.nikAnak == nik);
      if (_selectedAnak?.nikAnak == nik) _selectedAnak = null;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = result.error;
    _isLoading    = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchPerkembangan(String nik) async {
    _isLoadingDetail = true;
    notifyListeners();

    final result = await _anakService.getPerkembangan(nik);

    if (result.isSuccess) {
      _perkembangan = result.data!;
    } else {
      _errorMessage = result.error;
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelected() {
    _selectedAnak = null;
    notifyListeners();
  }
}