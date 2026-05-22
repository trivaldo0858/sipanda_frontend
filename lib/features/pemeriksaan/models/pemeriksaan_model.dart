// lib/features/pemeriksaan/models/pemeriksaan_model.dart

import 'package:flutter/material.dart';

class PemeriksaanModel {
  final int     idPeriksa;
  final String  nikAnak;
  final int     idPosyandu;
  final String  tglPeriksa;
  final double? beratBadan;
  final double? tinggiBadan;
  final double? lingkarKepala;
  final String? keluhan;
  final String  statusValidasi;
  final String? catatanValidasi;
  final String? namaAnak;
  final String? nipBidan;

  PemeriksaanModel({
    required this.idPeriksa,
    required this.nikAnak,
    required this.idPosyandu,
    required this.tglPeriksa,
    this.beratBadan,
    this.tinggiBadan,
    this.lingkarKepala,
    this.keluhan,
    required this.statusValidasi,
    this.catatanValidasi,
    this.namaAnak,
    this.nipBidan,
  });

  factory PemeriksaanModel.fromJson(Map<String, dynamic> json) =>
      PemeriksaanModel(
        idPeriksa:       json['id_periksa'] as int,
        nikAnak:         json['nik_anak'] as String,
        idPosyandu:      json['id_posyandu'] as int? ?? 0,
        tglPeriksa:      json['tgl_periksa'] as String,
        beratBadan:      (json['berat_badan'] as num?)?.toDouble(),
        tinggiBadan:     (json['tinggi_badan'] as num?)?.toDouble(),
        lingkarKepala:   (json['lingkar_kepala'] as num?)?.toDouble(),
        keluhan:         json['keluhan'] as String?,
        statusValidasi:  json['status_validasi'] as String? ?? 'Menunggu',
        catatanValidasi: json['catatan_validasi'] as String?,
        namaAnak:        json['anak']?['nama_anak'] as String?,
        nipBidan:        json['nip_bidan'] as String?,
      );

  bool get isMenunggu  => statusValidasi == 'Menunggu';
  bool get isDisetujui => statusValidasi == 'Disetujui';
  bool get isDitolak   => statusValidasi == 'Ditolak';

  Color get statusColor => switch (statusValidasi) {
    'Disetujui' => const Color(0xFF198754),
    'Ditolak'   => const Color(0xFFDC3545),
    _           => const Color(0xFFFFC107),
  };

  Color get statusBgColor => switch (statusValidasi) {
    'Disetujui' => const Color(0xFFD1E7DD),
    'Ditolak'   => const Color(0xFFF8D7DA),
    _           => const Color(0xFFFFF3CD),
  };
}