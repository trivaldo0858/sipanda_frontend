// lib/features/notifikasi/screens/notifikasi_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notifikasi_provider.dart';
import '../models/notifikasi_model.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  static const Color _primary    = Color(0xFF0D6EFD);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textGrey   = Color(0xFF64748B);
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _cardWhite  = Color(0xFFFFFFFF);
  static const Color _border     = Color(0xFFE2E8F0);
  static const Color _danger     = Color(0xFFDC3545);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotifikasiProvider>().loadList();
    });
  }

  String _timeAgo(String tgl) {
    try {
      final dt   = DateTime.parse(tgl);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return DateFormat('d MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return tgl;
    }
  }

  IconData _getIcon(String jenis) {
    return switch (jenis) {
      'Posyandu'    => Icons.calendar_today_rounded,
      'Imunisasi'   => Icons.vaccines_outlined,
      'Pemeriksaan' => Icons.monitor_heart_outlined,
      _             => Icons.notifications_outlined,
    };
  }

  Color _getColor(String jenis) {
    return switch (jenis) {
      'Posyandu'    => _primary,
      'Imunisasi'   => const Color(0xFF6F42C1),
      'Pemeriksaan' => const Color(0xFF198754),
      _             => const Color(0xFF64748B),
    };
  }

  Color _getBgColor(String jenis) {
    return switch (jenis) {
      'Posyandu'    => const Color(0xFFEAF2FF),
      'Imunisasi'   => const Color(0xFFF0EBFF),
      'Pemeriksaan' => const Color(0xFFD1E7DD),
      _             => const Color(0xFFF1F5F9),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: _cardWhite,
        foregroundColor: _textDark,
        elevation: 0,
        actions: [
          Consumer<NotifikasiProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox();
              return TextButton(
                onPressed: () => provider.markAllRead(),
                child: const Text(
                  'Baca Semua',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotifikasiProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          if (provider.status == NotifikasiStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 48, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(provider.errorMessage ?? 'Gagal memuat',
                      style: const TextStyle(color: _textGrey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadList(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                        Icons.notifications_none_rounded,
                        color: _primary,
                        size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Notifikasi jadwal dan imunisasi\nakan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _textGrey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: _primary,
            onRefresh: () => provider.loadList(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Belum Dibaca ──────────────────────
                if (provider.belumDibaca.isNotEmpty) ...[
                  _buildSectionHeader(
                      'Belum Dibaca', provider.belumDibaca.length),
                  const SizedBox(height: 8),
                  ...provider.belumDibaca.map((n) =>
                      _buildNotifCard(context, n, provider)),
                  const SizedBox(height: 16),
                ],

                // ── Sudah Dibaca ──────────────────────
                if (provider.sudahDibaca.isNotEmpty) ...[
                  _buildSectionHeader('Sudah Dibaca', null),
                  const SizedBox(height: 8),
                  ...provider.sudahDibaca.map((n) =>
                      _buildNotifCard(context, n, provider)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int? count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textGrey,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotifCard(BuildContext context,
      NotifikasiModel notif, NotifikasiProvider provider) {
    final color   = _getColor(notif.jenisNotif);
    final bgColor = _getBgColor(notif.jenisNotif);
    final icon    = _getIcon(notif.jenisNotif);

    return Dismissible(
      key: Key('notif_${notif.idNotifikasi}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _danger,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      onDismissed: (_) => provider.delete(notif.idNotifikasi),
      child: GestureDetector(
        onTap: () {
          if (notif.isBelumDibaca) {
            provider.markRead(notif.idNotifikasi);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isBelumDibaca
                ? _cardWhite
                : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notif.isBelumDibaca
                  ? color.withAlpha(80)
                  : _border,
              width: notif.isBelumDibaca ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),

              // Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notif.jenisLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (notif.isBelumDibaca)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.pesan,
                      style: TextStyle(
                        fontSize: 13,
                        color: notif.isBelumDibaca
                            ? _textDark
                            : _textGrey,
                        height: 1.4,
                        fontWeight: notif.isBelumDibaca
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notif.tglKirim),
                      style: const TextStyle(
                          fontSize: 11, color: _textGrey),
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
}