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
  final _formKey = GlobalKey<FormState>();
  final _namaAnakCtrl = TextEditingController();
  final _nikAnakCtrl = TextEditingController();
  final _namaIbuCtrl = TextEditingController();
  final _namaAyahCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  String _jenisKelamin = 'L';
  DateTime? _tglLahir;

  bool get isEditMode => widget.anakEdit != null;

  static const _primary = Color(0xFF1B6CA8);
  static const _textDark = Color(0xFF0D1B2A);
  static const _textGrey = Color(0xFF5C7A99);
  static const _bg = Color(0xFFF0F6FF);
  static const _border = Color(0xFFD0E4F7);
  static const _inputBg = Color(0xFFF5F9FF);

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final a = widget.anakEdit!;
      _nikAnakCtrl.text = a.nikAnak;
      _namaAnakCtrl.text = a.namaAnak;
      _namaIbuCtrl.text = a.namaIbu ?? '';
      _namaAyahCtrl.text = a.namaAyah;
      _alamatCtrl.text = a.alamat ?? '';
      _jenisKelamin = a.jenisKelamin;
      _tglLahir = DateTime.tryParse(a.tglLahir);
    }
  }

  @override
  void dispose() {
    _namaAnakCtrl.dispose();
    _nikAnakCtrl.dispose();
    _namaIbuCtrl.dispose();
    _namaAyahCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  String get _tglFormatted {
    if (_tglLahir == null) return '';
    return '${_tglLahir!.year}-${_tglLahir!.month.toString().padLeft(2, '0')}-${_tglLahir!.day.toString().padLeft(2, '0')}';
  }

  String get _tglDisplay {
    if (_tglLahir == null) return 'DD/MM/YYYY';
    return '${_tglLahir!.day.toString().padLeft(2, '0')}/${_tglLahir!.month.toString().padLeft(2, '0')}/${_tglLahir!.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime(2022),
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir Balita',
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tglLahir = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tglLahir == null) {
      _showSnack('Pilih tanggal lahir balita', false);
      return;
    }
    final provider = context.read<AnakProvider>();
    bool success;
    if (isEditMode) {
      success = await provider.updateAnak(
        nikAnak: _nikAnakCtrl.text.trim(),
        namaAnak: _namaAnakCtrl.text.trim(),
        namaIbu: _namaIbuCtrl.text.trim(),
        tglLahir: _tglFormatted,
        jenisKelamin: _jenisKelamin,
        namaAyah: _namaAyahCtrl.text.trim(),
        nikOrangTua: '',
      );
    } else {
      success = await provider.tambahAnak(
        nikAnak: _nikAnakCtrl.text.trim(),
        nikOrangTua: '',
        namaAnak: _namaAnakCtrl.text.trim(),
        namaIbu: _namaIbuCtrl.text.trim(),
        tglLahir: _tglFormatted,
        jenisKelamin: _jenisKelamin,
        namaAyah: _namaAyahCtrl.text.trim(),
        alamat: _alamatCtrl.text.trim().isEmpty
            ? null
            : _alamatCtrl.text.trim(),
      );
    }
    if (mounted) {
      _showSnack(
        success
            ? provider.successMessage ?? 'Berhasil!'
            : provider.errorMessage ?? 'Gagal menyimpan.',
        success,
      );
      if (success) context.pop();
    }
  }

  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: success
            ? const Color(0xFF1B6CA8)
            : const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _primary,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditMode ? 'Edit Data Balita' : 'Input Data Balita',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Consumer<AnakProvider>(
                builder: (ctx, provider, _) => SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
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
                        const SizedBox(height: 12),
                        const Text(
                          'Lengkapi Profil\nSi Kecil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pastikan data sesuai dengan Kartu Keluarga atau KIA.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textGrey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nama Balita
                        _sectionCard(
                          children: [
                            _lbl('NAMA BALITA'),
                            const SizedBox(height: 8),
                            _txtF(
                              _namaAnakCtrl,
                              'Contoh: Ahmad Fauzan',
                              capitalization: TextCapitalization.words,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Nama balita wajib diisi'
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // NIK
                        _sectionCard(
                          children: [
                            _lbl('NIK BALITA (16 DIGIT)'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nikAnakCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 16,
                              readOnly: isEditMode,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _textDark,
                                letterSpacing: 1,
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'NIK wajib diisi';
                                if (v.length < 16)
                                  return 'NIK harus tepat 16 digit (saat ini ${v.length} digit)';
                                return null;
                              },
                              decoration:
                                  _deco(
                                    hint: '16 digit nomor kependudukan',
                                  ).copyWith(
                                    counterText: '',
                                    suffixIcon: ValueListenableBuilder(
                                      valueListenable: _nikAnakCtrl,
                                      builder: (_, v, __) {
                                        final len = v.text.length;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          child: Center(
                                            widthFactor: 1,
                                            child: Text(
                                              '$len/16',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: len == 16
                                                    ? _primary
                                                    : _textGrey,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tanggal Lahir + Jenis Kelamin
                        _sectionCard(
                          children: [
                            _lbl('TANGGAL LAHIR'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _inputBg,
                                  borderRadius: BorderRadius.circular(12),
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
                                      _tglDisplay,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _tglLahir == null
                                            ? const Color(0xFFB0C8E4)
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
                            _lbl('JENIS KELAMIN'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _jkBtn(
                                    'L',
                                    'Laki-laki',
                                    Icons.male_rounded,
                                    const Color(0xFF1565C0),
                                    const Color(0xFFE3F2FD),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _jkBtn(
                                    'P',
                                    'Perempuan',
                                    Icons.female_rounded,
                                    const Color(0xFFAD1457),
                                    const Color(0xFFFCE4EC),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Nama Ibu & Ayah
                        _sectionCard(
                          children: [
                            _lbl('NAMA IBU / WALI'),
                            const SizedBox(height: 8),
                            _txtF(
                              _namaIbuCtrl,
                              'Nama lengkap ibu kandung',
                              capitalization: TextCapitalization.words,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Nama ibu wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _lbl('NAMA AYAH'),
                            const SizedBox(height: 8),
                            _txtF(
                              _namaAyahCtrl,
                              'Nama lengkap ayah',
                              capitalization: TextCapitalization.words,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Alamat
                        _sectionCard(
                          children: [
                            _lbl('ALAMAT DOMISILI'),
                            const SizedBox(height: 8),
                            _txtF(
                              _alamatCtrl,
                              'Jl. Merpati No. 12, RT 05/RW 02...',
                              maxLines: 3,
                            ),
                          ],
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
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            icon: provider.isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Icon(
                                    Icons.save_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
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
                        const SizedBox(height: 10),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _lbl(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: _textGrey,
      letterSpacing: 1.2,
    ),
  );

  InputDecoration _deco({String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB0C8E4)),
    filled: true,
    fillColor: _inputBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
      borderSide: const BorderSide(color: Color(0xFFE53935)),
    ),
    errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFE53935)),
  );

  Widget _txtF(
    TextEditingController c,
    String hint, {
    TextCapitalization capitalization = TextCapitalization.none,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) => TextFormField(
    controller: c,
    maxLines: maxLines,
    textCapitalization: capitalization,
    validator: validator,
    style: const TextStyle(fontSize: 14, color: _textDark),
    decoration: _deco(hint: hint),
  );

  Widget _jkBtn(
    String val,
    String label,
    IconData icon,
    Color color,
    Color bg,
  ) {
    final isSel = _jenisKelamin == val;
    return GestureDetector(
      onTap: () => setState(() => _jenisKelamin = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isSel ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? color : _border,
            width: isSel ? 2 : 1,
          ),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSel ? Colors.white.withOpacity(0.2) : bg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSel ? Colors.white : color, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSel ? Colors.white : _textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
