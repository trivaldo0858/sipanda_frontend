// lib/features/dashboard/screens/dashboard_kader_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_model.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardKaderScreen extends StatefulWidget {
  const DashboardKaderScreen({super.key});
  @override
  State<DashboardKaderScreen> createState() => _DashboardKaderScreenState();
}

class _DashboardKaderScreenState extends State<DashboardKaderScreen> {
  int _currentIndex = 0;

  static const Color _primary    = Color(0xFF0D6EFD);
  static const Color _primaryDark = Color(0xFF0A58CA);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textGrey   = Color(0xFF64748B);
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _cardWhite  = Color(0xFFFFFFFF);
  static const Color _border     = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadKader();
    });
  }

  String _formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return tgl;
    }
  }

  String _timeAgo(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
      return '${diff.inDays} hari yang lalu';
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
            _buildHomeTab(),
            _buildDataAnakTab(),
            _buildJadwalTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: _cardWhite,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care_outlined),
            activeIcon: Icon(Icons.child_care_rounded),
            label: 'Data Anak',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'Jadwal',
          ),
        ],
      ),
    );
  }

  // ── HOME TAB ─────────────────────────────────────────
  Widget _buildHomeTab() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          color: _primary,
          onRefresh: () => provider.loadKader(),
          child: CustomScrollView(
            slivers: [
              // AppBar
              SliverToBoxAdapter(child: _buildAppBar()),

              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _primary),
                  ),
                )
              else if (provider.status == DashboardStatus.error)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 48, color: _textGrey),
                        const SizedBox(height: 12),
                        Text(provider.errorMessage ?? 'Gagal memuat data',
                            style: const TextStyle(color: _textGrey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.loadKader,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatCard(provider.kaderData),
                      const SizedBox(height: 16),
                      _buildJadwalCard(provider.kaderData?.jadwalTerdekat),
                      const SizedBox(height: 24),
                      _buildLayananUtama(),
                      const SizedBox(height: 24),
                      _buildAktivitasTerbaru(
                          provider.kaderData?.aktivitasTerbaru ?? []),
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
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          color: _cardWhite,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded,
                    color: _primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Halo, Kader!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    if (auth.user?.namaPosyandu != null)
                      Text(
                        auth.user!.namaPosyandu!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textGrey,
                        ),
                      ),
                  ],
                ),
              ),
              // Notifikasi
              // Notifikasi
              IconButton(
                onPressed: () => context.push('/notifikasi'),
                icon: const Icon(Icons.notifications_outlined,
                    color: _textDark, size: 24),
              ),
              // Logout
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Konfirmasi Logout'),
                      content: const Text('Yakin ingin keluar?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Keluar',
                              style: TextStyle(color: Color(0xFFDC3545))),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await context.read<AuthProvider>().logout();
                    if (mounted) context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout_rounded,
                    color: Color(0xFFDC3545), size: 24),
                tooltip: 'Logout',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(DashboardKader? data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balita Terdaftar',
            style: TextStyle(fontSize: 13, color: _textGrey),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data?.totalBalita ?? 0}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'Anak',
                  style: TextStyle(fontSize: 14, color: _textGrey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(JadwalTerdekat? jadwal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jadwal Posyandu Terdekat',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  jadwal != null
                      ? _formatTanggal(jadwal.tglKegiatan)
                      : 'Belum ada jadwal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (jadwal != null)
                  Text(
                    jadwal.lokasi,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70),
                  ),
              ],
            ),
          ),
          if (jadwal != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'MENDATANG',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLayananUtama() {
    final menus = [
      _MenuData(
          icon: Icons.person_add_outlined,
          label: 'Input Data\nAnak',
          onTap: () => context.push('/anak/tambah')),
      _MenuData(
          icon: Icons.monitor_heart_outlined,
          label: 'Catat\nPemeriksaan',
          onTap: () => context.push('/anak')),
      _MenuData(
          icon: Icons.calendar_month_outlined,
          label: 'Kelola\nJadwal',
          onTap: () => setState(() => _currentIndex = 2)),
      _MenuData(
          icon: Icons.bar_chart_rounded,
          label: 'Laporan\nBulanan',
          onTap: () => context.push('/laporan')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Layanan Utama',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: menus.map((m) => _buildMenuCard(m)).toList(),
        ),
      ],
    );
  }

  Widget _buildMenuCard(_MenuData menu) {
    return GestureDetector(
      onTap: menu.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(menu.icon, color: _primary, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              menu.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _textDark,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAktivitasTerbaru(List<AktivitasTerbaru> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text('Lihat Semua',
                  style: TextStyle(color: _primary, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: const Center(
              child: Text('Belum ada aktivitas',
                  style: TextStyle(color: _textGrey)),
            ),
          )
        else
          ...list.take(3).map((a) => _buildAktivitasItem(a)),
      ],
    );
  }

  Widget _buildAktivitasItem(AktivitasTerbaru a) {
    final isNormal = a.statusValidasi == 'Valid';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.child_care_rounded,
                color: _primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.namaAnak,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    )),
                Text(
                  '${_timeAgo(a.tglPeriksa)} • Berat: ${a.beratBadan ?? '-'} kg',
                  style: const TextStyle(fontSize: 12, color: _textGrey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNormal
                  ? const Color(0xFFD1E7DD)
                  : const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              a.statusValidasi == 'Valid' ? 'NORMAL' : a.statusValidasi.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isNormal
                    ? const Color(0xFF198754)
                    : const Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DATA ANAK TAB ─────────────────────────────────────
  Widget _buildDataAnakTab() {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Data Anak'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/anak/tambah'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: const Center(
        child: Text('Tab Data Anak — akan diisi di fitur anak'),
      ),
    );
  }

  // ── JADWAL TAB ────────────────────────────────────────
  Widget _buildJadwalTab() {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Jadwal Posyandu'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Tab Jadwal — akan diisi di fitur jadwal'),
      ),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _MenuData({required this.icon, required this.label, required this.onTap});
}