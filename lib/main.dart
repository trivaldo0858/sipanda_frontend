// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'features/auth/auth_injection.dart';

// Providers
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/providers/anak_provider.dart';
import 'features/auth/presentation/providers/dashboard_provider.dart';
import 'features/auth/presentation/providers/imunisasi_provider.dart';
import 'features/auth/presentation/providers/jadwal_provider.dart';
import 'features/auth/presentation/providers/laporan_provider.dart';
import 'features/auth/presentation/providers/notifikasi_provider.dart';
import 'features/auth/presentation/providers/pemeriksaan_provider.dart';
import 'features/auth/presentation/providers/pengguna_provider.dart';
import 'features/auth/presentation/providers/posyandu_provider.dart';
import 'features/auth/presentation/providers/validasi_provider.dart';

// Screens
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/dashboard_kader_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.instance.init();
  runApp(const SipandaApp());
}

class SipandaApp extends StatelessWidget {
  const SipandaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth
        ...authProviders(),

        // App Providers
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AnakProvider()),
        ChangeNotifierProvider(create: (_) => PemeriksaanProvider()),
        ChangeNotifierProvider(create: (_) => ImunisasiProvider()),
        ChangeNotifierProvider(create: (_) => JadwalProvider()),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
        ChangeNotifierProvider(create: (_) => LaporanProvider()),
        ChangeNotifierProvider(create: (_) => PosyanduProvider()),
        ChangeNotifierProvider(create: (_) => ValidasiProvider()),
        ChangeNotifierProvider(create: (_) => PenggunaProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SIPANDA',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0B6AAE),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        ),
        home: const AppEntry(),
      ),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        return switch (auth.status) {
          AuthStatus.unknown => const _SplashScreen(),
          AuthStatus.unauthenticated => const LoginScreen(),
          AuthStatus.authenticated => _HomeRouter(auth: auth),
        };
      },
    );
  }
}

// =======================================================
// ROUTER BERDASARKAN ROLE
// =======================================================

class _HomeRouter extends StatelessWidget {
  final AuthProvider auth;

  const _HomeRouter({required this.auth});

  @override
  Widget build(BuildContext context) {
    final role = auth.pengguna?.role;

    return switch (role) {
      'Bidan' => const _BidanHome(),
      'Kader' => const DashboardKaderScreen(),
      'OrangTua' => const _OrangTuaHome(),
      _ => const LoginScreen(),
    };
  }
}

// =======================================================
// SPLASH
// =======================================================

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// =======================================================
// BIDAN
// =======================================================

class _BidanHome extends StatelessWidget {
  const _BidanHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Bidan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Halo Bidan, ${auth.pengguna?.username ?? '-'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// ORANG TUA
// =======================================================

class _OrangTuaHome extends StatelessWidget {
  const _OrangTuaHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Halo, ${auth.pengguna?.username ?? '-'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}