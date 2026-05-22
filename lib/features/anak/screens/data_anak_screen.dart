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
            child: const Text('Hapus',
                style: TextStyle(color: _danger)),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
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
        title: const Text('Data Balita'),
        actions: [
          IconButton(
            onPressed: () => context.push('/anak/tambah'),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah Balita',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: _cardWhite,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextFormField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIK balita...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFF94A3B8), size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Color(0xFF94A3B8), size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List anak
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
                        Text(
                            provider.errorMessage ?? 'Gagal memuat data',
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

                if (provider.anakList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.child_care_rounded,
                              color: _primary, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text('Belum ada data balita',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _textDark)),
                        const SizedBox(height: 8),
                        const Text('Tap + untuk menambah balita baru',
                            style: TextStyle(color: _textGrey)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () =>
                              context.push('/anak/tambah'),
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
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.anakList.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final anak = provider.anakList[index];
                      return _buildAnakCard(context, anak, provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnakCard(
      BuildContext context, AnakModel anak, AnakProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/anak/${anak.nikAnak}'),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: anak.isLakiLaki
                        ? const Color(0xFFEAF2FF)
                        : const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    anak.isLakiLaki
                        ? Icons.face_rounded
                        : Icons.face_3_rounded,
                    color: anak.isLakiLaki
                        ? _primary
                        : const Color(0xFFE91E63),
                    size: 26,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(anak.nikAnak,
                          style: const TextStyle(
                              fontSize: 12, color: _textGrey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: anak.isLakiLaki
                                  ? const Color(0xFFEAF2FF)
                                  : const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              anak.jenisKelaminLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: anak.isLakiLaki
                                    ? _primary
                                    : const Color(0xFFE91E63),
                              ),
                            ),
                          ),
                          if (anak.umurFormat != null) ...[
                            const SizedBox(width: 8),
                            Text(anak.umurFormat!,
                                style: const TextStyle(
                                    fontSize: 12, color: _textGrey)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions popup menu
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'detail':
                        context.push('/anak/${anak.nikAnak}');
                        break;
                      case 'periksa':
                        context.push(
                            '/pemeriksaan/catat?nik_anak=${anak.nikAnak}');
                        break;
                      case 'edit':
                        context.push('/anak/tambah', extra: anak);
                        break;
                      case 'hapus':
                        _konfirmasiHapus(context, anak);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'detail',
                      child: Row(children: [
                        Icon(Icons.info_outline_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Detail'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'periksa',
                      child: Row(children: [
                        Icon(Icons.monitor_heart_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Catat Pemeriksaan'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'hapus',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: _danger),
                        SizedBox(width: 10),
                        Text('Hapus',
                            style: TextStyle(color: _danger)),
                      ]),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert_rounded,
                      color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}