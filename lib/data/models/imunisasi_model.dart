// lib/data/models/imunisasi_model.dart

class JenisVaksinModel {
  final int idVaksin;
  final String namaVaksin;
  final String? deskripsi;

  JenisVaksinModel({
    required this.idVaksin,
    required this.namaVaksin,
    this.deskripsi,
  });

  factory JenisVaksinModel.fromJson(Map<String, dynamic> json) {
    return JenisVaksinModel(
      idVaksin:   json['id_vaksin'] as int,
      namaVaksin: json['nama_vaksin'] as String,
      deskripsi:  json['deskripsi'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nama_vaksin': namaVaksin,
    if (deskripsi != null) 'deskripsi': deskripsi,
  };
}

class ImunisasiModel {
  final int idImunisasi;
  final String nikAnak;
  final String? nipBidan;
  final int idVaksin;
  final DateTime tglPemberian;
  final String? namaAnak;
  final String? namaBidan;
  final JenisVaksinModel? jenisVaksin;

  ImunisasiModel({
    required this.idImunisasi,
    required this.nikAnak,
    this.nipBidan,
    required this.idVaksin,
    required this.tglPemberian,
    this.namaAnak,
    this.namaBidan,
    this.jenisVaksin,
  });

  factory ImunisasiModel.fromJson(Map<String, dynamic> json) {
    return ImunisasiModel(
      idImunisasi:  json['id_imunisasi'] as int,
      nikAnak:      json['nik_anak'] as String,
      nipBidan:     json['nip_bidan'] as String?,
      idVaksin:     json['id_vaksin'] as int,
      tglPemberian: DateTime.parse(json['tgl_pemberian'] as String),
      namaAnak:     json['anak']?['nama_anak'] as String?,
      namaBidan:    json['bidan']?['nama_bidan'] as String?,
      jenisVaksin:  json['jenis_vaksin'] != null
                      ? JenisVaksinModel.fromJson(json['jenis_vaksin'])
                      : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'nik_anak':      nikAnak,
    'id_vaksin':     idVaksin,
    'tgl_pemberian': tglPemberian.toIso8601String().split('T').first,
    if (nipBidan != null) 'nip_bidan': nipBidan,
  };
}