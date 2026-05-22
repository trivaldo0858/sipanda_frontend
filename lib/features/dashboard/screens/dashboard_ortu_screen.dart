// lib/features/dashboard/screens/dashboard_ortu_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_model.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardOrtuScreen extends StatefulWidget {
  const DashboardOrtuScreen({super.key});
  @override
  State<DashboardOrtuScreen> createState() => _DashboardOrtuScreenState();
}

class _DashboardOrtuScreenState extends State<DashboardOrtuScreen> {
  int _currentIndex = 0;

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
    } catch (_) {
      return tgl;
    }
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
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

  // ── BERANDA TAB ───────────────────────────────────────
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
                  child: Center(
                      child: CircularProgressIndicator(color: _primary)),
                )
              else if (provider.status == DashboardStatus.error)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(provider.errorMessage ?? 'Gagal memuat',
                            style: const TextStyle(color: _textGrey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.loadOrtu,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ...(provider.ortuData?.daftarAnak ?? [])
                          .map((a) => _buildProfilAnakCard(a)),
                      const SizedBox(height: 20),
                      _buildJadwalSection(
                          provider.ortuData?.jadwalTerdekat),
                    ]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── AppBar ────────────────────────────────────────────
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: _primary, size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'SIPANDA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),

              // ── Ikon Notifikasi ──────────────────────
              Stack(
                children: [
                  IconButton(
                    // FIX: push ke halaman notifikasi, bukan ke tab Profil
                    onPressed: () => context.push('/notifikasi'),
                    icon: const Icon(Icons.notifications_outlined,
                        color: _textDark, size: 24),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC3545),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
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

  // ── Kartu Profil Anak ─────────────────────────────────
  Widget _buildProfilAnakCard(InfoAnak anak) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PROFIL ANAK',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _primary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            anak.namaAnak,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.fingerprint_rounded,
                  size: 16, color: _textGrey),
              const SizedBox(width: 6),
              Text('NIK:${anak.nikAnak}',
                  style: const TextStyle(fontSize: 13, color: _textGrey)),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.cake_outlined, size: 16, color: _textGrey),
              const SizedBox(width: 6),
              Text(anak.umurFormat,
                  style: const TextStyle(fontSize: 13, color: _textGrey)),
            ],
          ),
          const SizedBox(height: 16),

          // Data terakhir — muncul kalau ada pemeriksaan
          if (anak.beratTerakhir != null || anak.tinggiTerakhir != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Data Terakhir',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                Text(
                  'Update: ${_formatTanggal(anak.tglLahir)}',
                  style: const TextStyle(fontSize: 11, color: _textGrey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (anak.beratTerakhir != null)
                  Expanded(
                    child: _buildDataCard(
                      icon: Icons.monitor_weight_outlined,
                      label: 'BERAT BADAN',
                      value: '${anak.beratTerakhir}',
                      unit: 'kg',
                    ),
                  ),
                if (anak.beratTerakhir != null && anak.tinggiTerakhir != null)
                  const SizedBox(width: 12),
                if (anak.tinggiTerakhir != null)
                  Expanded(
                    child: _buildDataCard(
                      icon: Icons.straighten_outlined,
                      label: 'TINGGI BADAN',
                      value: '${anak.tinggiTerakhir}',
                      unit: 'cm',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Tombol Lihat Detail → KMS
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/kms/${anak.nikAnak}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                minimumSize: Size.zero,
              ),
              icon: const Text(
                'Lihat Detail',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              label: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard({
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textGrey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Jadwal Terdekat ───────────────────────────────────
  Widget _buildJadwalSection(JadwalTerdekat? jadwal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Terdekat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
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
    try {
      dt = DateTime.parse(jadwal.tglKegiatan);
    } catch (_) {}

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
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('MMM').format(dt).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    dt.day.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jadwal.lokasi,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                if (jadwal.agenda != null) ...[
                  const SizedBox(height: 2),
                  Text(jadwal.agenda!,
                      style:
                          const TextStyle(fontSize: 12, color: _textGrey)),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFD7FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: _primary),
                      const SizedBox(width: 4),
                      Text(
                        jadwal.lokasi.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                          letterSpacing: 0.3,
                        ),
                      ),
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

  // ── HISTORY TAB ───────────────────────────────────────
  Widget _buildHistoryTab() {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Riwayat Pemeriksaan'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 48, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text('Riwayat pemeriksaan',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B))),
            SizedBox(height: 4),
            Text('Segera hadir',
                style: TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  // ── PROFIL TAB ────────────────────────────────────────
  Widget _buildProfilTab() {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1E7DD),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.family_restroom_rounded,
                      color: Color(0xFF198754), size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.user?.namaIbu ?? 'Orang Tua',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Akun Orang Tua',
                    style: TextStyle(fontSize: 13, color: _textGrey)),
                const SizedBox(height: 40),

                // ── Tombol Logout ──────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text('Yakin ingin keluar?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text(
                                'Keluar',
                                style:
                                    TextStyle(color: Color(0xFFDC3545)),
                              ),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.white, size: 20),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}