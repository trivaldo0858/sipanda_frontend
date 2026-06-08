// lib/router/app_router.dart

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

  static GoRouter createRouter(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return GoRouter(
      initialLocation: '/login',
      debugLogDiagnostics: true,

      redirect: (context, state) async {
        await authProvider.checkSession();
        final isLoggedIn  = authProvider.isAuthenticated;
        final isLoginPage = state.matchedLocation == '/login';
        final role        = authProvider.user?.role;

        if (!isLoggedIn && !isLoginPage) return '/login';
        if (isLoggedIn && isLoginPage) {
          return switch (role) {
            'Kader'    => '/dashboard/kader',
            'Bidan'    => '/dashboard/bidan',
            'OrangTua' => '/dashboard/ortu',
            _          => '/login',
          };
        }
        return null;
      },

      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
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
        GoRoute(
          path: '/pemeriksaan/catat',
          name: 'pemeriksaan-catat',
          builder: (context, state) =>
              const PilihAnakPemeriksaanScreen(),
        ),
        GoRoute(
          path: '/imunisasi/catat',
          name: 'imunisasi-catat',
          builder: (context, state) {
            final nikAnak =
                state.uri.queryParameters['nik_anak'] ?? '';
            return CatatImunisasiScreen(nikAnak: nikAnak);
          },
        ),
        GoRoute(
          path: '/jadwal',
          name: 'jadwal',
          builder: (context, state) => const JadwalScreen(),
        ),
        GoRoute(
          path: '/notifikasi',
          name: 'notifikasi',
          builder: (context, state) => const NotifikasiScreen(),
        ),
        GoRoute(
          path: '/kms/:nik',
          name: 'kms',
          builder: (context, state) {
            final nik = state.pathParameters['nik']!;
            return KmsScreen(nikAnak: nik);
          },
        ),

        // ── Placeholder ───────────────────────────────
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
              const Icon(Icons.error_outline_rounded,
                  size: 64, color: Color(0xFFDC3545)),
              const SizedBox(height: 16),
              const Text('Halaman tidak ditemukan',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
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
            const Icon(Icons.construction_rounded,
                size: 48, color: Color(0xFF64748B)),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Segera hadir',
                style: TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}