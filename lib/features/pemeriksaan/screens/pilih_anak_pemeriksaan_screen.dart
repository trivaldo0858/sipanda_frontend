// lib/features/pemeriksaan/screens/pilih_anak_pemeriksaan_screen.dart
// Screen ini KHUSUS untuk memilih balita sebelum catat pemeriksaan
// Tidak ada tombol Detail/Edit/Hapus

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/pemeriksaan_provider.dart';
import '../../anak/providers/anak_provider.dart';
import '../../anak/models/anak_model.dart';

class PilihAnakPemeriksaanScreen extends StatefulWidget {
  const PilihAnakPemeriksaanScreen({super.key});

  @override
  State<PilihAnakPemeriksaanScreen> createState() =>
      _PilihAnakPemeriksaanScreenState();
}

class _PilihAnakPemeriksaanScreenState
    extends State<PilihAnakPemeriksaanScreen> {
  final _searchCtrl = TextEditingController();

  static const Color _primary    = Color(0xFF0D6EFD);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textGrey   = Color(0xFF64748B);
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _cardWhite  = Color(0xFFFFFFFF);
  static const Color _border     = Color(0xFFE2E8F0);

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

  void _showInputPemeriksaan(AnakModel anak) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PemeriksaanBottomSheet(anak: anak),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Catat Pemeriksaan'),
        backgroundColor: _cardWhite,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Search
          Container(
            color: _cardWhite,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Balita',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap balita untuk mencatat\nhasil pemeriksaan.',
                  style: TextStyle(
                      fontSize: 13, color: _textGrey, height: 1.4),
                ),
                const SizedBox(height: 14),
                // Search bar
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
                      hintStyle: TextStyle(
                          fontSize: 14, color: Color(0xFFCBD5E1)),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Color(0xFF94A3B8), size: 20),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List balita — HANYA untuk dipilih, tidak ada aksi lain
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
                            provider.errorMessage ?? 'Gagal memuat',
                            style:
                                const TextStyle(color: _textGrey)),
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
                        const Text(
                          'Tambah balita terlebih dahulu\ndi menu Data Balita.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _textGrey),
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
                      return _buildAnakTile(anak);
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

  // Card sederhana — TAP untuk pilih, tidak ada Detail/Edit/Hapus
  Widget _buildAnakTile(AnakModel anak) {
    return GestureDetector(
      onTap: () => _showInputPemeriksaan(anak),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: anak.isLakiLaki
                    ? const Color(0xFFEAF2FF)
                    : const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(12),
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
                  if (anak.umurFormat != null)
                    Text(anak.umurFormat!,
                        style: const TextStyle(
                            fontSize: 12, color: _textGrey)),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_right_rounded,
                  color: _primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Sheet Input Pemeriksaan ────────────────────────
class _PemeriksaanBottomSheet extends StatefulWidget {
  final AnakModel anak;
  const _PemeriksaanBottomSheet({required this.anak});

  @override
  State<_PemeriksaanBottomSheet> createState() =>
      _PemeriksaanBottomSheetState();
}

class _PemeriksaanBottomSheetState
    extends State<_PemeriksaanBottomSheet> {
  final _formKey     = GlobalKey<FormState>();
  final _beratCtrl   = TextEditingController();
  final _tinggiCtrl  = TextEditingController();
  final _lingkarCtrl = TextEditingController();

  static const Color _primary  = Color(0xFF0D6EFD);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);
  static const Color _inputBg  = Color(0xFFF1F5F9);

  DateTime _tglPeriksa = DateTime.now();

  @override
  void dispose() {
    _beratCtrl.dispose();
    _tinggiCtrl.dispose();
    _lingkarCtrl.dispose();
    super.dispose();
  }

  String get _tglFormatted =>
      '${_tglPeriksa.year}-'
      '${_tglPeriksa.month.toString().padLeft(2, '0')}-'
      '${_tglPeriksa.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PemeriksaanProvider>();
    final success  = await provider.catat(
      nikAnak:       widget.anak.nikAnak,
      tglPeriksa:    _tglFormatted,
      beratBadan:    double.parse(_beratCtrl.text.trim()),
      tinggiBadan:   double.parse(_tinggiCtrl.text.trim()),
      lingkarKepala: double.parse(_lingkarCtrl.text.trim()),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Pemeriksaan ${widget.anak.namaAnak} berhasil disimpan!'
              : provider.errorMessage ?? 'Gagal menyimpan.'),
          backgroundColor: success
              ? const Color(0xFF198754)
              : const Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      if (success && mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PemeriksaanProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 28,
            right: 28,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.edit_note_rounded,
                        color: _primary, size: 28),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Input Perkembangan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lengkapi data pertumbuhan rutin Balita',
                    style: TextStyle(fontSize: 13, color: _textGrey),
                  ),
                  const SizedBox(height: 12),

                  // Badge nama anak
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.child_care_rounded,
                            color: _primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          widget.anak.namaAnak,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fields
                  _buildField(
                    label: 'BERAT BADAN (KG)',
                    controller: _beratCtrl,
                    hint: '0.0',
                    suffix: 'kg',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (double.tryParse(v) == null)
                        return 'Angka tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'TINGGI BADAN (CM)',
                    controller: _tinggiCtrl,
                    hint: '0.0',
                    suffix: 'cm',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (double.tryParse(v) == null)
                        return 'Angka tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'LINGKAR KEPALA (CM)',
                    controller: _lingkarCtrl,
                    hint: '0.0',
                    suffix: 'cm',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi';
                      if (double.tryParse(v) == null)
                        return 'Angka tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: provider.isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: provider.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5))
                          : const Icon(Icons.save_outlined,
                              color: Colors.white, size: 20),
                      label: Text(
                        provider.isSaving ? 'Menyimpan...' : 'Simpan Data',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal',
                        style: TextStyle(
                            fontSize: 14, color: _textGrey)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String suffix,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textGrey,
              letterSpacing: 1,
            )),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'^\d+\.?\d{0,1}')),
          ],
          validator: validator,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 16, color: Color(0xFFCBD5E1)),
            filled: true,
            fillColor: _inputBg,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            suffixText: suffix,
            suffixStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFDC3545)),
            ),
          ),
        ),
      ],
    );
  }
}