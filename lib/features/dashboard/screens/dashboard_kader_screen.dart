import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../anak/screens/data_anak_screen.dart';
import '../../jadwal/screens/jadwal_screen.dart';

class DashboardKaderScreen extends StatefulWidget {
  const DashboardKaderScreen({super.key});

  @override
  State<DashboardKaderScreen> createState() => _DashboardKaderScreenState();
}

class _DashboardKaderScreenState extends State<DashboardKaderScreen> {
  int _currentIndex = 0;

  static const _primary = Color(0xFF1B6CA8);
  static const _primaryDark = Color(0xFF0D47A1);
  static const _accent = Color(0xFF00838F);
  static const _textDark = Color(0xFF0D1B2A);
  static const _textGrey = Color(0xFF5C7A99);
  static const _bg = Color(0xFFF0F6FF);
  static const _cardWhite = Color(0xFFFFFFFF);
  static const _border = Color(0xFFD0E4F7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadKader();
    });
  }

  String _inisialPosyandu(String? nama) {
    if (nama == null || nama.isEmpty) return 'P';
    final kata = nama.trim().split(RegExp(r'\s+'));
    if (kata.length >= 2) {
      return (kata[0][0] + kata[1][0]).toUpperCase();
    }
    return nama.substring(0, nama.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return 'Baru saja';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
    return 'Baru saja';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            const DataAnakScreen(),
            const JadwalScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HOME TAB (HALAMAN UTAMA DASHBOARD) ───────────────────
  Widget _buildHomeTab() => Consumer<DashboardProvider>(
    builder: (context, provider, _) => RefreshIndicator(
      color: _primary,
      onRefresh: () => provider.loadKader(),
      child: CustomScrollView(
        slivers: [
          // Header Aplikasi tetap berada di paling atas
          SliverToBoxAdapter(child: _buildAppBar()),

          // Spasi pemisah yang ideal dari header ke halaman utama
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: _primary)),
            )
          else if (provider.status == DashboardStatus.error)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(provider.errorMessage ?? 'Gagal memuat data'),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => provider.loadKader(),
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
                  // MODIFIKASI KUNCI: Teks Menyapa & Nama Posyandu dipindah ke halaman utama
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Halo, Kader!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.user?.namaPosyandu ?? 'Nama Posyandu',
                          style: const TextStyle(
                            fontSize: 24, // Ukuran font judul utama halaman
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ), // Jarak napas sebelum masuk ke card statistik

                  _buildStatCard(provider.kaderData),
                  const SizedBox(height: 14),
                  _buildJadwalCard(provider.kaderData?.jadwalTerdekat),
                  const SizedBox(height: 22),
                  _buildLayananUtama(),
                  const SizedBox(height: 22),
                  _buildAktivitasTerbaru(
                    provider.kaderData?.aktivitasTerbaru ?? [],
                  ),
                ]),
              ),
            ),
        ],
      ),
    ),
  );

  // ── HEADER BARU (APP BAR MODERNISED) ─────────────────────
  Widget _buildAppBar() => Consumer<AuthProvider>(
    builder: (context, auth, _) {
      final namaPos = auth.user?.namaPosyandu;
      final inisial = _inisialPosyandu(namaPos);
      return Container(
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
        child: Row(
          children: [
            // 1. PROFIL KEMBALI KE SEBELAH KIRI (BULAT GRADASI BIRU SEPERTI JADWAL CARD)
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_primaryDark, _primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  inisial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // 2. BAGIAN TENGAH UTAMA BERTULISKAN "SIPANDA"
            Expanded(
              child: Center(
                child: Text(
                  'SIPANDA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _primaryDark,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // 3. TOMBOL AKSI NOTIFIKASI & LOGOUT TETAP DI SEBELAH KANAN
            IconButton(
              onPressed: () => context.push('/notifikasi'),
              icon: const Icon(
                Icons.notifications_outlined,
                color: _textDark,
                size: 23,
              ),
            ),
            IconButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: Color(0xFFE53935)),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await context.read<AuthProvider>().logout();
                  if (mounted) context.go('/login');
                }
              },
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE53935),
                size: 22,
              ),
            ),
          ],
        ),
      );
    },
  );

  // ── WIDGET STATISTIK BALITA ──────────────────────────────
  Widget _buildStatCard(DashboardKader? data) {
    final total = data?.totalBalita ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balita Terdaftar',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$total Anak',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.child_care_rounded,
              color: _primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET KARTU JADWAL POSYANDU ─────────────────────────
  Widget _buildJadwalCard(dynamic j) {
    if (j == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryDark, _primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Belum ada jadwal pelaksanaan terdekat.',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      );
    }
    DateTime? tgl;
    try {
      tgl = DateTime.parse(j.tglPelaksanaan);
    } catch (_) {}
    final fmtTgl = tgl != null
        ? DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tgl)
        : j.tglPelaksanaan;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryDark, _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withOpacity(0.24),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Jadwal Kegiatan Terdekat',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            fmtTgl,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Waktu: ${j.jamMulai.substring(0, 5)} - ${j.jamSelesai.substring(0, 5)} WIB',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET GRID LAYANAN UTAMA ────────────────────────────
  Widget _buildLayananUtama() {
    final list = [
      (_MenuData(
        Icons.app_registration_rounded,
        'Pendaftaran Balita',
        const Color(0xFF1565C0),
        const Color(0xFFE3F2FD),
      )),
      (_MenuData(
        Icons.monitor_weight_rounded,
        'Pemeriksaan',
        const Color(0xFF00838F),
        const Color(0xFFE0F7FA),
      )),
      (_MenuData(
        Icons.analytics_rounded,
        'Laporan PDF',
        const Color(0xFF2E7D32),
        const Color(0xFFE8F5E9),
      )),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Layanan Utama',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: list.map((m) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (m.title == 'Pendaftaran') {
                    setState(() => _currentIndex = 1);
                  } else if (m.title == 'Pemeriksaan') {
                    context.push('/pemeriksaan');
                  } else if (m.title == 'Laporan PDF') {
                    context.push('/laporan');
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: m.bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(m.icon, color: m.color, size: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        m.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── WIDGET AKTIVITAS TERBARU ─────────────────────────────
  Widget _buildAktivitasTerbaru(List<AktivitasTerbaru> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pemeriksaan Terbaru',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: const Center(
              child: Text(
                'Belum ada riwayat pemeriksaan terbaru.',
                style: TextStyle(fontSize: 13, color: _textGrey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final a = items[i];
              final isNormal = a.statusValidasi.toLowerCase() == 'disetujui';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_ind_rounded,
                        color: _primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.namaAnak,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            '${_timeAgo(a.tglPeriksa != null ? DateTime.tryParse(a.tglPeriksa!) : null)} • Berat: ${a.beratBadan ?? '-'} kg',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isNormal
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isNormal ? 'NORMAL' : a.statusValidasi.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isNormal ? _primary : const Color(0xFFF57F17),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ── BOTTOM NAVIGATION BAR ────────────────────────────────
  Widget _buildBottomNav() => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: _textDark.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      backgroundColor: _cardWhite,
      selectedItemColor: _primary,
      unselectedItemColor: _textGrey.withOpacity(0.6),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_rounded),
          label: 'Data Anak',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Jadwal',
        ),
      ],
    ),
  );
}

class _MenuData {
  final IconData icon;
  final String title;
  final Color color;
  final Color bg;
  _MenuData(this.icon, this.title, this.color, this.bg);
}
