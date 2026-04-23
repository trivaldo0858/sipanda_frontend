// lib/data/models/posyandu_model.dart

class PosyanduModel {
  final int idPosyandu;
  final String namaPosyandu;
  final String? alamat;
  final String? wilayah;
  final String? noTelp;
  final String status;

  PosyanduModel({
    required this.idPosyandu,
    required this.namaPosyandu,
    this.alamat,
    this.wilayah,
    this.noTelp,
    this.status = 'Aktif',
  });

  factory PosyanduModel.fromJson(Map<String, dynamic> json) {
    return PosyanduModel(
      idPosyandu:    json['id_posyandu'] as int,
      namaPosyandu:  json['nama_posyandu'] as String,
      alamat:        json['alamat'] as String?,
      wilayah:       json['wilayah'] as String?,
      noTelp:        json['no_telp'] as String?,
      status:        json['status'] as String? ?? 'Aktif',
    );
  }

  Map<String, dynamic> toJson() => {
    'nama_posyandu': namaPosyandu,
    if (alamat != null)  'alamat':  alamat,
    if (wilayah != null) 'wilayah': wilayah,
    if (noTelp != null)  'no_telp': noTelp,
    'status': status,
  };

  bool get isAktif => status == 'Aktif';
}