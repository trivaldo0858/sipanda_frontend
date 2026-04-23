// lib/data/models/anak_model.dart

class AnakModel {
  final String nikAnak;
  final String nikOrangTua;
  final String namaAnak;
  final DateTime tglLahir;
  final String jenisKelamin;
  final int? umurBulan;

  AnakModel({
    required this.nikAnak,
    required this.nikOrangTua,
    required this.namaAnak,
    required this.tglLahir,
    required this.jenisKelamin,
    this.umurBulan,
  });

  factory AnakModel.fromJson(Map<String, dynamic> json) {
    return AnakModel(
      nikAnak:      json['nik_anak'] as String,
      nikOrangTua:  json['nik_orang_tua'] as String,
      namaAnak:     json['nama_anak'] as String,
      tglLahir:     DateTime.parse(json['tgl_lahir'] as String),
      jenisKelamin: json['jenis_kelamin'] as String,
      umurBulan:    json['umur_bulan'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nik_anak':      nikAnak,
    'nik_orang_tua': nikOrangTua,
    'nama_anak':     namaAnak,
    'tgl_lahir':     tglLahir.toIso8601String().split('T').first,
    'jenis_kelamin': jenisKelamin,
  };

  String get jenisKelaminLabel => jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan';
}

// ── Perkembangan (grafik) ─────────────────────────────────────────────
class PerkembanganItem {
  final DateTime tglPemeriksaan;
  final double? beratBadan;
  final double? tinggiBadan;
  final double? lingkarKepala;

  PerkembanganItem({
    required this.tglPemeriksaan,
    this.beratBadan,
    this.tinggiBadan,
    this.lingkarKepala,
  });

  factory PerkembanganItem.fromJson(Map<String, dynamic> json) {
    return PerkembanganItem(
      tglPemeriksaan: DateTime.parse(json['tgl_pemeriksaan'] as String),
      beratBadan:     (json['berat_badan'] as num?)?.toDouble(),
      tinggiBadan:    (json['tinggi_badan'] as num?)?.toDouble(),
      lingkarKepala:  (json['lingkar_kepala'] as num?)?.toDouble(),
    );
  }
}