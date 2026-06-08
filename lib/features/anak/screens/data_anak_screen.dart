// lib/features/anak/screens/data_anak_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/anak_provider.dart';
import '../models/anak_model.dart';
import '../../auth/providers/auth_provider.dart';

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

  Future<void> _konfirmasiHapus(BuildContext context, AnakModel anak) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data Balita'),
        content: Text('Yakin ingin menghapus data ${anak.namaAnak}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: _danger))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<AnakProvider>();
      final success  = await provider.hapusAnak(anak.nikAnak);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'Data ${anak.namaAnak} berhasil dihapus.'
              : provider.errorMessage ?? 'Gagal menghapus.'),
          backgroundColor: success ? const Color(0xFF198754) : _danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role    = context.read<AuthProvider>().user?.role ?? '';
    final isKader = role == 'Kader';

    return Scaffold(
      backgroundColor: _background,
      // ── AppBar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _cardWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.child_care_rounded, color: _primary, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Data Balita',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark)),
        ]),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kelola informasi kesehatan dan pertumbuhan anak di wilayah Posyandu Anda.',
                  style: const TextStyle(fontSize: 12, color: _textGrey, height: 1.4),
                ),
              ),
            ),
            Container(height: 1, color: _border),
          ]),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search + Filter ────────────────────────────────
          Container(
            color: _cardWhite,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(children: [
              // Search
              Container(
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
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Filter tab
              Row(children: [
                _buildFilterTab('Semua'),
                const SizedBox(width: 8),
                _buildFilterTab('Laki-laki', value: 'L'),
                const SizedBox(width: 8),
                _buildFilterTab('Perempuan', value: 'P'),
              ]),
            ]),
          ),
          Container(height: 1, color: _border),

          // ── List Balita ────────────────────────────────────
          Expanded(
            child: Consumer<AnakProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: _primary));
                }

                if (provider.status == AnakStatus.error) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text(provider.errorMessage ?? 'Gagal memuat',
                        style: const TextStyle(color: _textGrey)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => provider.loadAnakList(), child: const Text('Coba Lagi')),
                  ]));
                }

                final filtered = _filtered(provider.anakList);

                if (filtered.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.child_care_rounded, color: _primary, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text('Belum ada data balita',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark)),
                    const SizedBox(height: 8),
                    const Text('Belum ada balita terdaftar', style: TextStyle(color: _textGrey)),
                  ]));
                }

                return RefreshIndicator(
                  color: _primary,
                  onRefresh: () => provider.loadAnakList(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildAnakCard(context, filtered[index], provider, isKader),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isKader
          ? FloatingActionButton(
              onPressed: () => context.push('/anak/tambah'),
              backgroundColor: _primary,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

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
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : _textGrey,
            )),
      ),
    );
  }

  Widget _buildAnakCard(BuildContext context, AnakModel anak, AnakProvider provider, bool isKader) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
              child: Icon(
                anak.isLakiLaki ? Icons.face_rounded : Icons.face_3_rounded,
                color: anak.isLakiLaki ? _primary : const Color(0xFFE91E63),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(anak.namaAnak,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
              const SizedBox(height: 2),
              Text(anak.nikAnak, style: const TextStyle(fontSize: 12, color: _textGrey)),
            ])),
            // Badge jenis kelamin
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: anak.isLakiLaki ? const Color(0xFFEAF2FF) : const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                anak.isLakiLaki ? 'L' : 'P',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: anak.isLakiLaki ? _primary : const Color(0xFFE91E63),
                ),
              ),
            ),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: isKader
              ? Row(children: [
                  Expanded(child: _buildActionBtn(icon: Icons.visibility_outlined, label: 'Detail',
                      color: _primary, onTap: () => context.push('/anak/${anak.nikAnak}'))),
                  Expanded(child: _buildActionBtn(icon: Icons.edit_outlined, label: 'Edit',
                      color: _textGrey, onTap: () => context.push('/anak/tambah', extra: anak))),
                  Expanded(child: _buildActionBtn(icon: Icons.delete_outline_rounded, label: 'Hapus',
                      color: _danger, onTap: () => _konfirmasiHapus(context, anak))),
                ])
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _buildActionBtn(icon: Icons.visibility_outlined, label: 'Lihat Detail',
                      color: _primary, onTap: () => context.push('/anak/${anak.nikAnak}')),
                ]),
        ),
      ]),
    );
  }

  Widget _buildActionBtn({
    required IconData icon, required String label,
    required Color color, required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}