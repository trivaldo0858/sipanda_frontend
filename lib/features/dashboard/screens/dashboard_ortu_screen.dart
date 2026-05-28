// lib/features/dashboard/screens/dashboard_ortu_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../kms/services/kms_service.dart';
import '../../kms/models/kms_model.dart';
import '../../imunisasi/services/imunisasi_service.dart';
import '../../imunisasi/models/imunisasi_model.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class DashboardOrtuScreen extends StatefulWidget {
  const DashboardOrtuScreen({super.key});
  @override
  State<DashboardOrtuScreen> createState() => _DashboardOrtuScreenState();
}

class _DashboardOrtuScreenState extends State<DashboardOrtuScreen> {
  int _currentIndex = 0;

  // State lokal interaktif untuk menampung perubahan input edit data profil
  String? _customNamaAnak;
  String? _customAlamat;

  static const Color _primary     = Color(0xFF0D6EFD);
  static const Color _primaryDark = Color(0xFF0A58CA);
  static const Color _textDark    = Color(0xFF1E293B);
  static const Color _textGrey    = Color(0xFF64748B);
  static const Color _background  = Color(0xFFF7F9FC);
  static const Color _cardWhite   = Color(0xFFFFFFFF);
  static const Color _border      = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadOrtu();
    });
  }

  String _formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('d MMM yyyy', 'id_ID').format(dt);
    } catch (_) { return tgl; }
  }

  // Fungsi pembantu interaktif untuk memunculkan Modal Bottom Sheet Form Pengeditan
  void _bukaModalEditProfil(String namaSekarang, String alamatSekarang) {
    final TextEditingController namaEditController = TextEditingController(text: namaSekarang);
    final TextEditingController alamatEditController = TextEditingController(text: alamatSekarang);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              const Text('Edit Data Profil Anak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
              const SizedBox(height: 20),
              TextField(
                controller: namaEditController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Anak',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.face_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: alamatEditController,
                decoration: InputDecoration(
                  labelText: 'Alamat Tinggal',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _customNamaAnak = namaEditController.text;
                    _customAlamat = alamatEditController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil anak berhasil diubah secara lokal!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006192),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildBerandaTab(),
            _buildHistoryTab(),
            _buildProfilTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: _cardWhite,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: _primary,
        unselectedItemColor: _textGrey,
        backgroundColor: _cardWhite,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            activeIcon: Icon(Icons.history_edu_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // BERANDA TAB
  // ══════════════════════════════════════════════════════
  Widget _buildBerandaTab() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          color: _primary,
          onRefresh: () => provider.loadOrtu(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar()),
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: _primary)),
                )
              else if (provider.status == DashboardStatus.error)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(provider.errorMessage ?? 'Gagal memuat',
                            style: const TextStyle(color: _textGrey)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: provider.loadOrtu, child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ...(provider.ortuData?.daftarAnak ?? []).map((a) => _buildAnakSection(a)),
                      const SizedBox(height: 24),
                      _buildJadwalSection(provider.ortuData?.jadwalTerdekat),
                    ]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final unread = provider.ortuData?.notifikasiUnread ?? 0;
        return Container(
          color: _cardWhite,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: _primary, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('SIPANDA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: _primary, letterSpacing: 0.5)),
              const Spacer(),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.push('/notifikasi'),
                    icon: const Icon(Icons.notifications_outlined, color: _textDark, size: 24),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(
                            color: Color(0xFFDC3545), shape: BoxShape.circle),
                        child: Center(
                          child: Text('$unread',
                              style: const TextStyle(fontSize: 10,
                                  color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnakSection(InfoAnak anak) {
    return Column(
      children: [
        // KARTU 1: Profil Anak
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('PROFIL ANAK',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: _primary, letterSpacing: 1)),
              ),
              const SizedBox(height: 12),
              Text(anak.namaAnak,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textDark)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.fingerprint_rounded, size: 16, color: _textGrey),
                const SizedBox(width: 6),
                Text('NIK:${anak.nikAnak}',
                    style: const TextStyle(fontSize: 13, color: _textGrey)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.cake_outlined, size: 16, color: _textGrey),
                const SizedBox(width: 6),
                Text(anak.umurFormat,
                    style: const TextStyle(fontSize: 13, color: _textGrey)),
              ]),
            ],
          ),
        ),

        // KARTU 2: Data Terakhir
        if (anak.beratTerakhir != null || anak.tinggiTerakhir != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Data Terakhir',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
                    Text('Update: ${_formatTanggal(anak.tglLahir)}',
                        style: const TextStyle(fontSize: 11, color: _textGrey)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(children: [
                  if (anak.beratTerakhir != null)
                    Expanded(child: _buildMetrikCard(
                      icon: Icons.monitor_weight_outlined,
                      label: 'BERAT BADAN',
                      value: '${anak.beratTerakhir}',
                      unit: 'kg',
                    )),
                  if (anak.beratTerakhir != null && anak.tinggiTerakhir != null)
                    const SizedBox(width: 12),
                  if (anak.tinggiTerakhir != null)
                    Expanded(child: _buildMetrikCard(
                      icon: Icons.straighten_outlined,
                      label: 'TINGGI BADAN',
                      value: '${anak.tinggiTerakhir}',
                      unit: 'cm',
                    )),
                ]),
                if (anak.lingkarTerakhir != null) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildMetrikCard(
                      icon: Icons.radio_button_checked_outlined,
                      label: 'LINGKAR KEPALA',
                      value: '${anak.lingkarTerakhir}',
                      unit: 'cm',
                    )),
                    const Expanded(child: SizedBox()),
                  ]),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/kms/${anak.nikAnak}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Text('Lihat Detail',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    label: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetrikCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: _textGrey),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: _textGrey, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(children: [
              TextSpan(text: value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _primary)),
              TextSpan(text: ' $unit',
                  style: const TextStyle(fontSize: 13, color: _textGrey)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalSection(JadwalTerdekat? jadwal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jadwal Terdekat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 12),
        jadwal == null
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: const Center(
                  child: Text('Belum ada jadwal posyandu',
                      style: TextStyle(color: _textGrey)),
                ),
              )
            : _buildJadwalCard(jadwal),
      ],
    );
  }

  Widget _buildJadwalCard(JadwalTerdekat jadwal) {
    DateTime? dt;
    try { dt = DateTime.parse(jadwal.tglKegiatan); } catch (_) {}
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFD7FF)),
      ),
      child: Row(
        children: [
          if (dt != null)
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)),
              child: Column(children: [
                Text(DateFormat('MMM').format(dt).toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(dt.day.toString(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                        color: Colors.white, height: 1.1)),
              ]),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(jadwal.lokasi,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
                if (jadwal.agenda != null) ...[
                  const SizedBox(height: 2),
                  Text(jadwal.agenda!, style: const TextStyle(fontSize: 12, color: _textGrey)),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFD7FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: _primary),
                      const SizedBox(width: 4),
                      Text(jadwal.lokasi.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: _primary, letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // HISTORY TAB
  // ══════════════════════════════════════════════════════
  Widget _buildHistoryTab() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final daftarAnak = provider.ortuData?.daftarAnak ?? [];
        if (daftarAnak.isEmpty) {
          return const Center(
            child: Text('Belum ada data anak', style: TextStyle(color: _textGrey)),
          );
        }
        final anak = daftarAnak.first;
        return _HistoryTabContent(nikAnak: anak.nikAnak, namaAnak: anak.namaAnak);
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // PROFIL TAB 
  // ══════════════════════════════════════════════════════
  Widget _buildProfilTab() {
    return Consumer2<AuthProvider, DashboardProvider>(
      builder: (context, auth, dashboardProvider, _) {
        if (dashboardProvider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF006699)));
        }

        final listAnak = dashboardProvider.ortuData?.daftarAnak ?? [];

        if (listAnak.isEmpty) {
          return const Center(
            child: Text('Belum ada data anak terdaftar di database Laravel.', style: TextStyle(color: _textGrey)),
          );
        }

        final anakUtama = listAnak.first;
        
       
        final String namaAnak = _customNamaAnak ?? anakUtama.namaAnak;
        final String umurAnak = anakUtama.umurFormat;
        final String nik = anakUtama.nikAnak;
        final String tanggalLahir = _formatTanggal(anakUtama.tglLahir);
        
        final String namaIbu = auth.user?.namaIbu ?? 'adel';
        final String alamat = _customAlamat ?? 'Jl. Melati No. 12, Bandung';
        

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'Profil Anak',
              style: TextStyle(color: Color(0xFF006699), fontWeight: FontWeight.bold, fontSize: 18),
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
                // 1. KARTU PROFIL UTAMA (MELENGKUNG INDAH)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
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
                              border: Border.all(color: const Color(0xFF0284C7), width: 2.5),
                            ),
                            child: const CircleAvatar(
                              radius: 55,
                              backgroundColor: Color(0xFFE2E8F0),
                              child: Icon(Icons.face, size: 55, color: Color(0xFF94A3B8)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFF0284C7), shape: BoxShape.circle),
                            child: const Icon(Icons.edit, size: 12, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        namaAnak,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.scale, size: 14, color: Color(0xFF0284C7)),
                            const SizedBox(width: 6),
                            Text(
                              umurAnak,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 2. KELOMPOK BARIS DATA ANAK
                const Text(
                  'DATA ANAK',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),

                _buildProfilComponentTile(icon: Icons.fingerprint, title: 'NIK', value: nik),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _buildProfilComponentGridTile(icon: Icons.male, title: 'JENIS KELAMIN', value: 'Laki-laki')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildProfilComponentGridTile(icon: Icons.calendar_month, title: 'TANGGAL LAHIR', value: tanggalLahir)),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. KELOMPOK DATA ORANG TUA (SUDAH DIHAPUS FIELD NAMA AYAH SESUAI KEINGINAN)
                const Text(
                  'DATA ORANG TUA',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.face_3_outlined, color: Color(0xFF0284C7), size: 22),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NAMA IBU', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(namaIbu, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _buildProfilComponentTile(icon: Icons.location_on_outlined, title: 'ALAMAT', value: alamat),
                const SizedBox(height: 28),

                // 4. ACTION BUTTONS: TOMBOL EDIT SEKARANG SUDAH AKTIF INTERAKTIF POP-UP B BOTTOM SHEET
                ElevatedButton.icon(
                  onPressed: () => _bukaModalEditProfil(namaAnak, alamat),
                  icon: const Icon(Icons.edit_note, size: 20, color: Colors.white),
                  label: const Text('Edit Data Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006192),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // 5. TOMBOL LOGOUT MERAH UTUH BESERTA DIALOG KONFIRMASI NYATA
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text('Yakin ingin keluar dari akun SIPANDA Anda?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Keluar', style: TextStyle(color: Color(0xFFDC3545))),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await auth.logout();
                        if (mounted) context.go('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC3545),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilComponentTile({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
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

  Widget _buildProfilComponentGridTile({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
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

// ══════════════════════════════════════════════════════════
// HISTORY TAB CONTENT
// ══════════════════════════════════════════════════════════
class _HistoryTabContent extends StatefulWidget {
  final String nikAnak;
  final String namaAnak;
  const _HistoryTabContent({required this.nikAnak, required this.namaAnak});

  @override
  State<_HistoryTabContent> createState() => _HistoryTabContentState();
}

class _HistoryTabContentState extends State<_HistoryTabContent> {
  final KmsService       _kmsService  = KmsService();
  final ImunisasiService _imunService = ImunisasiService();

  KmsModel?            _data;
  List<ImunisasiModel> _imunisasiList = [];
  bool                 _isLoading     = true;
  String?              _error;

  static const Color _primary     = Color(0xFF0D6EFD);
  static const Color _textDark    = Color(0xFF1E293B);
  static const Color _textGrey    = Color(0xFF64748B);
  static const Color _background  = Color(0xFFF7F9FC);
  static const Color _cardWhite   = Color(0xFFFFFFFF);
  static const Color _border      = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _kmsService.getKms(widget.nikAnak),
        _imunService.getRiwayat(widget.nikAnak),
      ]);

      setState(() {
        _data          = results[0] as KmsModel;
        _imunisasiList = results[1] as List<ImunisasiModel>;
        _isLoading     = false;
      });

      debugPrint('DEBUG imunisasi: ${_imunisasiList.length} data');
    } catch (e) {
      debugPrint('DEBUG error: $e');
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  String _formatTgl(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('d MMM yyyy', 'id_ID').format(dt);
    } catch (_) { return tgl; }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_error != null || _data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(_error ?? 'Gagal memuat', style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final data = _data!;
    return RefreshIndicator(
      color: _primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                    color: Color(0xFFEAF2FF), shape: BoxShape.circle),
                child: Icon(
                  data.isLakiLaki ? Icons.face_rounded : Icons.face_3_rounded,
                  color: data.isLakiLaki ? _primary : const Color(0xFFE91E63),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(widget.namaAnak,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            ],
          ),
          const SizedBox(height: 20),

          _buildGrafik(data),
          const SizedBox(height: 20),

          _buildImunisasiSection(),
          const SizedBox(height: 20),

          _buildKunjunganSection(data),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGrafik(KmsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Grafik Tumbuh Kembang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(8)),
              child: const Text('KMS Digital',
                  style: TextStyle(fontSize: 10, color: _primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _buildLegend('Berat (BB)', _primary),
                const SizedBox(width: 16),
                _buildLegend('Tinggi (TB)', const Color(0xFF6F42C1)),
              ]),
              const SizedBox(height: 16),
              data.pemeriksaanUrut.isEmpty
                  ? const SizedBox(
                      height: 160,
                      child: Center(
                        child: Text('Belum ada data pemeriksaan',
                            style: TextStyle(color: _textGrey)),
                      ),
                    )
                  : SizedBox(
                      height: 180,
                      child: _GrafikPertumbuhan(pemeriksaan: data.pemeriksaanUrut),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: _textGrey)),
      ],
    );
  }

  Widget _buildImunisasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Riwayat Imunisasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            TextButton(
              onPressed: () {},
              child: const Text('LIHAT SEMUA',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _imunisasiList.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: const Center(
                  child: Text('Belum ada riwayat imunisasi',
                      style: TextStyle(color: _textGrey)),
                ),
              )
            : SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imunisasiList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imun = _imunisasiList[index];
                    return Container(
                      width: 110,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _cardWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(
                                color: Color(0xFF0A58CA), shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            imun.namaVaksin ?? 'Vaksin',
                            style: const TextStyle(fontSize: 12,
                                fontWeight: FontWeight.w700, color: _textDark),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTgl(imun.tglPemberian),
                            style: const TextStyle(fontSize: 10, color: _textGrey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildKunjunganSection(KmsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kunjungan Rutin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 12),
        if (data.pemeriksaan.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: const Center(
              child: Text('Belum ada data kunjungan', style: TextStyle(color: _textGrey)),
            ),
          )
        else
          ...data.pemeriksaan.asMap().entries.map((e) =>
              _buildKunjunganCard(e.value, e.key == 0)),
      ],
    );
  }

  Widget _buildKunjunganCard(KmsPemeriksaan periksa, bool isFirst) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFirst ? _primary.withAlpha(80) : _border,
          width: isFirst ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFirst)
            const Text('KUNJUNGAN TERAKHIR',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: _primary, letterSpacing: 0.5)),
          Text(_formatTgl(periksa.tglPeriksa),
              style: TextStyle(
                fontSize: isFirst ? 16 : 14,
                fontWeight: isFirst ? FontWeight.w700 : FontWeight.w600,
                color: _textDark,
              )),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _buildDataItem(
              label: isFirst ? 'BERAT' : 'BB',
              value: periksa.beratBadan != null ? '${periksa.beratBadan} kg' : '-',
              isFirst: isFirst,
            )),
            Expanded(child: _buildDataItem(
              label: isFirst ? 'TINGGI' : 'TB',
              value: periksa.tinggiBadan != null ? '${periksa.tinggiBadan} cm' : '-',
              isFirst: isFirst,
            )),
            Expanded(child: _buildDataItem(
              label: isFirst ? 'L. KEPALA' : 'LK',
              value: periksa.lingkarKepala != null ? '${periksa.lingkarKepala} cm' : '-',
              isFirst: isFirst,
            )),
          ]),
        ],
      ),
    );
  }

  Widget _buildDataItem({required String label, required String value, required bool isFirst}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _textGrey)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
              fontSize: isFirst ? 16 : 14,
              fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
              color: isFirst ? _primary : _textDark,
            )),
      ],
    );
  }
}

