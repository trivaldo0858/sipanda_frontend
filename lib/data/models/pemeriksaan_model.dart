// lib/data/models/pemeriksaan_model.dart

class PemeriksaanModel {
  final int idPemeriksaan;
  final String nikAnak;
  final int idKader;
  final String? nipBidan;
  final int? idJadwal;
  final DateTime tglPemeriksaan;
  final double? beratBadan;
  final double? tinggiBadan;
  final double? lingkarKepala;
  final String? keluhan;
  final String? namaAnak;
  final String? namaKader;
  final String? namaBidan;

  PemeriksaanModel({
    required this.idPemeriksaan,
    required this.nikAnak,
    required this.idKader,
    this.nipBidan,
    this.idJadwal,
    required this.tglPemeriksaan,
    this.beratBadan,
    this.tinggiBadan,
    this.lingkarKepala,
    this.keluhan,
    this.namaAnak,
    this.namaKader,
    this.namaBidan,
  });

  factory PemeriksaanModel.fromJson(Map<String, dynamic> json) {
    return PemeriksaanModel(
      idPemeriksaan:  json['id_pemeriksaan'] as int,
      nikAnak:        json['nik_anak'] as String,
      idKader:        json['id_kader'] as int,
      nipBidan:       json['nip_bidan'] as String?,
      idJadwal:       json['id_jadwal'] as int?,
      tglPemeriksaan: DateTime.parse(json['tgl_pemeriksaan'] as String),
      beratBadan:     (json['berat_badan'] as num?)?.toDouble(),
      tinggiBadan:    (json['tinggi_badan'] as num?)?.toDouble(),
      lingkarKepala:  (json['lingkar_kepala'] as num?)?.toDouble(),
      keluhan:        json['keluhan'] as String?,
      namaAnak:       json['anak']?['nama_anak'] as String?,
      namaKader:      json['kader']?['nama_kader'] as String?,
      namaBidan:      json['bidan']?['nama_bidan'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nik_anak':        nikAnak,
    'id_kader':        idKader,
    if (nipBidan != null)  'nip_bidan':  nipBidan,
    if (idJadwal != null)  'id_jadwal':  idJadwal,
    'tgl_pemeriksaan': tglPemeriksaan.toIso8601String().split('T').first,
    if (beratBadan != null)    'berat_badan':    beratBadan,
    if (tinggiBadan != null)   'tinggi_badan':   tinggiBadan,
    if (lingkarKepala != null) 'lingkar_kepala': lingkarKepala,
    if (keluhan != null)       'keluhan':        keluhan,
  };
}