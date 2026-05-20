// lib/features/anak/presentation/screens/data_anak_kader_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/anak_model.dart';
import '../../../auth/presentation/providers/anak_provider.dart';

class DataAnakKaderScreen extends StatefulWidget {
  const DataAnakKaderScreen({super.key});

  @override
  State<DataAnakKaderScreen> createState() => _DataAnakKaderScreenState();
}

class _DataAnakKaderScreenState extends State<DataAnakKaderScreen>
    with SingleTickerProviderStateMixin {

  // ── Palette ───────────────────────────────────────────────────────
  static const _primary    = Color(0xFF0D6EFD);
  static const _primaryBg  = Color(0xFFEAF4FF);
  static const _bg         = Color(0xFFF7F9FC);
  static const _cardBg     = Colors.white;
  static const _textDark   = Color(0xFF1E293B);
  static const _textGrey   = Color(0xFF64748B);
  static const _danger     = Color(0xFFEF4444);
  static const _dangerBg   = Color(0xFFFEE2E2);

  // ── State ─────────────────────────────────────────────────────────
  int _filterIndex        = 0; // 0=Semua 1=L 2=P
  int _navIndex           = 1;
  final _searchCtrl       = TextEditingController();
  final _scrollCtrl       = ScrollController();
  late AnimationController _animCtrl;

  final _filters = ['Semua', 'Laki-laki', 'Perempuan'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnakProvider>().fetchAll();
      _animCtrl.forward();
    });
    _scrollCtrl.addListener(_onScroll);
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final p = context.read<AnakProvider>();
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      if (p.hasMore && !p.isLoading) {
        p.loadMore(search: _searchCtrl.text.trim());
      }
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim();
    if (q.length >= 2 || q.isEmpty) {
      context.read<AnakProvider>().fetchAll(search: q);
    }
  }

  List<AnakModel> _filtered(List<AnakModel> all) {
    if (_filterIndex == 0) return all;
    final g = _filterIndex == 1 ? 'L' : 'P';
    return all.where((a) => a.jenisKelamin == g).toList();
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () =>
            context.read<AnakProvider>().fetchAll(search: _searchCtrl.text.trim()),
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    _searchBar(),
                    const SizedBox(height: 14),
                    _chipFilter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildList(),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
      floatingActionButton: _fab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: _cardBg,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    leading: IconButton(
      icon: const Icon(Icons.menu_rounded, color: _textDark, size: 24),
      onPressed: () {},
    ),
    title: const Text(
      'Data Anak',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _primary,
        letterSpacing: 0.2,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.search_rounded, color: _textDark, size: 24),
        onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
      ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: const Color(0xFFF0F0F0)),
    ),
  );

  // ── Header ────────────────────────────────────────────────────────
  Widget _header() => Consumer<AnakProvider>(
    builder: (_, p, __) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Balita',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _primary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kelola informasi kesehatan dan pertumbuhan anak\ndi wilayah Posyandu Anda.',
          style: TextStyle(fontSize: 13, color: _textGrey, height: 1.5),
        ),
        if (!p.isLoading && p.anakList.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _primaryBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_filtered(p.anakList).length} balita ditemukan',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  // ── Search Bar ────────────────────────────────────────────────────
  Widget _searchBar() => Row(
    children: [
      Expanded(
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(fontSize: 14, color: _textDark),
            decoration: const InputDecoration(
              hintText: 'Cari nama atau NIK...',
              hintStyle: TextStyle(color: _textGrey, fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: _textGrey, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      GestureDetector(
        onTap: _showFilter,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
        ),
      ),
    ],
  );

  // ── Chip Filter ───────────────────────────────────────────────────
  Widget _chipFilter() => SizedBox(
    height: 36,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final active = _filterIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _filterIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: active ? _primary : _cardBg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(active ? 0.12 : 0.05),
                  blurRadius: active ? 10 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _filters[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : _textGrey,
              ),
            ),
          ),
        );
      },
    ),
  );

  // ── List ──────────────────────────────────────────────────────────
  Widget _buildList() {
    return Consumer<AnakProvider>(
      builder: (_, p, __) {
        if (p.isLoading && p.anakList.isEmpty) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _SkeletonCard(),
                ),
                childCount: 3,
              ),
            ),
          );
        }

        if (p.errorMessage != null && p.anakList.isEmpty) {
          return SliverFillRemaining(child: _errorState(p));
        }

        final list = _filtered(p.anakList);

        if (list.isEmpty) {
          return SliverFillRemaining(child: _emptyState());
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i == list.length) {
                  return p.hasMore
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _primary,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }
                return _AnakCardItem(
                  anak: list[i],
                  index: i,
                  onDetail: () => _onDetail(list[i]),
                  onEdit: () => _onEdit(list[i]),
                  onHapus: () => _onHapus(list[i]),
                  onInput: () => _onInput(list[i]),
                );
              },
              childCount: list.length + 1,
            ),
          ),
        );
      },
    );
  }

  // ── Empty & Error ─────────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(color: _primaryBg, shape: BoxShape.circle),
          child: const Icon(Icons.child_care_rounded, color: _primary, size: 44),
        ),
        const SizedBox(height: 18),
        const Text(
          'Belum ada data balita',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tambahkan balita pertama di\nwilayah posyandu Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: _textGrey, height: 1.5),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _onTambah,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Tambah Balita'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ],
    ),
  );

  Widget _errorState(AnakProvider p) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_rounded, size: 52, color: _textGrey),
        const SizedBox(height: 14),
        const Text(
          'Gagal memuat data',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark),
        ),
        const SizedBox(height: 6),
        Text(
          p.errorMessage ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: _textGrey),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => p.fetchAll(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Coba Lagi'),
        ),
      ],
    ),
  );

  // ── FAB ───────────────────────────────────────────────────────────
  Widget _fab() => FloatingActionButton(
    onPressed: _onTambah,
    backgroundColor: _primary,
    shape: const CircleBorder(),
    elevation: 4,
    child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
  );

  // ── Bottom Nav ────────────────────────────────────────────────────
  Widget _bottomNav() {
    const items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
      _NavItem(icon: Icons.child_care_outlined, activeIcon: Icons.child_care_rounded, label: 'Data Balita'),
      _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Jadwal'),
      _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = _navIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? _primaryBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        active ? items[i].activeIcon : items[i].icon,
                        color: active ? _primary : _textGrey,
                        size: 22,
                      ),
                      if (active) ...[
                        const SizedBox(width: 6),
                        Text(
                          items[i].label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────
  void _onTambah() {
    // TODO: Navigate to form tambah anak
    _snack('Buka form tambah balita');
  }

  void _onDetail(AnakModel anak) {
    // TODO: Navigate to detail anak
    _snack('Detail: ${anak.namaAnak}');
  }

  void _onEdit(AnakModel anak) {
    // TODO: Navigate to edit anak
    _snack('Edit: ${anak.namaAnak}');
  }

  void _onInput(AnakModel anak) {
    // TODO: Navigate to input pemeriksaan
    _snack('Input pemeriksaan: ${anak.namaAnak}');
  }

  Future<void> _onHapus(AnakModel anak) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Data Anak?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Data ${anak.namaAnak} akan dihapus permanen.\nTindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: _textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      final success = await context.read<AnakProvider>().delete(anak.nikAnak);
      if (mounted) {
        _snack(
          success ? '${anak.namaAnak} berhasil dihapus' : 'Gagal menghapus data',
          isError: !success,
        );
      }
    }
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        onSort: (s) {
          Navigator.pop(context);
          _snack('Diurutkan: $s');
        },
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _danger : _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ANAK CARD ITEM
// ══════════════════════════════════════════════════════════════════════
class _AnakCardItem extends StatelessWidget {
  final AnakModel anak;
  final int index;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onHapus;
  final VoidCallback onInput;

  static const _primary   = Color(0xFF0D6EFD);
  static const _primaryBg = Color(0xFFEAF4FF);
  static const _textDark  = Color(0xFF1E293B);
  static const _textGrey  = Color(0xFF64748B);
  static const _danger    = Color(0xFFEF4444);
  static const _dangerBg  = Color(0xFFFEE2E2);

  const _AnakCardItem({
    required this.anak,
    required this.index,
    required this.onDetail,
    required this.onEdit,
    required this.onHapus,
    required this.onInput,
  });

  @override
  Widget build(BuildContext context) {
    final isLaki   = anak.jenisKelamin == 'L';
    final initial  = anak.namaAnak.isNotEmpty ? anak.namaAnak[0].toUpperCase() : 'A';
    final avatarBg = isLaki ? _primaryBg : const Color(0xFFFCE8F3);
    final avatarFg = isLaki ? _primary : const Color(0xFFAE0B6A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: avatarBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: avatarFg.withOpacity(0.2), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: avatarFg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anak.namaAnak,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          anak.nikAnak,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textGrey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Gender badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: avatarBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isLaki ? '♂ L' : '♀ P',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: avatarFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ───────────────────────────────────────────
            Container(height: 1, color: const Color(0xFFF1F5F9)),

            // ── Action Buttons ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionBtn(
                    icon: Icons.remove_red_eye_outlined,
                    label: 'Detail',
                    iconColor: _primary,
                    bgColor: _primaryBg,
                    onTap: onDetail,
                  ),
                  _ActionBtn(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    iconColor: const Color(0xFF64748B),
                    bgColor: const Color(0xFFF1F5F9),
                    onTap: onEdit,
                  ),
                  _ActionBtn(
                    icon: Icons.delete_outline_rounded,
                    label: 'Hapus',
                    iconColor: _danger,
                    bgColor: _dangerBg,
                    onTap: onHapus,
                  ),
                  _ActionBtn(
                    icon: Icons.assignment_outlined,
                    label: 'Input',
                    iconColor: Colors.white,
                    bgColor: _primary,
                    onTap: onInput,
                    isSolid: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;
  final bool isSolid;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: isSolid
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0D6EFD).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSolid ? const Color(0xFF0D6EFD) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton Card ─────────────────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _bone(58, 58, radius: 29, opacity: _anim.value),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(140, 16, opacity: _anim.value),
                      const SizedBox(height: 8),
                      _bone(100, 12, opacity: _anim.value),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: const Color(0xFFF1F5F9)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (_) => Column(
                  children: [
                    _bone(48, 48, radius: 24, opacity: _anim.value),
                    const SizedBox(height: 6),
                    _bone(32, 10, opacity: _anim.value),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bone(double w, double h,
      {double radius = 8, required double opacity}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, opacity * 0.08),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Filter Bottom Sheet ───────────────────────────────────────────────
class _FilterSheet extends StatelessWidget {
  final void Function(String) onSort;
  const _FilterSheet({required this.onSort});

  static const _primary  = Color(0xFF0D6EFD);
  static const _textDark = Color(0xFF1E293B);
  static const _textGrey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final options = [
      _SortOption(icon: Icons.sort_by_alpha_rounded, label: 'Nama A–Z'),
      _SortOption(icon: Icons.arrow_upward_rounded,  label: 'Usia Termuda'),
      _SortOption(icon: Icons.arrow_downward_rounded,label: 'Usia Tertua'),
      _SortOption(icon: Icons.access_time_rounded,   label: 'Terbaru Ditambahkan'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Urutkan Data',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih cara menampilkan data balita',
            style: TextStyle(fontSize: 13, color: _textGrey),
          ),
          const SizedBox(height: 16),
          ...options.map((o) => ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(o.icon, color: _primary, size: 20),
            ),
            title: Text(
              o.label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textDark),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: _textGrey, size: 20),
            contentPadding: EdgeInsets.zero,
            onTap: () => onSort(o.label),
          )),
        ],
      ),
    );
  }
}

// ── Data Classes ──────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _SortOption {
  final IconData icon;
  final String label;
  const _SortOption({required this.icon, required this.label});
}