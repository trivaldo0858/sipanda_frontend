// lib/router/app_router.dart
//
// PERBAIKAN:
// - createRouter() menerima AuthProvider langsung (bukan BuildContext)
//   → menghindari race condition & "context not found" error
// - Splash screen cek session async SATU KALI
// - refreshListenable → router otomatis re-evaluate redirect saat auth berubah
// - Redirect tidak async → tidak ada "await" di dalam redirect()

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_kader_screen.dart';
import '../features/dashboard/screens/dashboard_bidan_screen.dart';
import '../features/dashboard/screens/dashboard_ortu_screen.dart';
import '../features/anak/screens/data_anak_screen.dart';
import '../features/anak/screens/form_tambah_anak_screen.dart';
import '../features/anak/screens/detail_anak_screen.dart';
import '../features/anak/models/anak_model.dart';
import '../features/pemeriksaan/screens/pilih_anak_pemeriksaan_screen.dart';
import '../features/imunisasi/screens/catat_imunisasi_screen.dart';
import '../features/jadwal/screens/jadwal_screen.dart';
import '../features/notifikasi/screens/notifikasi_screen.dart';
import '../features/kms/screens/kms_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: authProvider, // rebuild saat notifyListeners()

      redirect: (context, state) {
        final status = authProvider.status;
        final location = state.matchedLocation;

        // Masih initial (belum cek session) → tunggu di splash
        if (status == AuthStatus.initial) {
          return location == '/splash' ? null : '/splash';
        }

        final isAuth = status == AuthStatus.authenticated;

        // Belum login
        if (!isAuth) {
          if (location == '/login' || location == '/splash') return null;
          return '/login';
        }

        // Sudah login → keluar dari splash/login
        if (location == '/splash' || location == '/login') {
          return switch (authProvider.user?.role) {
            'Kader' => '/dashboard/kader',
            'Bidan' => '/dashboard/bidan',
            'OrangTua' => '/dashboard/ortu',
            _ => '/login',
          };
        }

        return null;
      },

      routes: [
        // ── Splash ────────────────────────────────────────
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const _SplashScreen(),
        ),

        // ── Login ─────────────────────────────────────────
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // ── Dashboard ─────────────────────────────────────
        GoRoute(
          path: '/dashboard/kader',
          name: 'dashboard-kader',
          builder: (context, state) => const DashboardKaderScreen(),
        ),
        GoRoute(
          path: '/dashboard/bidan',
          name: 'dashboard-bidan',
          builder: (context, state) => const DashboardBidanScreen(),
        ),
        GoRoute(
          path: '/dashboard/ortu',
          name: 'dashboard-ortu',
          builder: (context, state) => const DashboardOrtuScreen(),
        ),

        // ── Anak ──────────────────────────────────────────
        GoRoute(
          path: '/anak',
          name: 'anak',
          builder: (context, state) => const DataAnakScreen(),
        ),
        GoRoute(
          path: '/anak/tambah',
          name: 'anak-tambah',
          builder: (context, state) {
            final anakEdit = state.extra as AnakModel?;
            return FormTambahAnakScreen(anakEdit: anakEdit);
          },
        ),
        GoRoute(
          path: '/anak/:nik',
          name: 'anak-detail',
          builder: (context, state) {
            final nik = state.pathParameters['nik']!;
            return DetailAnakScreen(nikAnak: nik);
          },
        ),

        // ── Pemeriksaan ───────────────────────────────────
        GoRoute(
          path: '/pemeriksaan/catat',
          name: 'pemeriksaan-catat',
          builder: (context, state) => const PilihAnakPemeriksaanScreen(),
        ),

        // ── Imunisasi ─────────────────────────────────────
        GoRoute(
          path: '/imunisasi/catat',
          name: 'imunisasi-catat',
          builder: (context, state) {
            final nikAnak = state.uri.queryParameters['nik_anak'] ?? '';
            return CatatImunisasiScreen(nikAnak: nikAnak);
          },
        ),

        // ── Jadwal ────────────────────────────────────────
        GoRoute(
          path: '/jadwal',
          name: 'jadwal',
          builder: (context, state) => const JadwalScreen(),
        ),

        // ── Notifikasi ────────────────────────────────────
        GoRoute(
          path: '/notifikasi',
          name: 'notifikasi',
          builder: (context, state) => const NotifikasiScreen(),
        ),

        // ── KMS ───────────────────────────────────────────
        GoRoute(
          path: '/kms/:nik',
          name: 'kms',
          builder: (context, state) {
            final nik = state.pathParameters['nik']!;
            return KmsScreen(nikAnak: nik);
          },
        ),

        // ── Placeholder ───────────────────────────────────
        GoRoute(
          path: '/laporan',
          name: 'laporan',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Laporan'),
        ),
        GoRoute(
          path: '/profil',
          name: 'profil',
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Profil'),
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Color(0xFFDC3545),
              ),
              const SizedBox(height: 16),
              const Text(
                'Halaman tidak ditemukan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Splash Screen ─────────────────────────────────────────────────────
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil checkSession SATU KALI — GoRouter auto-redirect via refreshListenable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF0D6EFD),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'SIPANDA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sistem Informasi Posyandu',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF0D6EFD),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder Screen ────────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction_rounded,
              size: 48,
              color: Color(0xFF64748B),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Segera hadir',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
