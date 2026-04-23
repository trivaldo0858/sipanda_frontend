// lib/data/models/jadwal_model.dart

class JadwalPosyanduModel {
  final int idJadwal;
  final int idKader;
  final DateTime tglKegiatan;
  final String lokasi;
  final String? agenda;
  final String? namaKader;
  final String? wilayah;

  JadwalPosyanduModel({
    required this.idJadwal,
    required this.idKader,
    required this.tglKegiatan,
    required this.lokasi,
    this.agenda,
    this.namaKader,
    this.wilayah,
  });

  factory JadwalPosyanduModel.fromJson(Map<String, dynamic> json) {
    return JadwalPosyanduModel(
      idJadwal:    json['id_jadwal'] as int,
      idKader:     json['id_kader'] as int,
      tglKegiatan: DateTime.parse(json['tgl_kegiatan'] as String),
      lokasi:      json['lokasi'] as String,
      agenda:      json['agenda'] as String?,
      namaKader:   json['kader']?['nama_kader'] as String?,
      wilayah:     json['kader']?['wilayah'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_kader':     idKader,
    'tgl_kegiatan': tglKegiatan.toIso8601String().split('T').first,
    'lokasi':       lokasi,
    if (agenda != null) 'agenda': agenda,
  };

  bool get isUpcoming => tglKegiatan.isAfter(DateTime.now());
}