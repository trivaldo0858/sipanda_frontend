// lib/features/anak/models/anak_model.dart

class AnakModel {
  final String  nikAnak;
  final String  nikOrangTua;
  final int     idPosyandu;
  final String  namaAnak;
  final String  tglLahir;
  final String  jenisKelamin;
  final String  namaAyah;
  final String? namaIbu;
  final String? noTelp;
  final String? alamat;
  final int?    umurBulan;
  final String? umurFormat;
  final String? namaPosyandu;

  AnakModel({
    required this.nikAnak,
    required this.nikOrangTua,
    required this.idPosyandu,
    required this.namaAnak,
    required this.tglLahir,
    required this.jenisKelamin,
    required this.namaAyah,
    this.namaIbu,
    this.noTelp,
    this.alamat,
    this.umurBulan,
    this.umurFormat,
    this.namaPosyandu,
  });

  factory AnakModel.fromJson(Map<String, dynamic> json) {
    final orangTua = json['orang_tua'] as Map<String, dynamic>?;
    return AnakModel(
      nikAnak:      json['nik_anak'] as String,
      nikOrangTua:  json['nik_orang_tua'] as String? ?? '',
      idPosyandu:   json['id_posyandu'] as int? ?? 0,
      namaAnak:     json['nama_anak'] as String,
      tglLahir:     json['tgl_lahir'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      namaAyah:     json['nama_ayah'] as String? ?? '',
      namaIbu:      orangTua?['nama_ibu'] as String?,
      noTelp:       orangTua?['no_telp'] as String?,
      alamat:       orangTua?['alamat'] as String?,
      umurBulan:    json['umur_bulan'] as int?,
      umurFormat:   json['umur_format'] as String?,
      namaPosyandu: json['posyandu']?['nama_posyandu'] as String?,
    );
  }

  bool get isLakiLaki => jenisKelamin == 'L';
  String get jenisKelaminLabel => isLakiLaki ? 'Laki-laki' : 'Perempuan';
}