// lib/features/kms/models/kms_model.dart

class KmsPemeriksaan {
  final String tglPeriksa;
  final double? umurBulan;
  final double? beratBadan;
  final double? tinggiBadan;
  final double? lingkarKepala;

  KmsPemeriksaan({
    required this.tglPeriksa,
    this.umurBulan,
    this.beratBadan,
    this.tinggiBadan,
    this.lingkarKepala,
  });

  factory KmsPemeriksaan.fromJson(Map<String, dynamic> json) =>
      KmsPemeriksaan(
        tglPeriksa:   json['tgl_periksa'] as String,
        umurBulan:    (json['umur_bulan'] as num?)?.toDouble(),
        beratBadan:   (json['berat_badan'] as num?)?.toDouble(),
        tinggiBadan:  (json['tinggi_badan'] as num?)?.toDouble(),
        lingkarKepala:(json['lingkar_kepala'] as num?)?.toDouble(),
      );
}

class KmsModel {
  final String  nikAnak;
  final String  namaAnak;
  final String  tglLahir;
  final String  jenisKelamin;
  final int?    umurBulan;
  final String? umurFormat;
  final List<KmsPemeriksaan> pemeriksaan;

  KmsModel({
    required this.nikAnak,
    required this.namaAnak,
    required this.tglLahir,
    required this.jenisKelamin,
    this.umurBulan,
    this.umurFormat,
    required this.pemeriksaan,
  });

  factory KmsModel.fromJson(Map<String, dynamic> json) {
    final anak = json['anak'] as Map<String, dynamic>? ?? {};
    final pemeriksaanList =
        (json['pemeriksaan'] as List? ?? [])
            .map((e) => KmsPemeriksaan.fromJson(e))
            .toList();

    return KmsModel(
      nikAnak:      anak['nik_anak'] as String? ?? '',
      namaAnak:     anak['nama_anak'] as String? ?? '',
      tglLahir:     anak['tgl_lahir'] as String? ?? '',
      jenisKelamin: anak['jenis_kelamin'] as String? ?? 'L',
      umurBulan:    anak['umur_bulan'] as int?,
      umurFormat:   anak['umur_format'] as String?,
      pemeriksaan:  pemeriksaanList,
    );
  }

  // Urut dari terlama ke terbaru untuk grafik
  List<KmsPemeriksaan> get pemeriksaanUrut {
    final list = [...pemeriksaan];
    list.sort((a, b) => a.tglPeriksa.compareTo(b.tglPeriksa));
    return list;
  }

  KmsPemeriksaan? get terakhir {
    if (pemeriksaan.isEmpty) return null;
    final list = [...pemeriksaan];
    list.sort((a, b) => b.tglPeriksa.compareTo(a.tglPeriksa));
    return list.first;
  }

  bool get isLakiLaki => jenisKelamin == 'L';
}