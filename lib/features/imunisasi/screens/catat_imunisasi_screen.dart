// lib/features/imunisasi/screens/catat_imunisasi_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/imunisasi_provider.dart';
import '../models/imunisasi_model.dart';
import '../../anak/providers/anak_provider.dart';
import '../../anak/models/anak_model.dart';

class CatatImunisasiScreen extends StatefulWidget {
  final String nikAnak;
  const CatatImunisasiScreen({super.key, required this.nikAnak});

  @override
  State<CatatImunisasiScreen> createState() =>
      _CatatImunisasiScreenState();
}

class _CatatImunisasiScreenState extends State<CatatImunisasiScreen> {
  static const Color _primary    = Color(0xFF6F42C1);
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
      context.read<ImunisasiProvider>().loadJenisVaksin();
    });
  }

  void _showInputImunisasi(AnakModel anak) {
    showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  // Tambah ini:
  builder: (_) => Padding(
    padding: MediaQuery.of(context).viewInsets,
    child: _ImunisasiBottomSheet(anak: anak),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Catat Imunisasi'),
        backgroundColor: _cardWhite,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  'Tap balita untuk mencatat\npemberian imunisasi/vaksin.',
                  style: TextStyle(
                      fontSize: 13, color: _textGrey, height: 1.4),
                ),
              ],
            ),
          ),

          // List balita
          Expanded(
            child: Consumer<AnakProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: _primary),
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
                            color: const Color(0xFFF0EBFF),
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

  Widget _buildAnakTile(AnakModel anak) {
    return GestureDetector(
      onTap: () => _showInputImunisasi(anak),
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
                color: const Color(0xFFF0EBFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                anak.isLakiLaki
                    ? Icons.face_rounded
                    : Icons.face_3_rounded,
                color: _primary,
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
                color: const Color(0xFFF0EBFF),
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

// ── Bottom Sheet Input Imunisasi ──────────────────────────
class _ImunisasiBottomSheet extends StatefulWidget {
  final AnakModel anak;
  const _ImunisasiBottomSheet({required this.anak});

  @override
  State<_ImunisasiBottomSheet> createState() =>
      _ImunisasiBottomSheetState();
}

class _ImunisasiBottomSheetState
    extends State<_ImunisasiBottomSheet> {
  final _catatanCtrl = TextEditingController();

  JenisVaksinModel? _selectedVaksin;
  DateTime          _tglPemberian = DateTime.now();

  static const Color _primary  = Color(0xFF6F42C1);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);
  static const Color _inputBg  = Color(0xFFF1F5F9);

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  String get _tglFormatted =>
      '${_tglPemberian.year}-'
      '${_tglPemberian.month.toString().padLeft(2, '0')}-'
      '${_tglPemberian.day.toString().padLeft(2, '0')}';

  String get _tglDisplay =>
      '${_tglPemberian.day.toString().padLeft(2, '0')} / '
      '${_tglPemberian.month.toString().padLeft(2, '0')} / '
      '${_tglPemberian.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglPemberian,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tglPemberian = picked);
  }

  Future<void> _submit() async {
    if (_selectedVaksin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis vaksin terlebih dahulu'),
          backgroundColor: Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<ImunisasiProvider>();
    final success  = await provider.catat(
      nikAnak:      widget.anak.nikAnak,
      idVaksin:     _selectedVaksin!.idVaksin,
      tglPemberian: _tglFormatted,
      catatan: _catatanCtrl.text.trim().isEmpty
          ? null
          : _catatanCtrl.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Imunisasi ${widget.anak.namaAnak} berhasil dicatat!'
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
    return Consumer<ImunisasiProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
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
                    color: const Color(0xFFF0EBFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.vaccines_outlined,
                      color: _primary, size: 28),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Catat Imunisasi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Input pemberian vaksin kepada balita',
                  style: TextStyle(fontSize: 13, color: _textGrey),
                ),
                const SizedBox(height: 12),

                // Badge nama anak
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBFF),
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

                // ── Pilih Vaksin ───────────────────────
                _buildLabel('JENIS VAKSIN *'),
                const SizedBox(height: 8),
                provider.jenisVaksin.isEmpty
                    ? Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: _inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _primary),
                          ),
                        ),
                      )
                    : DropdownButtonFormField<JenisVaksinModel>(
                        value: _selectedVaksin,
                        hint: const Text('Pilih jenis vaksin'),
                        items: provider.jenisVaksin
                            .map((v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v.namaVaksin),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedVaksin = val),
                        icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF94A3B8)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _inputBg,
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: _primary, width: 1.5),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        isExpanded: true,
                      ),
                const SizedBox(height: 16),

                // ── Tanggal Pemberian ──────────────────
                _buildLabel('TANGGAL PEMBERIAN'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    height: 52,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _primary, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: _primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _tglDisplay,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textDark,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.edit_outlined,
                            color: _textGrey, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Catatan ───────────────────────────
                _buildLabel('CATATAN (OPSIONAL)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _catatanCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Catatan tambahan...',
                    hintStyle: const TextStyle(
                        color: Color(0xFFCBD5E1)),
                    filled: true,
                    fillColor: _inputBg,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: _primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Tombol Simpan ─────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: provider.isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16)),
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
                      provider.isSaving
                          ? 'Menyimpan...'
                          : 'Simpan Imunisasi',
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
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _textGrey,
          letterSpacing: 1,
        ),
      ),
    );
  }
}