// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  // Emulator Android  : http://10.0.2.2:8000
  // Device fisik      : http://192.168.x.x:8000
  // Production        : https://yourdomain.com
static const String baseUrl = 'http://10.0.167.29:8000/api/v1';  
  // ── Auth ──────────────────────────────────────────
  static const String loginKader    = '/auth/login/kader';
  static const String loginBidan    = '/auth/login/bidan';
  static const String loginOrangTua = '/auth/login/orang-tua';
  static const String logout        = '/auth/logout';
  static const String me            = '/auth/me';
  static const String ubahPassword      = '/auth/ubah-password';
  static const String ubahPasswordKader = '/auth/ubah-password-kader';

  // ── Posyandu (public) ─────────────────────────────
  static const String posyanduList  = '/posyandu/list';
  static const String posyanduProfil = '/posyandu/profil';
  static String posyanduDetail(int id) => '/posyandu/$id';

  // ── Dashboard ─────────────────────────────────────
  static const String dashboard = '/dashboard';

  // ── Anak ──────────────────────────────────────────
  static const String anak = '/anak';
  static String anakDetail(String nik)       => '/anak/$nik';
  static String anakUpdate(String nik)       => '/anak/$nik';
  static String anakDelete(String nik)       => '/anak/$nik';
  static String anakPerkembangan(String nik) => '/anak/$nik/perkembangan';

  // ── Pemeriksaan ───────────────────────────────────
  static const String pemeriksaan = '/pemeriksaan';
  static String pemeriksaanDetail(int id)   => '/pemeriksaan/$id';
  static String pemeriksaanUpdate(int id)   => '/pemeriksaan/$id';
  static String pemeriksaanDelete(int id)   => '/pemeriksaan/$id';
  static String pemeriksaanValidasi(int id) => '/pemeriksaan/$id/validasi';

  // ── Imunisasi ─────────────────────────────────────
  static const String imunisasi           = '/imunisasi';
  static const String imunisasiJenisVaksin = '/imunisasi/jenis-vaksin';
  static String imunisasiDetail(int id)   => '/imunisasi/$id';
  static String imunisasiUpdate(int id)   => '/imunisasi/$id';
  static String imunisasiDelete(int id)   => '/imunisasi/$id';
  static String imunisasiRiwayat(String nik) => '/imunisasi/riwayat/$nik';

  // ── Jadwal Posyandu ───────────────────────────────
  static const String jadwal = '/jadwal';
  static String jadwalDetail(int id) => '/jadwal/$id';
  static String jadwalUpdate(int id) => '/jadwal/$id';
  static String jadwalDelete(int id) => '/jadwal/$id';

  // ── Laporan ───────────────────────────────────────
  static const String laporan = '/laporan';
  static String laporanDetail(int id)      => '/laporan/$id';
  static String laporanDelete(int id)      => '/laporan/$id';
  static String laporanExportPdf(int id)   => '/laporan/$id/export-pdf';
  static String laporanExportExcel(int id) => '/laporan/$id/export-excel';

  // ── Notifikasi ────────────────────────────────────
  static const String notifikasi          = '/notifikasi';
  static const String notifUnreadCount    = '/notifikasi/unread-count';
  static const String notifMarkAllRead    = '/notifikasi/mark-all-read';
  static String notifRead(int id)         => '/notifikasi/$id/read';
  static String notifDelete(int id)       => '/notifikasi/$id';
}