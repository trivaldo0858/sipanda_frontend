// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/auth_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedRole = 0; // 0=Kader, 1=Bidan, 2=OrangTua

  // ── Kader ─────────────────────────────────────────────
  PosyanduItem? _selectedPosyandu;
  final _kaderPasswordCtrl = TextEditingController();
  bool _kaderObscure = true;
  final _kaderFormKey = GlobalKey<FormState>();

  // ── Bidan ─────────────────────────────────────────────
  final _bidanUsernameCtrl = TextEditingController();
  final _bidanPasswordCtrl = TextEditingController();
  bool _bidanObscure = true;
  final _bidanFormKey = GlobalKey<FormState>();

  // ── Orang Tua ─────────────────────────────────────────
  final _ortuNikCtrl = TextEditingController();
  DateTime? _selectedDate;
  final _ortuFormKey = GlobalKey<FormState>();

  // ── Warna ─────────────────────────────────────────────
  static const Color _primary    = Color(0xFF0D6EFD);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textGrey   = Color(0xFF64748B);
  static const Color _background = Color(0xFFF0F4F8);
  static const Color _cardWhite  = Color(0xFFFFFFFF);
  static const Color _inputBg    = Color(0xFFEEF2F7);
  static const Color _tabBg      = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadPosyanduList();
    });
  }

  @override
  void dispose() {
    _kaderPasswordCtrl.dispose();
    _bidanUsernameCtrl.dispose();
    _bidanPasswordCtrl.dispose();
    _ortuNikCtrl.dispose();
    super.dispose();
  }

  String get _tglLahirFormatted {
    if (_selectedDate == null) return '';
    return '${_selectedDate!.year}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';
  }

  String get _tglLahirDisplay {
    if (_selectedDate == null) return 'mm/dd/yyyy';
    return '${_selectedDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDate!.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2022),
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir Anak',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _loginKader() async {
    if (!_kaderFormKey.currentState!.validate()) return;
    if (_selectedPosyandu == null) {
      _showError('Pilih posyandu terlebih dahulu.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.loginKader(
      idPosyandu: _selectedPosyandu!.idPosyandu,
      passwordKader: _kaderPasswordCtrl.text.trim(),
    );
    if (mounted) {
      if (success) {
        context.go('/dashboard/kader');
      } else {
        _showError(auth.errorMessage ?? 'Login gagal.');
      }
    }
  }

  Future<void> _loginBidan() async {
    if (!_bidanFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.loginBidan(
      username: _bidanUsernameCtrl.text.trim(),
      password: _bidanPasswordCtrl.text.trim(),
    );
    if (mounted) {
      if (success) {
        context.go('/dashboard/bidan');
      } else {
        _showError(auth.errorMessage ?? 'Login gagal.');
      }
    }
  }

  Future<void> _loginOrangTua() async {
    if (!_ortuFormKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Pilih tanggal lahir anak.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.loginOrangTua(
      nikAnak: _ortuNikCtrl.text.trim(),
      tglLahir: _tglLahirFormatted,
    );
    if (mounted) {
      if (success) {
        context.go('/dashboard/ortu');
      } else {
        _showError(auth.errorMessage ?? 'Login gagal.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFDC3545),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_hospital_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SIPANDA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // ── Card Login ────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Silakan masuk untuk mengakses layanan kesehatan digital Posyandu Anda.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Tab Role ──────────────────────────
                    _buildRoleTab(),
                    const SizedBox(height: 24),

                    // ── Form per Role ─────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _selectedRole == 0
                          ? _buildKaderForm()
                          : _selectedRole == 1
                              ? _buildBidanForm()
                              : _buildOrtuForm(),
                    ),

                    const SizedBox(height: 24),

                    // ── Footer ────────────────────────────
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 13, color: _textGrey),
                          children: [
                            const TextSpan(
                                text: 'Belum terdaftar di Posyandu? '),
                            TextSpan(
                              text: 'Hubungi Petugas',
                              style: const TextStyle(
                                color: _primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab Role ───────────────────────────────────────────
  Widget _buildRoleTab() {
    final roles = ['Kader', 'Bidan', 'Orang Tua'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _tabBg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: List.generate(roles.length, (i) {
          final isSelected = _selectedRole == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _cardWhite : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  roles[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isSelected ? _textDark : _textGrey,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Form Kader ────────────────────────────────────────
  Widget _buildKaderForm() {
    return Consumer<AuthProvider>(
      key: const ValueKey('kader'),
      builder: (context, auth, _) {
        return Form(
          key: _kaderFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown Posyandu
              _buildLabel('Lokasi Posyandu'),
              const SizedBox(height: 8),
              auth.posyanduLoading
                  ? _buildLoadingField()
                  : _buildPosyanduDropdown(auth.posyanduList),
              const SizedBox(height: 16),

              // Password
              _buildLabel('Kata Sandi'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _kaderPasswordCtrl,
                hint: 'Masukkan kata sandi',
                obscure: _kaderObscure,
                onToggle: () =>
                    setState(() => _kaderObscure = !_kaderObscure),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              _buildSubmitButton(
                label: 'Masuk Sekarang',
                isLoading: auth.isLoading,
                onPressed: _loginKader,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPosyanduDropdown(List<PosyanduItem> list) {
    return DropdownButtonFormField<PosyanduItem>(
      value: _selectedPosyandu,
      hint: Text('Pilih posyandu',
          style: TextStyle(
              fontSize: 14, color: _textGrey.withAlpha(150))),
      items: list.map((p) => DropdownMenuItem(
        value: p,
        child: Text(p.namaPosyandu,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14)),
      )).toList(),
      onChanged: (val) => setState(() => _selectedPosyandu = val),
      validator: (v) => v == null ? 'Pilih posyandu' : null,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF94A3B8)),
      decoration: _inputDecoration(),
      dropdownColor: _cardWhite,
      borderRadius: BorderRadius.circular(12),
      isExpanded: true,
    );
  }

  Widget _buildLoadingField() {
    return Container(
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
              strokeWidth: 2, color: _primary),
        ),
      ),
    );
  }

  // ── Form Bidan ────────────────────────────────────────
  Widget _buildBidanForm() {
    return Consumer<AuthProvider>(
      key: const ValueKey('bidan'),
      builder: (context, auth, _) {
        return Form(
          key: _bidanFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nama Pengguna'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bidanUsernameCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Username wajib diisi' : null,
                decoration: _inputDecoration(
                    hint: 'Masukkan nama pengguna'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Kata Sandi'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _bidanPasswordCtrl,
                hint: 'Masukkan kata sandi',
                obscure: _bidanObscure,
                onToggle: () =>
                    setState(() => _bidanObscure = !_bidanObscure),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              _buildSubmitButton(
                label: 'Masuk Sekarang',
                isLoading: auth.isLoading,
                onPressed: _loginBidan,
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Form Orang Tua ────────────────────────────────────
  Widget _buildOrtuForm() {
    return Consumer<AuthProvider>(
      key: const ValueKey('ortu'),
      builder: (context, auth, _) {
        return Form(
          key: _ortuFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('NIK Anak'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ortuNikCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 16,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'NIK wajib diisi';
                  if (v.length < 16) return 'NIK harus 16 digit';
                  return null;
                },
                decoration:
                    _inputDecoration(hint: '16 digit NIK').copyWith(
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Tanggal Lahir Anak'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _inputBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _tglLahirDisplay,
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedDate == null
                              ? _textGrey.withAlpha(150)
                              : _textDark,
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        color: _selectedDate != null
                            ? _primary
                            : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSubmitButton(
                label: 'Masuk Sekarang',
                isLoading: auth.isLoading,
                onPressed: _loginOrangTua,
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Shared Widgets ─────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: _textGrey.withAlpha(150)),
      filled: true,
      fillColor: _inputBg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC3545)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFDC3545), width: 1.5),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: _inputDecoration(hint: hint).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF94A3B8),
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withAlpha(150),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}