// lib/features/auth/domain/entities/auth_entity.dart
// VERSI TERBARU — ganti file lama

class AuthEntity {
  final String token;
  final PenggunaEntity pengguna;

  const AuthEntity({
    required this.token,
    required this.pengguna,
  });
}

class PenggunaEntity {
  final int idUser;
  final String username;
  final String role;
  final int? idPosyandu;       // ← BARU
  final ProfilEntity? profil;

  const PenggunaEntity({
    required this.idUser,
    required this.username,
    required this.role,
    this.idPosyandu,
    this.profil,
  });

  bool get isSuperAdmin => role == 'SuperAdmin'; // ← BARU
  bool get isBidan      => role == 'Bidan';
  bool get isKader      => role == 'Kader';
  bool get isOrangTua   => role == 'OrangTua';
}

class ProfilEntity {
  final String nama;
  final String? nip;
  final String? noTelp;
  final int? idKader;
  final String? wilayah;
  final String? nikOrangTua;
  final String? alamat;

  const ProfilEntity({
    required this.nama,
    this.nip,
    this.noTelp,
    this.idKader,
    this.wilayah,
    this.nikOrangTua,
    this.alamat,
  });
}

class AnakLoginEntity {
  final String nikAnak;
  final String namaAnak;
  final DateTime tglLahir;
  final String jenisKelamin;
  final int? umurBulan;

  const AnakLoginEntity({
    required this.nikAnak,
    required this.namaAnak,
    required this.tglLahir,
    required this.jenisKelamin,
    this.umurBulan,
  });
}