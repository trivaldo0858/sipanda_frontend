// lib/features/anak/screens/data_anak_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/anak_provider.dart';
import '../models/anak_model.dart';

class DataAnakScreen extends StatefulWidget {
  const DataAnakScreen({super.key});

  @override
  State<DataAnakScreen> createState() => _DataAnakScreenState();
}

class _DataAnakScreenState extends State<DataAnakScreen> {
  final _searchCtrl = TextEditingController();
  String _filterJK  = 'Semua';

  static const Color _primary    = Color(0xFF0D6EFD);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textGrey   = Color(0xFF64748B);
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _cardWhite  = Color(0xFFFFFFFF);
  static const Color _border     = Color(0xFFE2E8F0);
  static const Color _danger     = Color(0xFFDC3545);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnakProvider>().loadAnakList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    context.read<AnakProvider>().loadAnakList(
          search: value.isEmpty ? null : value,
        );
  }

  List<AnakModel> _filtered(List<AnakModel> list) {
    if (_filterJK == 'Semua') return list;
    return list.where((a) => a.jenisKelamin == _filterJK).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Filter Data Balita',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
                  const SizedBox(height: 16),
                  const Text('Jenis Kelamin',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textGrey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _filterChipOption('Semua', setSheetState),
                      const SizedBox(width: 10),
                      _filterChipOption('Laki-laki', setSheetState, value: 'L'),
                      const SizedBox(width: 10),
                      _filterChipOption('Perempuan', setSheetState, value: 'P'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterChipOption(String label, StateSetter setSheetState, {String? value}) {
    final chipValue  = value ?? 'Semua';
    final isSelected = _filterJK == chipValue;
    return GestureDetector(
      onTap: () {
        setSheetState(() => _filterJK = chipValue);
        setState(() => _filterJK = chipValue);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : _textGrey,
          ),
        ),
      ),
    );
  }

  Future<void> _konfirmasiHapus(BuildContext context, AnakModel anak) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data Balita'),
        content: Text('Yakin ingin menghapus data ${anak.namaAnak}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<AnakProvider>();
      final success  = await provider.hapusAnak(anak.nikAnak);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Data ${anak.namaAnak} berhasil dihapus.'
                : provider.errorMessage ?? 'Gagal menghapus.'),
            backgroundColor: success ? const Color(0xFF198754) : _danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _cardWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Data Anak',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────
          Container(
            color: _cardWhite,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Balita',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola informasi kesehatan dan pertumbuhan anak\ndi wilayah Posyandu Anda.',
                  style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4),
                ),
                const SizedBox(height: 16),

                // Search + Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _onSearch,
                          decoration: const InputDecoration(
                            hintText: 'Cari nama atau NIK...',
                            hintStyle: TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: Color(0xFF94A3B8), size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: _filterJK != 'Semua'
                              ? _primary
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: _filterJK != 'Semua' ? Colors.white : _primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Filter chip tab ────────────────
                Row(
                  children: [
                    _buildFilterTab('Semua'),
                    const SizedBox(width: 8),
                    _buildFilterTab('Laki-laki', value: 'L'),
                    const SizedBox(width: 8),
                    _buildFilterTab('Perempuan', value: 'P'),
                  ],
                ),

                // Badge filter aktif
                if (_filterJK != 'Semua') ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _filterJK == 'L' ? 'Laki-laki' : 'Perempuan',
                              style: const TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w600, color: _primary),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _filterJK = 'Semua'),
                              child: const Icon(Icons.close_rounded, size: 14, color: _primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── List Balita ───────────────────────────
          Expanded(
            child: Consumer<AnakProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primary),
                  );
                }

                if (provider.status == AnakStatus.error) {
                  return Center(
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
                          onPressed: () => provider.loadAnakList(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final filtered = _filtered(provider.anakList);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.child_care_rounded,
                              color: _primary, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text('Belum ada data balita',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w600, color: _textDark)),
                        const SizedBox(height: 8),
                        const Text('Tap + untuk menambah balita baru',
                            style: TextStyle(color: _textGrey)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/anak/tambah'),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Tambah Balita'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: _primary,
                  onRefresh: () => provider.loadAnakList(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildAnakCard(context, filtered[index], provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/anak/tambah'),
        backgroundColor: _primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  // ── Filter Tab ────────────────────────────────────────
  Widget _buildFilterTab(String label, {String? value}) {
    final chipValue  = value ?? 'Semua';
    final isSelected = _filterJK == chipValue;
    return GestureDetector(
      onTap: () => setState(() => _filterJK = chipValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : _textGrey,
          ),
        ),
      ),
    );
  }

  // ── Kartu Balita ──────────────────────────────────────
  Widget _buildAnakCard(
      BuildContext context, AnakModel anak, AnakProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          // Info anak
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // Avatar bulat
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    anak.isLakiLaki ? Icons.face_rounded : Icons.face_3_rounded,
                    color: anak.isLakiLaki ? _primary : const Color(0xFFE91E63),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anak.namaAnak,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(anak.nikAnak,
                          style: const TextStyle(fontSize: 13, color: _textGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Tombol aksi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    icon: Icons.visibility_outlined,
                    label: 'Detail',
                    color: _primary,
                    onTap: () => context.push('/anak/${anak.nikAnak}'),
                  ),
                ),
                Expanded(
                  child: _buildActionBtn(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: _textGrey,
                    onTap: () => context.push('/anak/tambah', extra: anak),
                  ),
                ),
                Expanded(
                  child: _buildActionBtn(
                    icon: Icons.delete_outline_rounded,
                    label: 'Hapus',
                    color: _danger,
                    onTap: () => _konfirmasiHapus(context, anak),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}