// lib/features/jadwal/models/jadwal_model.dart

class JadwalModel {
  final int     idJadwal;
  final int?    idPosyandu;
  final String  tglKegiatan;
  final String  lokasi;
  final String? agenda;
  final String? namaPosyandu;

  JadwalModel({
    required this.idJadwal,
    this.idPosyandu,
    required this.tglKegiatan,
    required this.lokasi,
    this.agenda,
    this.namaPosyandu,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) =>
      JadwalModel(
        idJadwal:     json['id_jadwal'] as int,
        idPosyandu:   json['id_posyandu'] as int?,
        tglKegiatan:  json['tgl_kegiatan'] as String,
        lokasi:       json['lokasi'] as String,
        agenda:       json['agenda'] as String?,
        namaPosyandu: json['posyandu']?['nama_posyandu'] as String?,
      );

  // Format tanggal untuk display
DateTime get tglDateTime {
  // Ambil hanya bagian tanggal (YYYY-MM-DD) saja
  final dateOnly = tglKegiatan.split('T').first;
  final parts = dateOnly.split('-');
  if (parts.length == 3) {
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
  return DateTime.parse(tglKegiatan);
}
  bool get isUpcoming => tglDateTime.isAfter(DateTime.now());
  bool get isPast     => tglDateTime.isBefore(DateTime.now());
}