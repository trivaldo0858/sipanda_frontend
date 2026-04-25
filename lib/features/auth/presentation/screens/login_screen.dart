// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────
  final _usernameCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _nikCtrl       = TextEditingController();
  final _formKey       = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────────────
  int _selectedRole    = 0; // 0=Kader, 1=Bidan, 2=OrangTua
  bool _obscurePass    = true;
  DateTime? _tglLahir;

  // ── Animation ─────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Colors ────────────────────────────────────────────────────────
  static const _primary     = Color(0xFF1B6FBE);
  static const _primaryDark = Color(0xFF0D4F8C);
  static const _primaryLight= Color(0xFF4A9FE0);
  static const _bgColor     = Color(0xFFEEF3F8);
  static const _inputBg     = Color(0xFFF0F4F8);
  static const _textDark    = Color(0xFF1A2B3C);
  static const _textGrey    = Color(0xFF8A9BB0);
  static const _cardBg      = Colors.white;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _nikCtrl.dispose();
    super.dispose();
  }

  // ── Role Switch ───────────────────────────────────────────────────
  void _switchRole(int index) {
    if (_selectedRole == index) return;
    setState(() => _selectedRole = index);
    _formKey.currentState?.reset();
    _usernameCtrl.clear();
    _passwordCtrl.clear();
    _nikCtrl.clear();
    _tglLahir = null;

    _slideCtrl.reset();
    _slideCtrl.forward();
  }

  // ── Date Picker ───────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime(now.year - 1),
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tglLahir = picked);
  }

  // ── Login Handler ─────────────────────────────────────────────────
  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    bool success = false;

    if (_selectedRole == 2) {
      // Orang Tua
      if (_tglLahir == null) {
        _showError('Pilih tanggal lahir anak terlebih dahulu.');
        return;
      }
      final tgl = '${_tglLahir!.year.toString().padLeft(4, '0')}'
          '-${_tglLahir!.month.toString().padLeft(2, '0')}'
          '-${_tglLahir!.day.toString().padLeft(2, '0')}';
      success = await auth.loginOrangTua(
        nikBalita: _nikCtrl.text.trim(),
        tglLahir:  tgl,
      );
    } else {
      success = await auth.login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text,
      );
    }

    if (!mounted) return;
    if (!success) {
      _showError(auth.errorMessage ?? 'Login gagal. Coba lagi.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _buildLogo(),
                ),

                // ── Card ─────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _buildCard(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Text(
          'SIPANDA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Main Card ─────────────────────────────────────────────────────
  Widget _buildCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B6FBE).withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 28),

              // Tab Role
              _buildRoleTab(),
              const SizedBox(height: 28),

              // Form Fields
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _selectedRole == 2
                    ? _buildOrangTuaForm()
                    : _buildKaderBidanForm(),
              ),

              const SizedBox(height: 24),

              // Button Login
              _buildLoginButton(),

              // Google Button (OrangTua only)
              if (_selectedRole == 2) ...[
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildGoogleButton(),
              ],

              const SizedBox(height: 24),

              // Bottom text
              _buildBottomText(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selamat Datang',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _textDark,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Silakan masuk untuk mengakses layanan\nkesehatan digital Posyandu Anda.',
          style: TextStyle(
            fontSize: 14,
            color: _textGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Role Tab ──────────────────────────────────────────────────────
  Widget _buildRoleTab() {
    const roles = ['Kader', 'Bidan', 'Orang Tua'];
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: List.generate(roles.length, (i) {
          final isActive = _selectedRole == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchRole(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    roles[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? _primary : _textGrey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Form Kader/Bidan ──────────────────────────────────────────────
  Widget _buildKaderBidanForm() {
    return Column(
      key: const ValueKey('kader_bidan'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Nama Pengguna'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _usernameCtrl,
          hint: 'Masukkan nama pengguna',
          icon: Icons.person_outline_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Username wajib diisi' : null,
        ),
        const SizedBox(height: 18),
        _buildLabel('Kata Sandi'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordCtrl,
          hint: 'Masukkan kata sandi',
          icon: Icons.lock_outline_rounded,
          obscure: _obscurePass,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePass = !_obscurePass),
            child: Icon(
              _obscurePass
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: _textGrey,
              size: 20,
            ),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
        ),
      ],
    );
  }

  // ── Form Orang Tua ────────────────────────────────────────────────
  Widget _buildOrangTuaForm() {
    return Column(
      key: const ValueKey('orang_tua'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('NIK Anak'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nikCtrl,
          hint: '16 digit NIK',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'NIK anak wajib diisi';
            if (v.trim().length != 16) return 'NIK harus 16 digit';
            return null;
          },
        ),
        const SizedBox(height: 18),
        _buildLabel('Tanggal Lahir Anak'),
        const SizedBox(height: 8),
        _buildDateField(),
      ],
    );
  }

  // ── Label ─────────────────────────────────────────────────────────
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

  // ── Text Field ────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: _textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textGrey, fontSize: 14),
        prefixIcon: Icon(icon, color: _textGrey, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _inputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFD32F2F)),
      ),
    );
  }

  // ── Date Field ────────────────────────────────────────────────────
  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _inputBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: _textGrey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _tglLahir == null
                    ? 'mm/dd/yyyy'
                    : '${_tglLahir!.day.toString().padLeft(2, '0')}/'
                      '${_tglLahir!.month.toString().padLeft(2, '0')}/'
                      '${_tglLahir!.year}',
                style: TextStyle(
                  fontSize: 15,
                  color: _tglLahir == null ? _textGrey : _textDark,
                  fontWeight: _tglLahir == null
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: _textGrey, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Login Button ──────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: auth.isLoading
                  ? null
                  : const LinearGradient(
                      colors: [_primaryDark, _primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: auth.isLoading ? const Color(0xFFD0DFF0) : null,
              borderRadius: BorderRadius.circular(28),
              boxShadow: auth.isLoading
                  ? null
                  : [
                      BoxShadow(
                        color: _primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: auth.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: _primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Masuk Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // ── Divider ───────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau masuk dengan',
            style: TextStyle(fontSize: 12, color: _textGrey),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }

  // ── Google Button ─────────────────────────────────────────────────
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          // TODO: implementasi Google Sign In
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Fitur Google Sign In segera hadir'),
              backgroundColor: _primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade200, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G icon
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const _GoogleIcon(),
            ),
            const SizedBox(width: 10),
            const Text(
              'Masuk dengan Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Text ───────────────────────────────────────────────────
  Widget _buildBottomText() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: _textGrey),
          children: [
            const TextSpan(text: 'Belum terdaftar di Posyandu? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  // TODO: navigasi ke halaman kontak
                },
                child: const Text(
                  'Hubungi Petugas',
                  style: TextStyle(
                    fontSize: 13,
                    color: _primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Google Icon Widget ────────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GoogleIconPainter(),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    // Blue arc (top-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.57,
      3.14,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22,
    );

    // Red arc (top-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.57,
      -1.05,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22,
    );

    // Yellow arc (bottom-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.09,
      1.05,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22,
    );

    // Green arc (bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.14,
      1.05,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22,
    );

    // White horizontal bar (G cutout)
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - size.height * 0.12,
          r * 0.9, size.height * 0.24),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}