// lib/data/models/laporan_model.dart

class LaporanModel {
  final int idLaporan;
  final String nipBidan;
  final String jenisLaporan;
  final DateTime periodeAwal;
  final DateTime periodeAkhir;
  final DateTime tglCetak;
  final String? namaBidan;
  final RingkasanLaporan? ringkasan;

  LaporanModel({
    required this.idLaporan,
    required this.nipBidan,
    required this.jenisLaporan,
    required this.periodeAwal,
    required this.periodeAkhir,
    required this.tglCetak,
    this.namaBidan,
    this.ringkasan,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      idLaporan:    json['id_laporan'] as int,
      nipBidan:     json['nip_bidan'] as String,
      jenisLaporan: json['jenis_laporan'] as String,
      periodeAwal:  DateTime.parse(json['periode_awal'] as String),
      periodeAkhir: DateTime.parse(json['periode_akhir'] as String),
      tglCetak:     DateTime.parse(json['tgl_cetak'] as String),
      namaBidan:    json['bidan']?['nama_bidan'] as String?,
      ringkasan:    json['ringkasan'] != null
                      ? RingkasanLaporan.fromJson(json['ringkasan'])
                      : null,
    );
  }
}

class RingkasanLaporan {
  final int totalPemeriksaan;
  final int totalAnakDiperiksa;
  final int totalImunisasi;
  final Map<String, dynamic> imunisasiPerVaksin;
  final double? rataBeratBadan;
  final double? rataTinggiBadan;

  RingkasanLaporan({
    required this.totalPemeriksaan,
    required this.totalAnakDiperiksa,
    required this.totalImunisasi,
    required this.imunisasiPerVaksin,
    this.rataBeratBadan,
    this.rataTinggiBadan,
  });

  factory RingkasanLaporan.fromJson(Map<String, dynamic> json) {
    return RingkasanLaporan(
      totalPemeriksaan:    json['total_pemeriksaan'] as int,
      totalAnakDiperiksa:  json['total_anak_diperiksa'] as int,
      totalImunisasi:      json['total_imunisasi'] as int,
      imunisasiPerVaksin:  json['imunisasi_per_vaksin'] as Map<String, dynamic>? ?? {},
      rataBeratBadan:      (json['rata_berat_badan'] as num?)?.toDouble(),
      rataTinggiBadan:     (json['rata_tinggi_badan'] as num?)?.toDouble(),
    );
  }
}

// ── Generic Pagination Wrapper ────────────────────────────────────────
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = (json['data'] as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      data:        items,
      currentPage: json['current_page'] as int,
      lastPage:    json['last_page'] as int,
      total:       json['total'] as int,
    );
  }
}