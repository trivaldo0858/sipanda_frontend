import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/network/api_client.dart';
import 'router/app_router.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/anak/providers/anak_provider.dart';
import 'features/pemeriksaan/providers/pemeriksaan_provider.dart';
import 'features/imunisasi/providers/imunisasi_provider.dart';
import 'features/jadwal/providers/jadwal_provider.dart';
import 'features/notifikasi/providers/notifikasi_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Dio
  ApiClient.instance.init();

  // Buat AuthProvider dan jalankan checkSession() sebelum app render
  // Ini memastikan status login diketahui sebelum GoRouter memutuskan route awal
  final authProvider = AuthProvider();
  await authProvider.checkSession();

  runApp(SipandaApp(authProvider: authProvider));
}

class SipandaApp extends StatelessWidget {
  final AuthProvider authProvider;
  const SipandaApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Gunakan authProvider yang sudah ter-inisialisasi
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AnakProvider()),
        ChangeNotifierProvider(create: (_) => PemeriksaanProvider()),
        ChangeNotifierProvider(create: (_) => ImunisasiProvider()),
        ChangeNotifierProvider(create: (_) => JadwalProvider()),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.createRouter(context);
          return MaterialApp.router(
            title: 'SIPANDA',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            routerConfig: router,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const Color primary = Color(0xFF0D6EFD);
    const Color background = Color(0xFFF7F9FC);
    const Color cardWhite = Color(0xFFFFFFFF);
    const Color textDark = Color(0xFF1E293B);
    const Color textGrey = Color(0xFF64748B);
    const Color border = Color(0xFFE2E8F0);
    const Color borderLight = Color(0xFFF1F5F9);
    const Color danger = Color(0xFFDC3545);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: cardWhite,
      ),
      scaffoldBackgroundColor: background,

      appBarTheme: const AppBarTheme(
        backgroundColor: cardWhite,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        iconTheme: IconThemeData(color: textDark),
      ),

      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: cardWhite,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: borderLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textGrey,
        ),
        errorStyle: const TextStyle(fontSize: 12, color: danger),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primary,
        unselectedItemColor: textGrey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(fontSize: 14, color: cardWhite),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
