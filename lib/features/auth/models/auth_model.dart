// lib/features/auth/models/auth_model.dart

// ── Model Posyandu (untuk dropdown login Kader) ───────────
class PosyanduItem {
  final int    idPosyandu;
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
    idPosyandu:    json['id_posyandu'] as int,
    namaPosyandu:  json['nama_posyandu'] as String,
    desaKelurahan: json['desa_kelurahan'] as String? ?? '',
    kecamatan:     json['kecamatan'] as String? ?? '',
    kabupatenKota: json['kabupaten_kota'] as String? ?? '',
  );
}

// ── Model User yang sedang login ──────────────────────────
class AuthUser {
  final int     idUser;
  final String  role;
  final String? token;
  final String? username;

  // Profil Bidan
  final String? nip;
  final String? namaBidan;
  final String? noTelp;

  // Profil Kader
  final String? namaKader;

  // Profil OrangTua
  final String? namaAyah;
  final String? namaIbu;
  final String? nikOrangTua;
  final String? alamat;

  // Posyandu
  final int?    idPosyandu;
  final String? namaPosyandu;

  AuthUser({
    required this.idUser,
    required this.role,
    this.token,
    this.username,
    this.nip,
    this.namaBidan,
    this.noTelp,
    this.namaKader,
    this.namaIbu,
    this.namaAyah,
    this.nikOrangTua,
    this.alamat,
    this.idPosyandu,
    this.namaPosyandu,
  });

  bool get isKader    => role == 'Kader';
  bool get isBidan    => role == 'Bidan';
  bool get isOrangTua => role == 'OrangTua';

  String get displayName {
    if (isKader)    return namaKader ?? namaPosyandu ?? 'Kader';
    if (isBidan)    return namaBidan ?? 'Bidan';
    if (isOrangTua) return namaIbu ?? 'Orang Tua';
    return 'Pengguna';
  }

  /// Parse dari response login Kader/Bidan
  factory AuthUser.fromLoginResponse(Map<String, dynamic> data) {
    final profil = data['profil'] as Map<String, dynamic>?;
    final role   = data['role'] as String;

    // Support dua format:
    // Kader  → data['posyandu']       (nama_posyandu langsung)
    // Bidan  → data['posyandu_aktif'] (nama_posyandu)
    final posyandu = (data['posyandu_aktif'] ?? data['posyandu'])
        as Map<String, dynamic>?;

    return AuthUser(
      idUser:       data['id_user'] as int,
      role:         role,
      token:        data['token'] as String?,
      username:     data['username'] as String?,
      nip:          profil?['nip'] as String?,
      namaBidan:    profil?['nama_bidan'] as String? ?? profil?['nama'] as String?,
      noTelp:       profil?['no_telp'] as String?,
      namaKader:    role == 'Kader' ? (profil?['nama'] as String?) : null,
      idPosyandu:   posyandu?['id_posyandu'] as int?,
      namaPosyandu: posyandu?['nama_posyandu'] as String?,
    );
  }

  /// Parse dari response login OrangTua
  factory AuthUser.fromOrangTuaResponse(Map<String, dynamic> data) {
  final profil = data['profil'] as Map<String, dynamic>?;
  return AuthUser(
    idUser:      data['id_user'] as int,
    role:        'OrangTua',
    token:       data['token'] as String?,
    username:    data['username'] as String?,
    namaIbu:     profil?['nama_ibu'] as String?,       // ← nama_ibu
    namaAyah: profil?['nama_ayah'] as String?,
    nikOrangTua: profil?['nik_orang_tua'] as String?,  // ← nik_orang_tua
    alamat:      profil?['alamat'] as String?,          // ← alamat
  );
}
}