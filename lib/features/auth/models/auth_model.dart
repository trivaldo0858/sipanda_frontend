// lib/features/auth/models/auth_model.dart

// ── Model Posyandu (untuk dropdown login Kader) ───────────
class PosyanduItem {
  final int idPosyandu;
  final String namaPosyandu;
  final String desaKelurahan;
  final String kecamatan;
  final String kabupatenKota;

  PosyanduItem({
    required this.idPosyandu,
    required this.namaPosyandu,
    required this.desaKelurahan,
    required this.kecamatan,
    required this.kabupatenKota,
  });

  factory PosyanduItem.fromJson(Map<String, dynamic> json) => PosyanduItem(
        idPosyandu: json['id_posyandu'] as int,
        namaPosyandu: json['nama_posyandu'] as String,
        desaKelurahan: json['desa_kelurahan'] as String? ?? '',
        kecamatan: json['kecamatan'] as String? ?? '',
        kabupatenKota: json['kabupaten_kota'] as String? ?? '',
      );
}

// ── Model User yang sedang login ─────────────────────────
class AuthUser {
  final int idUser;
  final String role; // Kader | Bidan | OrangTua
  final String? token;

  // Data posyandu (Kader & Bidan)
  final int? idPosyandu;
  final String? namaPosyandu;

  // Data profil Bidan
  final String? nip;
  final String? namaBidan;
  final String? noTelp;

  // Data profil OrangTua
  final String? nikOrangTua;
  final String? namaIbu;

  AuthUser({
    required this.idUser,
    required this.role,
    this.token,
    this.idPosyandu,
    this.namaPosyandu,
    this.nip,
    this.namaBidan,
    this.noTelp,
    this.nikOrangTua,
    this.namaIbu,
  });

  bool get isKader    => role == 'Kader';
  bool get isBidan    => role == 'Bidan';
  bool get isOrangTua => role == 'OrangTua';

  /// Parse dari response loginKader
  factory AuthUser.fromKaderResponse(Map<String, dynamic> data) {
    final posyandu = data['posyandu'] as Map<String, dynamic>?;
    return AuthUser(
      idUser: data['id_user'] as int,
      role: 'Kader',
      token: data['token'] as String?,
      idPosyandu: posyandu?['id_posyandu'] as int?,
      namaPosyandu: posyandu?['nama_posyandu'] as String?,
    );
  }

  /// Parse dari response loginBidan
  factory AuthUser.fromBidanResponse(Map<String, dynamic> data) {
    final profil   = data['profil']   as Map<String, dynamic>?;
    final posyandu = data['posyandu'] as Map<String, dynamic>?;
    return AuthUser(
      idUser: data['id_user'] as int,
      role: 'Bidan',
      token: data['token'] as String?,
      nip: profil?['nip'] as String?,
      namaBidan: profil?['nama_bidan'] as String?,
      noTelp: profil?['no_telp'] as String?,
      idPosyandu: posyandu?['id_posyandu'] as int?,
      namaPosyandu: posyandu?['nama_posyandu'] as String?,
    );
  }

  /// Parse dari response loginOrangTua
  factory AuthUser.fromOrangTuaResponse(Map<String, dynamic> data) {
    final profil = data['profil'] as Map<String, dynamic>?;
    return AuthUser(
      idUser: data['id_user'] as int,
      role: 'OrangTua',
      token: data['token'] as String?,
      nikOrangTua: profil?['nik_orang_tua'] as String?,
      namaIbu: profil?['nama_ibu'] as String?,
    );
  }

  /// Nama tampilan di UI
  String get displayName {
    if (isKader)    return namaPosyandu ?? 'Kader';
    if (isBidan)    return namaBidan ?? 'Bidan';
    if (isOrangTua) return namaIbu ?? 'Orang Tua';
    return 'Pengguna';
  }
}