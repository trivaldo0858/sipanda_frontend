// lib/features/anak/screens/form_tambah_anak_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/anak_provider.dart';
import '../models/anak_model.dart';

class FormTambahAnakScreen extends StatefulWidget {
  final AnakModel? anakEdit;
  const FormTambahAnakScreen({super.key, this.anakEdit});

  @override
  State<FormTambahAnakScreen> createState() => _FormTambahAnakScreenState();
}

class _FormTambahAnakScreenState extends State<FormTambahAnakScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _namaAnakCtrl = TextEditingController();
  final _nikAnakCtrl  = TextEditingController();
  final _namaIbuCtrl  = TextEditingController();
  final _alamatCtrl   = TextEditingController();

  String    _jenisKelamin = 'L';
  DateTime? _tglLahir;

  bool get isEditMode => widget.anakEdit != null;

  static const Color _primary    = Color(0xFF0D6EFD);
  static const Color _primaryDark = Color(0xFF0A58CA);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textGrey   = Color(0xFF64748B);
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _border     = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final a = widget.anakEdit!;
      _nikAnakCtrl.text  = a.nikAnak;
      _namaAnakCtrl.text = a.namaAnak;
      _namaIbuCtrl.text  = a.namaIbu ?? '';
      _alamatCtrl.text   = a.alamat ?? '';
      _jenisKelamin      = a.jenisKelamin;
      _tglLahir          = DateTime.tryParse(a.tglLahir);
    }
  }

  @override
  void dispose() {
    _namaAnakCtrl.dispose();
    _nikAnakCtrl.dispose();
    _namaIbuCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  String get _tglLahirFormatted {
    if (_tglLahir == null) return '';
    return '${_tglLahir!.year}-'
        '${_tglLahir!.month.toString().padLeft(2, '0')}-'
        '${_tglLahir!.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime(2022),
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir Balita',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tglLahir = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tglLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal lahir balita'),
          backgroundColor: Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<AnakProvider>();
    bool success;

    if (isEditMode) {
      success = await provider.updateAnak(
        nikAnak:      _nikAnakCtrl.text.trim(),
        namaAnak:     _namaAnakCtrl.text.trim(),
        namaIbu:      _namaIbuCtrl.text.trim(),
        tglLahir:     _tglLahirFormatted,
        jenisKelamin: _jenisKelamin,
        namaAyah:     '',
        nikOrangTua:  '',
      );
    } else {
      success = await provider.tambahAnak(
        nikAnak:      _nikAnakCtrl.text.trim(),
        nikOrangTua:  '',
        namaAnak:     _namaAnakCtrl.text.trim(),
        namaIbu:      _namaIbuCtrl.text.trim(),
        tglLahir:     _tglLahirFormatted,
        jenisKelamin: _jenisKelamin,
        namaAyah:     '',
        alamat:       _alamatCtrl.text.trim().isEmpty
            ? null : _alamatCtrl.text.trim(),
      );
    }

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
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom AppBar ──────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_box_outlined,
                        color: _primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditMode ? 'Edit Data Balita' : 'Input Data Balita',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded,
                        color: _textDark, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // ── Form Content ───────────────────────────────
            Expanded(
              child: Consumer<AnakProvider>(
                builder: (context, provider, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isEditMode ? 'EDIT DATA' : 'REGISTRASI BARU',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Judul
                          const Text(
                            'Lengkapi Profil\nSi Kecil',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pastikan data yang dimasukkan sesuai dengan Kartu Keluarga atau KIA untuk akurasi pemantauan tumbuh kembang.',
                            style: TextStyle(
                              fontSize: 13,
                              color: _textGrey,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Nama Balita ─────────────────
                          _buildLabel('NAMA BALITA'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _namaAnakCtrl,
                            hint: 'Contoh: Ahmad Fauzan',
                            capitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Nama balita wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // ── NIK ─────────────────────────
                          _buildLabel('NOMOR INDUK KEPENDUDUKAN (NIK)'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nikAnakCtrl,
                            hint: '16 digit nomor kependudukan',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: 16,
                            readOnly: isEditMode,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'NIK wajib diisi';
                              if (v.length < 16) return 'NIK harus 16 digit';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // ── Tanggal Lahir ───────────────
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('TANGGAL LAHIR'),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: _pickDate,
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _tglLahir != null
                                            ? _primary
                                            : _border,
                                        width: _tglLahir != null ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _tglLahir == null
                                              ? 'MM/DD/YYYY'
                                              : '${_tglLahir!.month.toString().padLeft(2, '0')}/${_tglLahir!.day.toString().padLeft(2, '0')}/${_tglLahir!.year}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _tglLahir == null
                                                ? const Color(0xFFCBD5E1)
                                                : _textDark,
                                          ),
                                        ),
                                        Icon(
                                          Icons.calendar_month_outlined,
                                          color: _tglLahir != null
                                              ? _primary
                                              : const Color(0xFF94A3B8),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Jenis Kelamin
                                _buildLabel('JENIS KELAMIN'),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildJKButton(
                                            'L', 'LAKI-LAKI', '♂')),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _buildJKButton(
                                            'P', 'PEREMPUAN', '♀')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Nama Ibu ────────────────────
                          _buildLabel('NAMA IBU / WALI'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _namaIbuCtrl,
                            hint: 'Nama lengkap ibu kandung',
                            capitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Nama ibu wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // ── Alamat ──────────────────────
                          _buildLabel('ALAMAT DOMISILI'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _alamatCtrl,
                            hint: 'Jl. Merpati No. 12, RT 05/RW 02...',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // ── Info Card Biru ──────────────
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: _primaryDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Siap untuk penimbangan?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Setelah data disimpan, Anda bisa langsung mengisi Kartu Menuju Sehat (KMS) digital.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Tombol Simpan ───────────────
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: provider.isSaving ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: provider.isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5),
                                    )
                                  : const Icon(Icons.save_outlined,
                                      color: Colors.white, size: 20),
                              label: Text(
                                provider.isSaving
                                    ? 'Menyimpan...'
                                    : 'SIMPAN DATA',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Tombol Batal ────────────────
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => context.pop(),
                              child: const Text(
                                'BATAL',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _textGrey,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _textGrey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    int maxLines = 1,
    bool readOnly = false,
    TextCapitalization capitalization = TextCapitalization.none,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      readOnly: readOnly,
      textCapitalization: capitalization,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: readOnly ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
          borderSide: const BorderSide(color: Color(0xFFDC3545)),
        ),
      ),
    );
  }

  Widget _buildJKButton(String value, String label, String symbol) {
    final isSelected  = _jenisKelamin == value;
    final color       = value == 'L' ? _primary : const Color(0xFFE91E63);
    return GestureDetector(
      onTap: () => setState(() => _jenisKelamin = value),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : _border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$symbol ',
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : _textGrey,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _textGrey,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}