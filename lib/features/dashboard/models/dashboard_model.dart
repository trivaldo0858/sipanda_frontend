// lib/features/dashboard/models/dashboard_model.dart

// ── Dashboard Kader ───────────────────────────────────────
class DashboardKader {
  final int totalBalita;
  final int pemeriksaanBulanIni;
  final JadwalTerdekat? jadwalTerdekat;
  final List<AktivitasTerbaru> aktivitasTerbaru;
  final String namaPosyandu;

  DashboardKader({
    required this.totalBalita,
    required this.pemeriksaanBulanIni,
    this.jadwalTerdekat,
    required this.aktivitasTerbaru,
    required this.namaPosyandu,
  });

  factory DashboardKader.fromJson(Map<String, dynamic> json) {
    final jadwal = json['jadwal_terdekat'];
    return DashboardKader(
      totalBalita: json['total_balita'] as int? ?? 0,
      pemeriksaanBulanIni: json['pemeriksaan_bulan_ini'] as int? ?? 0,
      namaPosyandu: json['nama_posyandu'] as String? ?? '',
      jadwalTerdekat: jadwal != null ? JadwalTerdekat.fromJson(jadwal) : null,
      aktivitasTerbaru: (json['aktivitas_terbaru'] as List? ?? [])
          .map((e) => AktivitasTerbaru.fromJson(e))
          .toList(),
    );
  }
}

class JadwalTerdekat {
  final int idJadwal;
  final String tglKegiatan;
  final String lokasi;
  final String? agenda;

  JadwalTerdekat({
    required this.idJadwal,
    required this.tglKegiatan,
    required this.lokasi,
    this.agenda,
  });

  factory JadwalTerdekat.fromJson(Map<String, dynamic> json) => JadwalTerdekat(
        idJadwal: json['id_jadwal'] as int,
        tglKegiatan: json['tgl_kegiatan'] as String,
        lokasi: json['lokasi'] as String,
        agenda: json['agenda'] as String?,
      );
}

class AktivitasTerbaru {
  final String nikAnak;
  final String namaAnak;
  final String tglPeriksa;
  final double? beratBadan;
  final double? tinggiBadan;
  final String statusValidasi;

  AktivitasTerbaru({
    required this.nikAnak,
    required this.namaAnak,
    required this.tglPeriksa,
    this.beratBadan,
    this.tinggiBadan,
    required this.statusValidasi,
  });

  factory AktivitasTerbaru.fromJson(Map<String, dynamic> json) =>
      AktivitasTerbaru(
        nikAnak: json['nik_anak'] as String,
        namaAnak: json['nama_anak'] as String,
        tglPeriksa: json['tgl_periksa'] as String,
        beratBadan: (json['berat_badan'] as num?)?.toDouble(),
        tinggiBadan: (json['tinggi_badan'] as num?)?.toDouble(),
        statusValidasi: json['status_validasi'] as String? ?? 'Menunggu',
      );
}

// ── Dashboard Bidan ───────────────────────────────────────
class DashboardBidan {
  final int balitaPerluImunisasi;
  final int imunisasiBulanIni;
  final int pemeriksaanMenungguValidasi;
  final List<AktivitasImunisasi> aktivitasImunisasi;

  DashboardBidan({
    required this.balitaPerluImunisasi,
    required this.imunisasiBulanIni,
    required this.pemeriksaanMenungguValidasi,
    required this.aktivitasImunisasi,
  });

  factory DashboardBidan.fromJson(Map<String, dynamic> json) => DashboardBidan(
        balitaPerluImunisasi:
            json['balita_perlu_imunisasi'] as int? ?? 0,
        imunisasiBulanIni: json['imunisasi_bulan_ini'] as int? ?? 0,
        pemeriksaanMenungguValidasi:
            json['pemeriksaan_menunggu_validasi'] as int? ?? 0,
        aktivitasImunisasi:
            (json['aktivitas_imunisasi'] as List? ?? [])
                .map((e) => AktivitasImunisasi.fromJson(e))
                .toList(),
      );
}

class AktivitasImunisasi {
  final String nikAnak;
  final String namaAnak;
  final String namaVaksin;
  final String tglPemberian;

  AktivitasImunisasi({
    required this.nikAnak,
    required this.namaAnak,
    required this.namaVaksin,
    required this.tglPemberian,
  });

  factory AktivitasImunisasi.fromJson(Map<String, dynamic> json) =>
      AktivitasImunisasi(
        nikAnak: json['nik_anak'] as String,
        namaAnak: json['nama_anak'] as String,
        namaVaksin: json['nama_vaksin'] as String,
        tglPemberian: json['tgl_pemberian'] as String,
      );
}

// ── Dashboard Orang Tua ───────────────────────────────────
class DashboardOrtu {
  final List<InfoAnak> daftarAnak;
  final JadwalTerdekat? jadwalTerdekat;
  final int notifikasiUnread;

  DashboardOrtu({
    required this.daftarAnak,
    this.jadwalTerdekat,
    required this.notifikasiUnread,
  });

  factory DashboardOrtu.fromJson(Map<String, dynamic> json) => DashboardOrtu(
        daftarAnak: (json['daftar_anak'] as List? ?? [])
            .map((e) => InfoAnak.fromJson(e))
            .toList(),
        jadwalTerdekat: json['jadwal_terdekat'] != null
            ? JadwalTerdekat.fromJson(json['jadwal_terdekat'])
            : null,
        notifikasiUnread: json['notifikasi_unread'] as int? ?? 0,
      );
}

class InfoAnak {
  final String nikAnak;
  final String namaAnak;
  final String tglLahir;
  final String jenisKelamin;
  final int umurBulan;
  final double? beratTerakhir;
  final double? tinggiTerakhir;
  final double? lingkarTerakhir;

  InfoAnak({
    required this.nikAnak,
    required this.namaAnak,
    required this.tglLahir,
    required this.jenisKelamin,
    required this.umurBulan,
    this.beratTerakhir,
    this.tinggiTerakhir,
    this.lingkarTerakhir,

  });

  factory InfoAnak.fromJson(Map<String, dynamic> json) => InfoAnak(
        nikAnak: json['nik_anak'] as String,
        namaAnak: json['nama_anak'] as String,
        tglLahir: json['tgl_lahir'] as String,
        jenisKelamin: json['jenis_kelamin'] as String,
        umurBulan: json['umur_bulan'] as int? ?? 0,
        beratTerakhir: (json['berat_terakhir'] as num?)?.toDouble(),
        tinggiTerakhir: (json["tinggi_terakhir"] as num?)?.toDouble(),
        lingkarTerakhir:(json["lingkar_terakhir"] as num?)?.toDouble(),
      );

  String get umurFormat {
    if (umurBulan < 12) return '$umurBulan bulan';
    final tahun = umurBulan ~/ 12;
    final bulan = umurBulan % 12;
    return bulan == 0 ? '$tahun tahun' : '$tahun tahun $bulan bulan';
  }
}