// lib/data/models/pengguna_model.dart

class PenggunaModel {
  final int idUser;
  final String username;
  final String role;
  final ProfilModel? profil;

  PenggunaModel({
    required this.idUser,
    required this.username,
    required this.role,
    this.profil,
  });

  factory PenggunaModel.fromJson(Map<String, dynamic> json) {
    return PenggunaModel(
      idUser:   json['id_user'] as int,
      username: json['username'] as String,
      role:     json['role'] as String,
      profil:   json['profil'] != null
                  ? ProfilModel.fromJson(json['profil'] as Map<String, dynamic>, json['role'] as String)
                  : null,
    );
  }

  bool get isBidan    => role == 'Bidan';
  bool get isKader    => role == 'Kader';
  bool get isOrangTua => role == 'OrangTua';
}

// ── Profil dinamis sesuai role ────────────────────────────────────────
class ProfilModel {
  // Bidan
  final String? nip;
  final String? noTelp;
  // Kader
  final int? idKader;
  final String? wilayah;
  // OrangTua
  final String? nikOrangTua;
  final String? alamat;
  // Shared
  final String nama;

  ProfilModel({
    required this.nama,
    this.nip,
    this.noTelp,
    this.idKader,
    this.wilayah,
    this.nikOrangTua,
    this.alamat,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json, String role) {
    return ProfilModel(
      nama:        json['nama'] as String? ?? '',
      nip:         json['nip'] as String?,
      noTelp:      json['no_telp'] as String?,
      idKader:     json['id_kader'] as int?,
      wilayah:     json['wilayah'] as String?,
      nikOrangTua: json['nik'] as String?,
      alamat:      json['alamat'] as String?,
    );
  }
}

// ── Auth Response (login) ─────────────────────────────────────────────
class AuthResponse {
  final String token;
  final PenggunaModel pengguna;

  AuthResponse({required this.token, required this.pengguna});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token:    json['token'] as String,
      pengguna: PenggunaModel.fromJson(json),
    );
  }
}