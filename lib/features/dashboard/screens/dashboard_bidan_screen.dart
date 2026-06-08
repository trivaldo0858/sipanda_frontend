// lib/features/dashboard/screens/dashboard_bidan_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../anak/screens/data_anak_screen.dart';
import '../../jadwal/screens/jadwal_screen.dart';

class DashboardBidanScreen extends StatefulWidget {
  const DashboardBidanScreen({super.key});
  @override
  State<DashboardBidanScreen> createState() => _DashboardBidanScreenState();
}

class _DashboardBidanScreenState extends State<DashboardBidanScreen> {
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
      context.read<DashboardProvider>().loadBidan();
    });
  }

  String _timeAgo(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
      return '${diff.inDays} hari yang lalu';
    } catch (_) { return tgl; }
  }

  String _getInisial(String? nama) {
    if (nama == null || nama.isEmpty) return 'B';
    final words = nama.trim().split(' ');
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return nama.substring(0, nama.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _showLogoutDialog(BuildContext context, AuthProvider auth) async {
    final nama = auth.user?.namaBidan ?? 'Bidan';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: const Color(0xFF6F42C1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(_getInisial(nama),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bidan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(nama, style: const TextStyle(fontSize: 13, color: _textGrey)),
              ],
            )),
          ],
        ),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
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
            _buildDataBalitaTab(),
            _buildJadwalTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.child_care_outlined), activeIcon: Icon(Icons.child_care_rounded), label: 'Data Balita'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month_rounded), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildBerandaTab() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          color: _primary,
          onRefresh: () => provider.loadBidan(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar()),
              if (provider.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: _primary)))
              else if (provider.status == DashboardStatus.error)
                SliverFillRemaining(child: Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: _textGrey),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage ?? 'Gagal memuat', style: const TextStyle(color: _textGrey)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: provider.loadBidan, child: const Text('Coba Lagi')),
                  ],
                )))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(delegate: SliverChildListDelegate([
                    _buildStatCard(provider.bidanData),
                    const SizedBox(height: 24),
                    _buildLayananUtama(),
                    const SizedBox(height: 24),
                    _buildAktivitasImunisasi(provider.bidanData?.aktivitasImunisasi ?? []),
                  ])),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── AppBar mirip Kader ────────────────────────────────
  Widget _buildAppBar() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final nama = auth.user?.namaBidan ?? '';
        final inisial = _getInisial(nama);
        return Container(
          color: _cardWhite,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Halo, Bidan!', style: TextStyle(fontSize: 14, color: _textGrey)),
                    Text(
                      nama.isNotEmpty ? nama : 'Bidan',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showLogoutDialog(context, auth),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F42C1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(inisial,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(DashboardBidan? data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _primaryDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STATUS BULAN INI',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${data?.balitaPerluImunisasi ?? 0}',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('Balita',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
          const Text('Balita Perlu Imunisasi', style: TextStyle(fontSize: 13, color: Colors.white70)),
          if (data != null && data.pemeriksaanMenungguValidasi > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text('${data.pemeriksaanMenungguValidasi} pemeriksaan menunggu validasi',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLayananUtama() {
    final menus = [
      _MenuData(icon: Icons.vaccines_outlined, label: 'Input\nImunisasi',
          color: const Color(0xFF6F42C1), bgColor: const Color(0xFFF0EBFF),
          onTap: () => context.push('/imunisasi/catat')),
      _MenuData(icon: Icons.bar_chart_rounded, label: 'Laporan\nBulanan',
          color: _primary, bgColor: const Color(0xFFEAF2FF),
          onTap: () => context.push('/laporan')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Layanan Utama',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 14),
        Row(
          children: menus.map((m) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: m == menus.last ? 0 : 12),
              child: _buildMenuCard(m),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMenuCard(_MenuData menu) {
    return GestureDetector(
      onTap: menu.onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
            color: _cardWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: menu.bgColor, borderRadius: BorderRadius.circular(14)),
              child: Icon(menu.icon, color: menu.color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(menu.label, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textDark, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildAktivitasImunisasi(List<AktivitasImunisasi> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Aktivitas Imunisasi Terakhir',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text('Lihat Semua', style: TextStyle(color: _primary, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _cardWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
            child: const Center(child: Text('Belum ada aktivitas imunisasi', style: TextStyle(color: _textGrey))),
          )
        else
          ...list.take(5).map((a) => _buildImunisasiItem(a)),
      ],
    );
  }

  Widget _buildImunisasiItem(AktivitasImunisasi a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _cardWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFF0EBFF), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.child_friendly_rounded, color: Color(0xFF6F42C1), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.namaAnak,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
              Text('${a.namaVaksin} • ${_timeAgo(a.tglPemberian)}',
                  style: const TextStyle(fontSize: 12, color: _textGrey)),
            ],
          )),
          const Icon(Icons.check_circle_rounded, color: Color(0xFF198754), size: 22),
        ],
      ),
    );
  }

  Widget _buildDataBalitaTab() => const DataAnakScreen();

  Widget _buildJadwalTab() => const JadwalScreen();

  Widget _buildProfilTab() => Scaffold(
    backgroundColor: _background,
    appBar: AppBar(title: const Text('Profil'), automaticallyImplyLeading: false),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<AuthProvider>(builder: (context, auth, _) {
              final nama = auth.user?.namaBidan ?? 'Bidan';
              return Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: const Color(0xFF6F42C1), borderRadius: BorderRadius.circular(24)),
                  child: Center(child: Text(_getInisial(nama),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28))),
                ),
                const SizedBox(height: 12),
                Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(height: 4),
                const Text('Bidan', style: TextStyle(fontSize: 13, color: _textGrey)),
              ]);
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Konfirmasi Logout'),
                      content: const Text('Yakin ingin keluar?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text('Keluar dari Akun',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MenuData {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  _MenuData({required this.icon, required this.label, required this.onTap,
      this.color = const Color(0xFF0D6EFD), this.bgColor = const Color(0xFFEAF2FF)});
}