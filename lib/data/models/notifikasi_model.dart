// lib/data/models/notifikasi_model.dart

class NotifikasiModel {
  final int idNotifikasi;
  final int idUser;
  final String? nikAnak;
  final String pesan;
  final DateTime tglKirim;
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

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      idNotifikasi: json['id_notifikasi'] as int,
      idUser:       json['id_user'] as int,
      nikAnak:      json['nik_anak'] as String?,
      pesan:        json['pesan'] as String,
      tglKirim:     DateTime.parse(json['tgl_kirim'] as String),
      status:       json['status'] as String,
      jenisNotif:   json['jenis_notif'] as String,
    );
  }

  bool get isBelumDibaca => status == 'Belum Dibaca';
}