class _GrafikPertumbuhan extends StatelessWidget {
  final List<KmsPemeriksaan> pemeriksaan;
  const _GrafikPertumbuhan({required this.pemeriksaan});

  @override
  Widget build(BuildContext context) {
    if (pemeriksaan.isEmpty) return const SizedBox();
    final bbData = pemeriksaan.where((p) => p.beratBadan != null).map((p) => p.beratBadan!).toList();
    final tbData = pemeriksaan.where((p) => p.tinggiBadan != null).map((p) => p.tinggiBadan!).toList();
    final labels = pemeriksaan.map((p) {
      try {
        final dt = DateTime.parse(p.tglPeriksa);
        return '${dt.month}/${dt.year.toString().substring(2)}';
      } catch (_) { return ''; }
    }).toList();

    return CustomPaint(
      painter: _GrafikPainter(bbData: bbData, tbData: tbData, labels: labels),
      child: const SizedBox.expand(),
    );
  }
}

class _GrafikPainter extends CustomPainter {
  final List<double> bbData;
  final List<double> tbData;
  final List<String> labels;

  _GrafikPainter({required this.bbData, required this.tbData, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 10.0, padR = 10.0, padT = 10.0, padB = 30.0;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;

    final paintBB = Paint()
      ..color = const Color(0xFF0D6EFD)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintTB = Paint()
      ..color = const Color(0xFF6F42C1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    if (bbData.length > 1) {
      final minBB = bbData.reduce(math.min);
      final maxBB = bbData.reduce(math.max);
      final range = (maxBB - minBB).clamp(1.0, double.infinity);
      final bgPath = Path();
      for (int i = 0; i < bbData.length; i++) {
        final x = padL + (i / (bbData.length - 1)) * w;
        final y = padT + h - ((bbData[i] - minBB) / range) * h;
        i == 0 ? bgPath.moveTo(x, y) : bgPath.lineTo(x, y);
      }
      bgPath.lineTo(padL + w, padT + h);
      bgPath.lineTo(padL, padT + h);
      bgPath.close();
      canvas.drawPath(bgPath,
          Paint()..color = const Color(0xFFEAF2FF).withAlpha(150)..style = PaintingStyle.fill);
    }

    _drawLine(canvas, bbData, paintBB, const Color(0xFF0D6EFD), padL, padR, padT, padB, size);
    _drawDashedLine(canvas, tbData, paintTB, padL, padR, padT, padB, size);

    if (labels.isNotEmpty) {
      final count = math.min(labels.length, 5);
      for (int i = 0; i < count; i++) {
        final idx = labels.length == 1 ? 0
            : (i * (labels.length - 1) / (count - 1)).round().clamp(0, labels.length - 1);
        final x = labels.length == 1 ? padL + w / 2
            : padL + (idx / (labels.length - 1)) * w;
        final tp = TextPainter(
          text: TextSpan(text: labels[idx],
              style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, size.height - padB + 6));
      }
    }
  }

  void _drawLine(Canvas canvas, List<double> data, Paint paint, Color dotColor,
      double padL, double padR, double padT, double padB, Size size) {
    if (data.isEmpty) return;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;
    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).clamp(1.0, double.infinity);

    if (data.length == 1) {
      final x = padL + w / 2; final y = padT + h / 2;
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = dotColor..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = Colors.white..style = PaintingStyle.fill);
      return;
    }

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = padL + (i / (data.length - 1)) * w;
      final y = padT + h - ((data[i] - minV) / range) * h;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < data.length; i++) {
      final x = padL + (i / (data.length - 1)) * w;
      final y = padT + h - ((data[i] - minV) / range) * h;
      dotPaint.color = dotColor;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      dotPaint.color = Colors.white;
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, List<double> data, Paint paint,
      double padL, double padR, double padT, double padB, Size size) {
    if (data.length < 2) return;
    final w = size.width - padL - padR;
    final h = size.height - padT - padB;
    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).clamp(1.0, double.infinity);

    for (int i = 0; i < data.length - 1; i++) {
      final x1 = padL + (i / (data.length - 1)) * w;
      final y1 = padT + h - ((data[i] - minV) / range) * h;
      final x2 = padL + ((i + 1) / (data.length - 1)) * w;
      final y2 = padT + h - ((data[i + 1] - minV) / range) * h;
      final dx = x2 - x1; final dy = y2 - y1;
      final dist = math.sqrt(dx * dx + dy * dy);
      var drawn = 0.0; var isDash = true;
      while (drawn < dist) {
        final len = math.min(isDash ? 8.0 : 4.0, dist - drawn);
        final t1 = drawn / dist; final t2 = (drawn + len) / dist;
        if (isDash) {
          canvas.drawLine(
            Offset(x1 + dx * t1, y1 + dy * t1),
            Offset(x1 + dx * t2, y1 + dy * t2),
            paint,
          );
        }
        drawn += len; isDash = !isDash;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}