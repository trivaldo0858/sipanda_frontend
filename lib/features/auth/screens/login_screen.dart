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

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // -1 = landing, 0 = Kader, 1 = Bidan, 2 = OrangTua
  int _selectedRole = -1;

  // Kader
  PosyanduItem? _selectedPosyandu;
  final _kaderPasswordCtrl = TextEditingController();
  bool _kaderObscure = true;
  final _kaderFormKey = GlobalKey<FormState>();

  // Bidan
  final _bidanUsernameCtrl = TextEditingController();
  final _bidanPasswordCtrl = TextEditingController();
  bool _bidanObscure = true;
  final _bidanFormKey = GlobalKey<FormState>();

  // Orang Tua
  final _ortuNikCtrl = TextEditingController();
  DateTime? _selectedDate;
  final _ortuFormKey = GlobalKey<FormState>();

  // Animation
  late AnimationController _formCtrl;
  late Animation<Offset> _formSlide;
  late Animation<double> _formFade;

  // Colors
  static const _primary = Color(0xFF1B6CA8);
  static const _accent = Color(0xFF00BFA6);
  static const _textDark = Color(0xFF0D1B2A);
  static const _textGrey = Color(0xFF5C7A99);
  static const _inputBg = Color(0xFFF0F6FF);
  static const _border = Color(0xFFD0E4F7);
  static const _white = Colors.white;
  static const _bg = Color(0xFFF0F6FF);

  @override
  void initState() {
    super.initState();
    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutCubic));
    _formFade = CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadPosyanduList();
    });
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    _kaderPasswordCtrl.dispose();
    _bidanUsernameCtrl.dispose();
    _bidanPasswordCtrl.dispose();
    _ortuNikCtrl.dispose();
    super.dispose();
  }

  void _selectRole(int role) {
    setState(() => _selectedRole = role);
    _formCtrl
      ..reset()
      ..forward();
  }

  void _backToLanding() {
    setState(() => _selectedRole = -1);
    _formCtrl.reset();
  }

  String get _tglFormatted {
    if (_selectedDate == null) return '';
    return '${_selectedDate!.year}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';
  }

  String get _tglDisplay {
    if (_selectedDate == null) return 'Pilih tanggal lahir anak';
    const b = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${_selectedDate!.day.toString().padLeft(2, '0')} '
        '${b[_selectedDate!.month]} ${_selectedDate!.year}';
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: DateTime(2022),
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir Anak',
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _selectedDate = p);
  }

  Future<void> _loginKader() async {
    if (!_kaderFormKey.currentState!.validate()) return;
    if (_selectedPosyandu == null) {
      _err('Pilih posyandu terlebih dahulu.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginKader(
      idPosyandu: _selectedPosyandu!.idPosyandu,
      passwordKader: _kaderPasswordCtrl.text.trim(),
    );
    if (mounted) {
      if (ok)
        context.go('/dashboard/kader');
      else
        _err(auth.errorMessage ?? 'Login gagal');
    }
  }

  Future<void> _loginBidan() async {
    if (!_bidanFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginBidan(
      username: _bidanUsernameCtrl.text.trim(),
      password: _bidanPasswordCtrl.text.trim(),
    );
    if (mounted) {
      if (ok)
        context.go('/dashboard/bidan');
      else
        _err(auth.errorMessage ?? 'Login gagal');
    }
  }

  Future<void> _loginOrtu() async {
    if (!_ortuFormKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _err('Pilih tanggal lahir anak.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginOrangTua(
      nikAnak: _ortuNikCtrl.text.trim(),
      tglLahir: _tglFormatted,
    );
    if (mounted) {
      if (ok)
        context.go('/dashboard/ortu');
      else
        _err(auth.errorMessage ?? 'Login gagal');
    }
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: _white, size: 17),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
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
      body: Stack(
        children: [
          // Gradient top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A2E6E),
                    Color(0xFF1565C0),
                    Color(0xFF0277BD),
                    Color(0xFF00838F),
                  ],
                  stops: [0.0, 0.35, 0.7, 1.0],
                ),
              ),
              child: CustomPaint(painter: _RipplePainter()),
            ),
          ),

          // Content center
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo + Judul ───────────────────────
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // ── Card ──────────────────────────────
                    _selectedRole == -1
                        ? _buildLandingCard()
                        : SlideTransition(
                            position: _formSlide,
                            child: FadeTransition(
                              opacity: _formFade,
                              child: _buildFormCard(),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _white.withOpacity(0.3), width: 1.5),
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            color: _white,
            size: 34,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'SIPANDA',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: _white,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistem Posyandu Anak Digital',
          style: TextStyle(
            fontSize: 13,
            color: _white.withOpacity(0.75),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ── Landing Card ─────────────────────────────────────────
  Widget _buildLandingCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selamat Datang',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih peran Anda untuk melanjutkan',
            style: TextStyle(fontSize: 13, color: _textGrey.withOpacity(0.85)),
          ),
          const SizedBox(height: 24),

          _roleBtn(
            0,
            Icons.people_alt_rounded,
            'Kader',
            const Color(0xFF1565C0),
            const Color(0xFFE3F2FD),
          ),
          const SizedBox(height: 10),
          _roleBtn(
            1,
            Icons.medical_services_rounded,
            'Bidan',
            const Color(0xFF00838F),
            const Color(0xFFE0F7FA),
          ),
          const SizedBox(height: 10),
          _roleBtn(
            2,
            Icons.family_restroom_rounded,
            'Orang Tua',
            const Color(0xFF2E7D32),
            const Color(0xFFE8F5E9),
          ),

          const SizedBox(height: 20),
          Center(
            child: Text(
              'Belum terdaftar? Hubungi petugas posyandu',
              style: TextStyle(
                fontSize: 12,
                color: _textGrey.withOpacity(0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBtn(int idx, IconData icon, String label, Color color, Color bg) {
    return GestureDetector(
      onTap: () => _selectRole(idx),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  // ── Form Card ────────────────────────────────────────────
  Widget _buildFormCard() {
    final info = _roleInfo(_selectedRole);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back + role label
          Row(
            children: [
              GestureDetector(
                onTap: _backToLanding,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15,
                    color: _primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: info.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(info.icon, size: 14, color: info.color),
                    const SizedBox(width: 6),
                    Text(
                      info.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: info.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Halo, ${info.label}!',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.sub,
            style: TextStyle(fontSize: 13, color: _textGrey.withOpacity(0.85)),
          ),
          const SizedBox(height: 22),

          // Form content
          if (_selectedRole == 0)
            _kaderForm()
          else if (_selectedRole == 1)
            _bidanForm()
          else
            _ortuForm(),
        ],
      ),
    );
  }

  ({IconData icon, String label, String sub, Color color, Color bg}) _roleInfo(
    int r,
  ) {
    return switch (r) {
      0 => (
        icon: Icons.people_alt_rounded,
        label: 'Kader',
        sub: 'Pilih posyandu & masukkan kata sandi',
        color: const Color(0xFF1565C0),
        bg: const Color(0xFFE3F2FD),
      ),
      1 => (
        icon: Icons.medical_services_rounded,
        label: 'Bidan',
        sub: 'Masukkan username & kata sandi',
        color: const Color(0xFF00838F),
        bg: const Color(0xFFE0F7FA),
      ),
      _ => (
        icon: Icons.family_restroom_rounded,
        label: 'Orang Tua',
        sub: 'Masukkan NIK anak & tanggal lahir',
        color: const Color(0xFF2E7D32),
        bg: const Color(0xFFE8F5E9),
      ),
    };
  }

  // ── Form Kader ───────────────────────────────────────────
  Widget _kaderForm() {
    return Consumer<AuthProvider>(
      key: const ValueKey('k'),
      builder: (_, auth, __) => Form(
        key: _kaderFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lbl('Lokasi Posyandu'),
            const SizedBox(height: 8),
            auth.posyanduLoading
                ? _loadBox()
                : _dropdownPosyandu(auth.posyanduList),
            const SizedBox(height: 14),
            _lbl('Kata Sandi'),
            const SizedBox(height: 8),
            _passF(
              _kaderPasswordCtrl,
              'Kata sandi posyandu',
              _kaderObscure,
              () => setState(() => _kaderObscure = !_kaderObscure),
              (v) => (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            _submitBtn(
              'Masuk sebagai Kader',
              auth.isLoading,
              _loginKader,
              const Color(0xFF1565C0),
            ),
            const SizedBox(height: 14),
            _footer(),
          ],
        ),
      ),
    );
  }

  // ── Form Bidan ───────────────────────────────────────────
  Widget _bidanForm() {
    return Consumer<AuthProvider>(
      key: const ValueKey('b'),
      builder: (_, auth, __) => Form(
        key: _bidanFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lbl('Nama Pengguna'),
            const SizedBox(height: 8),
            _txtF(
              _bidanUsernameCtrl,
              'Username bidan',
              (v) => (v == null || v.isEmpty) ? 'Username wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _lbl('Kata Sandi'),
            const SizedBox(height: 8),
            _passF(
              _bidanPasswordCtrl,
              'Kata sandi',
              _bidanObscure,
              () => setState(() => _bidanObscure = !_bidanObscure),
              (v) => (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            _submitBtn(
              'Masuk sebagai Bidan',
              auth.isLoading,
              _loginBidan,
              const Color(0xFF00838F),
            ),
            const SizedBox(height: 14),
            _footer(),
          ],
        ),
      ),
    );
  }

  // ── Form Orang Tua ───────────────────────────────────────
  Widget _ortuForm() {
    return Consumer<AuthProvider>(
      key: const ValueKey('o'),
      builder: (_, auth, __) => Form(
        key: _ortuFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lbl('NIK Anak'),
            const SizedBox(height: 8),
            _txtF(
              _ortuNikCtrl,
              '16 digit NIK anak',
              (v) {
                if (v == null || v.isEmpty) return 'NIK wajib diisi';
                if (v.length < 16) return 'NIK harus 16 digit';
                return null;
              },
              keyboard: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 16,
            ),
            const SizedBox(height: 14),
            _lbl('Tanggal Lahir Anak'),
            const SizedBox(height: 8),
            _datePick(),
            const SizedBox(height: 24),
            _submitBtn(
              'Masuk sebagai Orang Tua',
              auth.isLoading,
              _loginOrtu,
              const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 14),
            _footer(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ══════════════════════════════════════════════════════════

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: _white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: _primary.withOpacity(0.12),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );

  Widget _lbl(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _textDark,
    ),
  );

  InputDecoration _deco({String? hint, Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(fontSize: 14, color: _textGrey.withOpacity(0.55)),
    filled: true,
    fillColor: _inputBg,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
    ),
    errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFE53935)),
  );

  Widget _txtF(
    TextEditingController c,
    String hint,
    FormFieldValidator<String>? v, {
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    int? maxLength,
  }) => TextFormField(
    controller: c,
    keyboardType: keyboard,
    inputFormatters: formatters,
    maxLength: maxLength,
    validator: v,
    style: const TextStyle(fontSize: 14, color: _textDark),
    decoration: _deco(hint: hint).copyWith(counterText: ''),
  );

  Widget _passF(
    TextEditingController c,
    String hint,
    bool obs,
    VoidCallback toggle,
    FormFieldValidator<String>? v,
  ) => TextFormField(
    controller: c,
    obscureText: obs,
    validator: v,
    style: const TextStyle(fontSize: 14, color: _textDark),
    decoration: _deco(
      hint: hint,
      suffix: IconButton(
        icon: Icon(
          obs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: _textGrey,
          size: 20,
        ),
        onPressed: toggle,
      ),
    ),
  );

  Widget _dropdownPosyandu(List<PosyanduItem> list) =>
      DropdownButtonFormField<PosyanduItem>(
        value: _selectedPosyandu,
        hint: Text(
          'Pilih unit posyandu',
          style: TextStyle(fontSize: 14, color: _textGrey.withOpacity(0.55)),
        ),
        items: list
            .map(
              (p) => DropdownMenuItem(
                value: p,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p.namaPosyandu,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    if (p.desaKelurahan.isNotEmpty)
                      Text(
                        '${p.desaKelurahan}, ${p.kecamatan}',
                        style: TextStyle(
                          fontSize: 11,
                          color: _textGrey.withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => _selectedPosyandu = v),
        validator: (v) => v == null ? 'Pilih posyandu terlebih dahulu' : null,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _textGrey),
        decoration: _deco(),
        dropdownColor: _white,
        borderRadius: BorderRadius.circular(12),
        isExpanded: true,
      );

  Widget _loadBox() => Container(
    height: 52,
    decoration: BoxDecoration(
      color: _inputBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
      ),
    ),
  );

  Widget _datePick() => GestureDetector(
    onTap: _pickDate,
    child: Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedDate != null ? _primary : _border,
          width: _selectedDate != null ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 18,
            color: _selectedDate != null ? _primary : _textGrey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _tglDisplay,
              style: TextStyle(
                fontSize: 14,
                color: _selectedDate == null
                    ? _textGrey.withOpacity(0.55)
                    : _textDark,
                fontWeight: _selectedDate != null
                    ? FontWeight.w500
                    : FontWeight.w400,
              ),
            ),
          ),
          if (_selectedDate != null)
            GestureDetector(
              onTap: () => setState(() => _selectedDate = null),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: _textGrey,
              ),
            ),
        ],
      ),
    ),
  );

  Widget _submitBtn(
    String label,
    bool loading,
    VoidCallback onTap,
    Color color,
  ) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.45),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(color: _white, strokeWidth: 2.5),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login_rounded, size: 18, color: _white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _white,
                  ),
                ),
              ],
            ),
    ),
  );

  Widget _footer() => Center(
    child: Text(
      'Belum terdaftar? Hubungi petugas posyandu',
      style: TextStyle(fontSize: 12, color: _textGrey.withOpacity(0.65)),
    ),
  );
}

// ── Background painter ──────────────────────────────────────
class _RipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.88, size.height * 0.15),
        size.width * 0.18 * i,
        p,
      );
    }
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.55,
        size.width * 0.6,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.88,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
