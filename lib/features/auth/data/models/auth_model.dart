// lib/features/auth/data/models/auth_model.dart
//
// DATA LAYER — Model
// ✅ Extends Entity dari Domain Layer
// ✅ Tambahan: fromJson / toJson untuk parsing API
// ✅ Domain Layer tidak perlu tahu soal JSON

import '../../domain/entities/auth_entity.dart';

// ── AuthModel ─────────────────────────────────────────────────────────
class AuthModel extends AuthEntity {
  const AuthModel({
    required super.token,
    required super.pengguna,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token:    json['token'] as String,
      pengguna: PenggunaModel.fromJson(json),
    );
  }
}

// ── PenggunaModel ─────────────────────────────────────────────────────
class PenggunaModel extends PenggunaEntity {
  const PenggunaModel({
    required super.idUser,
    required super.username,
    required super.role,
    super.profil,
  });

  factory PenggunaModel.fromJson(Map<String, dynamic> json) {
    return PenggunaModel(
      idUser:   json['id_user'] as int,
      username: json['username'] as String,
      role:     json['role'] as String,
      profil:   json['profil'] != null
                  ? ProfilModel.fromJson(
                      json['profil'] as Map<String, dynamic>,
                    )
                  : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_user':  idUser,
    'username': username,
    'role':     role,
  };
}

// ── ProfilModel ───────────────────────────────────────────────────────
class ProfilModel extends ProfilEntity {
  const ProfilModel({
    required super.nama,
    super.nip,
    super.noTelp,
    super.idKader,
    super.wilayah,
    super.nikOrangTua,
    super.alamat,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
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

// ── AnakLoginModel ────────────────────────────────────────────────────
class AnakLoginModel extends AnakLoginEntity {
  const AnakLoginModel({
    required super.nikAnak,
    required super.namaAnak,
    required super.tglLahir,
    required super.jenisKelamin,
    super.umurBulan,
  });

  factory AnakLoginModel.fromJson(Map<String, dynamic> json) {
    return AnakLoginModel(
      nikAnak:      json['nik_anak'] as String,
      namaAnak:     json['nama_anak'] as String,
      tglLahir:     DateTime.parse(json['tgl_lahir'] as String),
      jenisKelamin: json['jenis_kelamin'] as String,
      umurBulan:    json['umur_bulan'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nik_anak':      nikAnak,
    'nama_anak':     namaAnak,
    'tgl_lahir':     tglLahir.toIso8601String().split('T').first,
    'jenis_kelamin': jenisKelamin,
    'umur_bulan':    umurBulan,
  };
}