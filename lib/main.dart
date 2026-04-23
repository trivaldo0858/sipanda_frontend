// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'features/auth/auth_injection.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'providers/providers.dart';

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
        // Auth — Clean Architecture
        ...authProviders(),

        // Data providers — via barrel export
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AnakProvider()),
        ChangeNotifierProvider(create: (_) => PemeriksaanProvider()),
        ChangeNotifierProvider(create: (_) => ImunisasiProvider()),
        ChangeNotifierProvider(create: (_) => JadwalProvider()),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
        ChangeNotifierProvider(create: (_) => LaporanProvider()),
        ChangeNotifierProvider(create: (_) => PosyanduProvider()),
        ChangeNotifierProvider(create: (_) => ValidasiProvider()),
      ],
      child: MaterialApp(
        title: 'SIPANDA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E86AB),
          ),
          useMaterial3: true,
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
      builder: (context, auth, _) {
        return switch (auth.status) {
          AuthStatus.unknown         => const _SplashScreen(),
          AuthStatus.unauthenticated => const _LoginScreen(),
          AuthStatus.authenticated   => _HomeRouter(auth: auth),
        };
      },
    );
  }
}

class _HomeRouter extends StatelessWidget {
  final AuthProvider auth;
  const _HomeRouter({required this.auth});

  @override
  Widget build(BuildContext context) {
    return switch (auth.pengguna?.role) {
      'Bidan'    => const _BidanHome(),
      'Kader'    => const _KaderHome(),
      'OrangTua' => const _OrangTuaHome(),
      _          => const _LoginScreen(),
    };
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Halaman Login — segera dibuat')),
  );
}

class _BidanHome extends StatelessWidget {
  const _BidanHome();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Dashboard Bidan')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Halo Bidan, ${context.watch<AuthProvider>().pengguna?.username}!'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            child: const Text('Logout'),
          ),
        ],
      ),
    ),
  );
}

class _KaderHome extends StatelessWidget {
  const _KaderHome();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Dashboard Kader')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Halo Kader, ${context.watch<AuthProvider>().pengguna?.username}!'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            child: const Text('Logout'),
          ),
        ],
      ),
    ),
  );
}

class _OrangTuaHome extends StatelessWidget {
  const _OrangTuaHome();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Halo, ${auth.pengguna?.username ?? '-'}!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AuthProvider>().logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}