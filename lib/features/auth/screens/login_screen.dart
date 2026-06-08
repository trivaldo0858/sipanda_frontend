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
  // -1 = pilih role, 0 = Kader, 1 = Bidan, 2 = OrangTua
  int _selectedRole = -1;

  // Kader
  PosyanduItem? _selectedPosyandu;
  final _kaderPassCtrl = TextEditingController();
  bool _kaderObscure = true;
  final _kaderFormKey = GlobalKey<FormState>();

  // Bidan
  final _bidanUserCtrl = TextEditingController();
  final _bidanPassCtrl = TextEditingController();
  bool _bidanObscure = true;
  final _bidanFormKey = GlobalKey<FormState>();

  // Orang Tua
  final _ortuNikCtrl = TextEditingController();
  DateTime? _selectedDate;
  final _ortuFormKey = GlobalKey<FormState>();

  static const Color _primary   = Color(0xFF0D6EFD);
  static const Color _textDark  = Color(0xFF1E293B);
  static const Color _textGrey  = Color(0xFF64748B);
  static const Color _inputBg   = Color(0xFFF1F5F9);
  static const Color _border    = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadPosyanduList();
    });
  }

  @override
  void dispose() {
    _kaderPassCtrl.dispose();
    _bidanUserCtrl.dispose();
    _bidanPassCtrl.dispose();
    _ortuNikCtrl.dispose();
    super.dispose();
  }

  void _pilihRole(int role) => setState(() => _selectedRole = role);
  void _kembali() => setState(() => _selectedRole = -1);

  String get _tglFormatted {
    if (_selectedDate == null) return '';
    return '${_selectedDate!.year}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';
  }

  String get _tglDisplay {
    if (_selectedDate == null) return 'Pilih tanggal lahir anak';
    return '${_selectedDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDate!.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2022),
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _loginKader() async {
    if (!_kaderFormKey.currentState!.validate()) return;
    if (_selectedPosyandu == null) {
      _showError('Pilih posyandu terlebih dahulu');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginKader(
      idPosyandu: _selectedPosyandu!.idPosyandu,
      passwordKader: _kaderPassCtrl.text.trim(),
    );
    if (mounted) {
      if (ok) {
        context.go('/dashboard/kader');
      } else {
        _showError(auth.errorMessage ?? 'Login gagal');
      }
    }
  }

  Future<void> _loginBidan() async {
    if (!_bidanFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginBidan(
      username: _bidanUserCtrl.text.trim(),
      password: _bidanPassCtrl.text.trim(),
    );
    if (mounted) {
      if (ok) {
        context.go('/dashboard/bidan');
      } else {
        _showError(auth.errorMessage ?? 'Login gagal');
      }
    }
  }

  Future<void> _loginOrtu() async {
    if (!_ortuFormKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Pilih tanggal lahir anak');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginOrangTua(
      nikAnak: _ortuNikCtrl.text.trim(),
      tglLahir: _tglFormatted,
    );
    if (mounted) {
      if (ok) {
        context.go('/dashboard/ortu');
      } else {
        _showError(auth.errorMessage ?? 'Login gagal');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
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
      backgroundColor: _primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                const Icon(Icons.local_hospital_rounded,
                    color: Colors.white, size: 48),
                const SizedBox(height: 10),
                const Text('SIPANDA',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    )),
                const SizedBox(height: 4),
                const Text('Sistem Posyandu Anak Digital',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 32),

                // Card
                _selectedRole == -1
                    ? _buildPilihRole()
                    : _buildFormLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // PILIH ROLE
  // ════════════════════════════════════════════════════════
  Widget _buildPilihRole() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Masuk sebagai',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: _textDark)),
          const SizedBox(height: 4),
          const Text('Pilih peran Anda untuk melanjutkan',
              style: TextStyle(fontSize: 13, color: _textGrey)),
          const SizedBox(height: 20),
          _roleButton(0, Icons.people_alt_rounded, 'Kader',
              'Petugas posyandu', const Color(0xFF0D6EFD)),
          const SizedBox(height: 10),
          _roleButton(1, Icons.medical_services_rounded, 'Bidan',
              'Tenaga kesehatan', const Color(0xFF198754)),
          const SizedBox(height: 10),
          _roleButton(2, Icons.family_restroom_rounded, 'Orang Tua',
              'Wali balita', const Color(0xFFE67E22)),
        ],
      ),
    );
  }

  Widget _roleButton(int idx, IconData icon, String label,
      String sub, Color color) {
    return GestureDetector(
      onTap: () => _pilihRole(idx),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w700, color: _textDark)),
                  Text(sub,
                      style: const TextStyle(fontSize: 12, color: _textGrey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // FORM LOGIN
  // ════════════════════════════════════════════════════════
  Widget _buildFormLogin() {
    final roles = [
      {'icon': Icons.people_alt_rounded, 'label': 'Kader', 'color': const Color(0xFF0D6EFD)},
      {'icon': Icons.medical_services_rounded, 'label': 'Bidan', 'color': const Color(0xFF198754)},
      {'icon': Icons.family_restroom_rounded, 'label': 'Orang Tua', 'color': const Color(0xFFE67E22)},
    ];
    final role = roles[_selectedRole];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + badge role
          Row(
            children: [
              GestureDetector(
                onTap: _kembali,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _inputBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: _textDark),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (role['color'] as Color).withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(role['icon'] as IconData, size: 14,
                        color: role['color'] as Color),
                    const SizedBox(width: 6),
                    Text(role['label'] as String,
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: role['color'] as Color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Judul
          Text('Login ${role['label']}',
              style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 4),
          Text(_getSubtitle(),
              style: const TextStyle(fontSize: 13, color: _textGrey)),
          const SizedBox(height: 20),

          // Form per role
          if (_selectedRole == 0) _formKader(),
          if (_selectedRole == 1) _formBidan(),
          if (_selectedRole == 2) _formOrtu(),
        ],
      ),
    );
  }

  String _getSubtitle() {
    return switch (_selectedRole) {
      0 => 'Pilih posyandu dan masukkan password',
      1 => 'Masukkan username dan password',
      _ => 'Masukkan NIK anak dan tanggal lahir',
    };
  }

  // ── Form Kader ────────────────────────────────────────
  Widget _formKader() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Form(
        key: _kaderFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Posyandu', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _textDark)),
            const SizedBox(height: 6),
            auth.posyanduLoading
                ? _loadingBox()
                : DropdownButtonFormField<PosyanduItem>(
                    value: _selectedPosyandu,
                    hint: const Text('Pilih posyandu',
                        style: TextStyle(fontSize: 14, color: _textGrey)),
                    items: auth.posyanduList.map((p) =>
                        DropdownMenuItem(
                          value: p,
                          child: Text(p.namaPosyandu,
                              style: const TextStyle(fontSize: 14)),
                        )).toList(),
                    onChanged: (v) => setState(() => _selectedPosyandu = v),
                    validator: (v) => v == null ? 'Pilih posyandu' : null,
                    decoration: _inputDeco(),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                  ),
            const SizedBox(height: 14),
            const Text('Password', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _textDark)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _kaderPassCtrl,
              obscureText: _kaderObscure,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Password wajib diisi' : null,
              decoration: _inputDeco(
                hint: 'Masukkan password',
                suffix: _toggleObscure(_kaderObscure,
                    () => setState(() => _kaderObscure = !_kaderObscure)),
              ),
            ),
            const SizedBox(height: 24),
            _submitButton('Masuk', auth.isLoading, _loginKader),
          ],
        ),
      ),
    );
  }

  // ── Form Bidan ────────────────────────────────────────
  Widget _formBidan() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Form(
        key: _bidanFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Username', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _textDark)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _bidanUserCtrl,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Username wajib diisi' : null,
              decoration: _inputDeco(hint: 'Masukkan username'),
            ),
            const SizedBox(height: 14),
            const Text('Password', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _textDark)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _bidanPassCtrl,
              obscureText: _bidanObscure,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Password wajib diisi' : null,
              decoration: _inputDeco(
                hint: 'Masukkan password',
                suffix: _toggleObscure(_bidanObscure,
                    () => setState(() => _bidanObscure = !_bidanObscure)),
              ),
            ),
            const SizedBox(height: 24),
            _submitButton('Masuk', auth.isLoading, _loginBidan),
          ],
        ),
      ),
    );
  }

  // ── Form Orang Tua ────────────────────────────────────
  Widget _formOrtu() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Form(
        key: _ortuFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('NIK Anak', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _textDark)),
            const SizedBox(height: 6),
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
              decoration: _inputDeco(hint: 'Masukkan 16 digit NIK anak')
                  .copyWith(counterText: ''),
            ),
            const SizedBox(height: 14),
            const Text('Tanggal Lahir Anak', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: _textDark)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 18, color: _textGrey),
                    const SizedBox(width: 10),
                    Text(_tglDisplay,
                        style: TextStyle(fontSize: 14,
                            color: _selectedDate == null
                                ? _textGrey : _textDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _submitButton('Masuk', auth.isLoading, _loginOrtu),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ════════════════════════════════════════════════════════
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  InputDecoration _inputDeco({String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: _textGrey),
      filled: true,
      fillColor: _inputBg,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFFDC3545)),
      ),
    );
  }

  Widget _toggleObscure(bool obscure, VoidCallback onTap) {
    return IconButton(
      icon: Icon(obscure
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,
          color: _textGrey, size: 20),
      onPressed: onTap,
    );
  }

  Widget _loadingBox() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: const Center(
        child: SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: _primary)),
      ),
    );
  }

  Widget _submitButton(String label, bool loading, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Text(label,
                style: const TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}