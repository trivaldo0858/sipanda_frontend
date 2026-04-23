// lib/core/constants/api_constants.dart
// VERSI TERBARU — ganti file lama dengan ini

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://103.174.237.196:8082/api/v1';

  // ── Auth ──────────────────────────────────────────────────────────
  static const String login         = '/auth/login';
  static const String loginOrangTua = '/auth/login-ortu';   // ← BARU
  static const String loginGoogle   = '/auth/login-google';
  static const String logout        = '/auth/logout';
  static const String me            = '/auth/me';
  static const String ubahPassword  = '/auth/ubah-password';

  // ── Dashboard ─────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';

  // ── Anak ──────────────────────────────────────────────────────────
  static const String anak = '/anak';
  static String anakDetail(String nik)       => '/anak/$nik';
  static String anakPerkembangan(String nik) => '/anak/$nik/perkembangan';

  // ── Pemeriksaan ───────────────────────────────────────────────────
  static const String pemeriksaan         = '/pemeriksaan';
  static String pemeriksaanDetail(int id) => '/pemeriksaan/$id';

  // ── Imunisasi ─────────────────────────────────────────────────────
  static const String imunisasi         = '/imunisasi';
  static String imunisasiDetail(int id) => '/imunisasi/$id';

  // ── Jadwal ────────────────────────────────────────────────────────
  static const String jadwal         = '/jadwal';
  static String jadwalDetail(int id) => '/jadwal/$id';

  // ── Vaksin ────────────────────────────────────────────────────────
  static const String vaksin         = '/vaksin';
  static String vaksinDetail(int id) => '/vaksin/$id';

  // ── Laporan ───────────────────────────────────────────────────────
  static const String laporan               = '/laporan';
  static String laporanDetail(int id)       => '/laporan/$id';
  static String laporanExportPdf(int id)    => '/laporan/$id/export-pdf';    // ← BARU
  static String laporanExportExcel(int id)  => '/laporan/$id/export-excel';  // ← BARU

  // ── Notifikasi ────────────────────────────────────────────────────
  static const String notifikasi        = '/notifikasi';
  static String notifRead(int id)       => '/notifikasi/$id/read';
  static const String notifMarkAllRead  = '/notifikasi/mark-all-read';
  static String notifDelete(int id)     => '/notifikasi/$id';

  // ── Pengguna ──────────────────────────────────────────────────────
  static const String pengguna         = '/pengguna';
  static String penggunaDetail(int id) => '/pengguna/$id';
}