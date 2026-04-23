// lib/providers/laporan_provider.dart
// VERSI TERBARU — ganti file lama dengan ini

import 'package:flutter/material.dart';
import '../../../../data/models/laporan_model.dart';
import '../../../../data/services/laporan_service.dart';

class LaporanProvider extends ChangeNotifier {
  final LaporanService _service = LaporanService();

  List<LaporanModel> _list  = [];
  LaporanModel? _selected;
  bool _isLoading           = false;
  bool _isDownloading       = false;
  double _downloadProgress  = 0.0;
  String? _errorMessage;
  String? _downloadedFilePath;
  int _currentPage          = 1;
  int _lastPage             = 1;

  // ── Getters ───────────────────────────────────────────────────────
  List<LaporanModel> get list       => _list;
  LaporanModel? get selected        => _selected;
  bool get isLoading                => _isLoading;
  bool get isDownloading            => _isDownloading;
  double get downloadProgress       => _downloadProgress;
  String? get errorMessage          => _errorMessage;
  String? get downloadedFilePath    => _downloadedFilePath;
  bool get hasMore                  => _currentPage < _lastPage;

  // ── Fetch list ────────────────────────────────────────────────────
  Future<void> fetchAll({String? jenisLaporan}) async {
    _setLoading(true);
    _currentPage = 1;

    final result = await _service.getAll(jenisLaporan: jenisLaporan, page: 1);

    if (result.isSuccess) {
      _list        = result.data!.data;
      _currentPage = result.data!.currentPage;
      _lastPage    = result.data!.lastPage;
    } else {
      _errorMessage = result.error;
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

  // ── Generate ──────────────────────────────────────────────────────
  Future<bool> generate({
    required String jenisLaporan,
    required DateTime periodeAwal,
    required DateTime periodeAkhir,
  }) async {
    _setLoading(true);

    final result = await _service.generate(
      jenisLaporan: jenisLaporan,
      periodeAwal:  periodeAwal.toIso8601String().split('T').first,
      periodeAkhir: periodeAkhir.toIso8601String().split('T').first,
    );

    if (result.isSuccess) {
      _list.insert(0, result.data!);
      _selected = result.data;
      _setLoading(false);
      return true;
    }

    _errorMessage = result.error;
    _setLoading(false);
    return false;
  }

  // ── Download PDF ──────────────────────────────────────────────────
  Future<bool> downloadPdf(int id, String namaFile) async {
    _isDownloading    = true;
    _downloadProgress = 0.0;
    _downloadedFilePath = null;
    _errorMessage     = null;
    notifyListeners();

    final result = await _service.downloadPdf(
      id,
      namaFile,
      onProgress: (received, total) {
        if (total > 0) {
          _downloadProgress = received / total;
          notifyListeners();
        }
      },
    );

    _isDownloading = false;

    if (result.isSuccess) {
      _downloadedFilePath = result.data;
      notifyListeners();
      return true;
    }

    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  // ── Download Excel ────────────────────────────────────────────────
  Future<bool> downloadExcel(int id, String namaFile) async {
    _isDownloading    = true;
    _downloadProgress = 0.0;
    _downloadedFilePath = null;
    _errorMessage     = null;
    notifyListeners();

    final result = await _service.downloadExcel(
      id,
      namaFile,
      onProgress: (received, total) {
        if (total > 0) {
          _downloadProgress = received / total;
          notifyListeners();
        }
      },
    );

    _isDownloading = false;

    if (result.isSuccess) {
      _downloadedFilePath = result.data;
      notifyListeners();
      return true;
    }

    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  // ── Hapus ─────────────────────────────────────────────────────────
  Future<bool> delete(int id) async {
    _setLoading(true);
    final result = await _service.delete(id);

    if (result.isSuccess) {
      _list.removeWhere((l) => l.idLaporan == id);
      if (_selected?.idLaporan == id) _selected = null;
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

  void clearDownload() {
    _downloadedFilePath = null;
    _downloadProgress   = 0.0;
    notifyListeners();
  }
}