// lib/features/imunisasi/models/imunisasi_model.dart

class JenisVaksinModel {
  final int    idVaksin;
  final String namaVaksin;
  final String? deskripsi;

  JenisVaksinModel({
    required this.idVaksin,
    required this.namaVaksin,
    this.deskripsi,
  });

  factory JenisVaksinModel.fromJson(Map<String, dynamic> json) =>
      JenisVaksinModel(
        idVaksin:   json['id_vaksin'] as int,
        namaVaksin: json['nama_vaksin'] as String,
        deskripsi:  json['deskripsi'] as String?,
      );
}

class ImunisasiModel {
  final int     idImunisasi;
  final String? nikAnak;
  final String? nipBidan;
  final int?    idVaksin;
  final String  tglPemberian;
  final String? catatan;
  final String? namaVaksin;
  final String? namaBidan;

  ImunisasiModel({
    required this.idImunisasi,
    this.nikAnak,
    this.nipBidan,
    this.idVaksin,
    required this.tglPemberian,
    this.catatan,
    this.namaVaksin,
    this.namaBidan,
  });

  factory ImunisasiModel.fromJson(Map<String, dynamic> json) =>
      ImunisasiModel(
        idImunisasi:  json['id_imunisasi'] as int,
        nikAnak:      json['nik_anak'] as String?,
        nipBidan:     json['nip_bidan'] as String?,
        idVaksin:     json['id_vaksin'] as int?,
        tglPemberian: json['tgl_pemberian'] as String,
        catatan:      json['catatan'] as String?,
        // Support dua format: flat (riwayat) dan nested (list)
        namaVaksin:   json['nama_vaksin'] as String? ??
            json['jenis_vaksin']?['nama_vaksin'] as String?,
        namaBidan:    json['nama_bidan'] as String? ??
            json['bidan']?['nama_bidan'] as String?,
      );
}