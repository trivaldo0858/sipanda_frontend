// lib/features/notifikasi/models/notifikasi_model.dart

class NotifikasiModel {
  final int    idNotifikasi;
  final int    idUser;
  final String? nikAnak;
  final String pesan;
  final String tglKirim;
  final String status;
  final String jenisNotif;

  NotifikasiModel({
    required this.idNotifikasi,
    required this.idUser,
    this.nikAnak,
    required this.pesan,
    required this.tglKirim,
    required this.status,
    required this.jenisNotif,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) =>
      NotifikasiModel(
        idNotifikasi: json['id_notifikasi'] as int,
        idUser:       json['id_user'] as int,
        nikAnak:      json['nik_anak'] as String?,
        pesan:        json['pesan'] as String,
        tglKirim:     json['tgl_kirim'] as String,
        status:       json['status'] as String,
        jenisNotif:   json['jenis_notif'] as String? ?? 'Umum',
      );

  bool get isBelumDibaca => status == 'Belum Dibaca';

  // Icon per jenis notifikasi
  String get jenisLabel {
    return switch (jenisNotif) {
      'Posyandu'  => 'Jadwal Posyandu',
      'Imunisasi' => 'Imunisasi',
      'Pemeriksaan' => 'Pemeriksaan',
      _           => 'Informasi',
    };
  }
}