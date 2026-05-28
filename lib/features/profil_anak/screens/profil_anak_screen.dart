import 'package:flutter/material.dart';

class ProfilAnakScreen extends StatelessWidget {
  // Menerima data riil anak hasil parsing dari API Laravel via profil_ortu_screen
  final Map<String, dynamic> dataAnakAsli;

  const ProfilAnakScreen({
    Key? key,
    required this.dataAnakAsli,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parsing data dari map backend secara dinamis agar data menyesuaikan anak yang dipilih
    final String namaAnak = dataAnakAsli['nama_anak'] ?? dataAnakAsli['nama'] ?? 'Tanpa Nama';
    final String umurAnak = dataAnakAsli['umur_format'] ?? 'Umur belum diisi';
    final String nik = dataAnakAsli['nik'] ?? '-';
    final String jenisKelamin = dataAnakAsli['jenis_kelamin'] ?? 'Laki-laki';
    final String tanggalLahir = dataAnakAsli['tanggal_lahir'] ?? '-';
    final String namaIbu = dataAnakAsli['nama_ibu'] ?? '-';
    final String namaAyah = dataAnakAsli['nama_ayah'] ?? '-';
    final String alamat = dataAnakAsli['alamat'] ?? '-';
    final String? fotoUrl = dataAnakAsli['foto_url'];

    // Cek jender adaptif untuk ikon status visual
    final bool isLakiLaki = jenisKelamin.toLowerCase() == 'laki-laki' || jenisKelamin.toLowerCase() == 'l';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF006699)),
        title: const Text(
          'Profil Anak',
          style: TextStyle(
            color: Color(0xFF006699),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF006699)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP PROFILE SECTION (PERSIS MOCK-UP KARTU MELENGKUNG)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32), // Sudut melengkung halus sesuai gambar
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isLakiLaki ? const Color(0xFF0284C7) : Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: const Color(0xFFE2E8F0),
                          backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
                          child: fotoUrl == null
                              ? Icon(
                                  isLakiLaki ? Icons.face : Icons.face_3,
                                  size: 55,
                                  color: const Color(0xFF94A3B8),
                                )
                              : null,
                        ),
                      ),
                      // Ikon Edit Kecil Biru di Lingkaran Foto
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0284C7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 12, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Render Nama Anak Dinamis
                  Text(
                    namaAnak,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Render Umur Anak Dinamis dengan Badge Melengkung Biru Muda
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.scale, size: 14, color: Color(0xFF0284C7)),
                        const SizedBox(width: 6),
                        Text(
                          umurAnak,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 2. DATA ANAK HEADER SECTION
            const Text(
              'DATA ANAK',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            // TILE NIK (Persis gambar pakai Box abu-abu muda lembut)
            _buildDataTile(
              icon: Icons.fingerprint,
              title: 'NIK',
              value: nik,
            ),
            const SizedBox(height: 12),

            // ROW GRID HALF (JENIS KELAMIN & TANGGAL LAHIR BERDAMPINGAN)
            Row(
              children: [
                Expanded(
                  child: _buildGridDataTile(
                    icon: isLakiLaki ? Icons.male : Icons.female,
                    title: 'JENIS KELAMIN',
                    value: jenisKelamin,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridDataTile(
                    icon: Icons.calendar_month,
                    title: 'TANGGAL LAHIR',
                    value: tanggalLahir,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. DATA ORANG TUA HEADER SECTION
            const Text(
              'DATA ORANG TUA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            // BOX NAMA IBU & NAMA AYAH BERDAMPINGAN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: Color(0xFF0284C7), size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NAMA IBU', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(namaIbu, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // TILE ALAMAT
            _buildDataTile(
              icon: Icons.location_on_outlined,
              title: 'ALAMAT',
              value: alamat,
            ),
            const SizedBox(height: 36),

            // 4. ACTION BUTTONS (EDIT DATA & UBAH FOTO PROFIL)
            ElevatedButton.icon(
              onPressed: () {
                // Navigasi ke Form Edit Profil Anak jika ditekan
              },
              icon: const Icon(Icons.edit_note, size: 20, color: Colors.white),
              label: const Text('Edit Data Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006192), // Biru gelap tegas sesuai gambar
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                // Aksi ganti foto dengan ImagePicker
              },
              icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xFF475569)),
              label: const Text('Ubah Foto Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2E8F0), // Abu netral soft pas dengan gambar mock-up
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builder Item Memanjang (NIK, Alamat)
  Widget _buildDataTile({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0284C7), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builder Item Box Grid Setengah (Jenis Kelamin & Tanggal Lahir)
  Widget _buildGridDataTile({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0284C7), size: 22),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
        ],
      ),
    );
  }
}