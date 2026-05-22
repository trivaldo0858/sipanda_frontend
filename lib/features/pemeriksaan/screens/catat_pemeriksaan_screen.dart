// lib/features/pemeriksaan/screens/catat_pemeriksaan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/pemeriksaan_provider.dart';

class CatatPemeriksaanScreen extends StatefulWidget {
  final String nikAnak;
  const CatatPemeriksaanScreen({super.key, required this.nikAnak});

  @override
  State<CatatPemeriksaanScreen> createState() =>
      _CatatPemeriksaanScreenState();
}

class _CatatPemeriksaanScreenState extends State<CatatPemeriksaanScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _beratCtrl     = TextEditingController();
  final _tinggiCtrl    = TextEditingController();
  final _lingkarCtrl   = TextEditingController();
  final _keluhanCtrl   = TextEditingController();

  DateTime _tglPeriksa = DateTime.now();

  static const Color _primary    = Color(0xFF0D6EFD);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textGrey   = Color(0xFF64748B);
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _border     = Color(0xFFE2E8F0);

  @override
  void dispose() {
    _beratCtrl.dispose();
    _tinggiCtrl.dispose();
    _lingkarCtrl.dispose();
    _keluhanCtrl.dispose();
    super.dispose();
  }

  String get _tglDisplay {
    return '${_tglPeriksa.day.toString().padLeft(2, '0')} / '
        '${_tglPeriksa.month.toString().padLeft(2, '0')} / '
        '${_tglPeriksa.year}';
  }

  String get _tglFormatted {
    return '${_tglPeriksa.year}-'
        '${_tglPeriksa.month.toString().padLeft(2, '0')}-'
        '${_tglPeriksa.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglPeriksa,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Pemeriksaan',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tglPeriksa = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PemeriksaanProvider>();
    final success  = await provider.catat(
      nikAnak:       widget.nikAnak,
      tglPeriksa:    _tglFormatted,
      beratBadan:    double.parse(_beratCtrl.text.trim()),
      tinggiBadan:   double.parse(_tinggiCtrl.text.trim()),
      lingkarKepala: double.parse(_lingkarCtrl.text.trim()),
      keluhan: _keluhanCtrl.text.trim().isEmpty
          ? null
          : _keluhanCtrl.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? provider.successMessage ?? 'Berhasil!'
              : provider.errorMessage ?? 'Gagal menyimpan.'),
          backgroundColor:
              success ? const Color(0xFF198754) : const Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      if (success) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Catat Pemeriksaan'),
      ),
      body: Consumer<PemeriksaanProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info anak
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.child_care_rounded,
                            color: _primary, size: 20),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('NIK Balita',
                                style: TextStyle(
                                    fontSize: 11, color: _textGrey)),
                            Text(
                              widget.nikAnak,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Tanggal Periksa ──────────────────
                  _buildSection('Tanggal Pemeriksaan'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      height: 52,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primary, width: 1.5),
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
                  const SizedBox(height: 24),

                  // ── Data Pengukuran ──────────────────
                  _buildSection('Data Pengukuran (KF-005)'),
                  const SizedBox(height: 14),

                  // Berat Badan
                  _buildLabel('Berat Badan (kg) *'),
                  const SizedBox(height: 6),
                  _buildNumberField(
                    controller: _beratCtrl,
                    hint: 'Contoh: 8.5',
                    suffix: 'kg',
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Berat badan wajib diisi';
                      if (double.tryParse(v) == null)
                        return 'Masukkan angka yang valid';
                      if (double.parse(v) <= 0)
                        return 'Berat harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tinggi Badan
                  _buildLabel('Tinggi Badan (cm) *'),
                  const SizedBox(height: 6),
                  _buildNumberField(
                    controller: _tinggiCtrl,
                    hint: 'Contoh: 75.0',
                    suffix: 'cm',
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Tinggi badan wajib diisi';
                      if (double.tryParse(v) == null)
                        return 'Masukkan angka yang valid';
                      if (double.parse(v) <= 0)
                        return 'Tinggi harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Lingkar Kepala
                  _buildLabel('Lingkar Kepala (cm) *'),
                  const SizedBox(height: 6),
                  _buildNumberField(
                    controller: _lingkarCtrl,
                    hint: 'Contoh: 42.0',
                    suffix: 'cm',
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Lingkar kepala wajib diisi';
                      if (double.tryParse(v) == null)
                        return 'Masukkan angka yang valid';
                      if (double.parse(v) <= 0)
                        return 'Lingkar kepala harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Keluhan ──────────────────────────
                  _buildSection('Keluhan (Opsional)'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _keluhanCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Tuliskan keluhan balita jika ada...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: _primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Tombol Simpan ────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: provider.isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: provider.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Icon(Icons.save_outlined,
                              color: Colors.white, size: 20),
                      label: Text(
                        provider.isSaving
                            ? 'Menyimpan...'
                            : 'Simpan Pemeriksaan',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol Batal
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Batal',
                          style: TextStyle(color: _textGrey)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textDark)),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textGrey));
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
    required String suffix,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
      ],
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixText: suffix,
        suffixStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFDC3545)),
        ),
      ),
    );
  }
}