// lib/features/laporan/models/laporan_model.dart

class LaporanModel {
  final int    idLaporan;
  final String jenis;
  final String periodeAwal;
  final String periodeAkhir;
  final String tglCetak;
  final RingkasanLaporan? ringkasan;

  LaporanModel({
    required this.idLaporan,
    required this.jenis,
    required this.periodeAwal,
    required this.periodeAkhir,
    required this.tglCetak,
    this.ringkasan,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) => LaporanModel(
    idLaporan:    json['id_laporan'] as int,
    jenis:        json['jenis_laporan'] as String,
    periodeAwal:  json['periode_awal'] as String,
    periodeAkhir: json['periode_akhir'] as String,
    tglCetak:     json['tgl_cetak'] as String,
    ringkasan:    json['ringkasan'] != null
        ? RingkasanLaporan.fromJson(json['ringkasan'])
        : null,
  );
}

class RingkasanLaporan {
  final RingkasanPemeriksaan? pemeriksaan;
  final RingkasanImunisasi?   imunisasi;

  RingkasanLaporan({this.pemeriksaan, this.imunisasi});

  factory RingkasanLaporan.fromJson(Map<String, dynamic> json) => RingkasanLaporan(
    pemeriksaan: json['pemeriksaan'] != null
        ? RingkasanPemeriksaan.fromJson(json['pemeriksaan'])
        : null,
    imunisasi: json['imunisasi'] != null
        ? RingkasanImunisasi.fromJson(json['imunisasi'])
        : null,
  );
}

class RingkasanPemeriksaan {
  final int    total;
  final int    totalAnak;
  final double? rataBerat;
  final double? rataTinggi;
  final int    disetujui;

  RingkasanPemeriksaan({
    required this.total,
    required this.totalAnak,
    this.rataBerat,
    this.rataTinggi,
    required this.disetujui,
  });

  factory RingkasanPemeriksaan.fromJson(Map<String, dynamic> json) => RingkasanPemeriksaan(
    total:       json['total'] as int? ?? 0,
    totalAnak:   json['total_anak'] as int? ?? 0,
    rataBerat:   (json['rata_berat_badan'] as num?)?.toDouble(),
    rataTinggi:  (json['rata_tinggi_badan'] as num?)?.toDouble(),
    disetujui:   json['disetujui'] as int? ?? 0,
  );
}

class RingkasanImunisasi {
  final int               total;
  final int               totalAnak;
  final Map<String, int>  perVaksin;

  RingkasanImunisasi({
    required this.total,
    required this.totalAnak,
    required this.perVaksin,
  });

  factory RingkasanImunisasi.fromJson(Map<String, dynamic> json) => RingkasanImunisasi(
    total:     json['total'] as int? ?? 0,
    totalAnak: json['total_anak'] as int? ?? 0,
    perVaksin: (json['per_vaksin'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v as int)),
  );
}