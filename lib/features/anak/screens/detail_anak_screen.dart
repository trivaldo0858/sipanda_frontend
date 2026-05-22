// lib/features/anak/screens/detail_anak_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/anak_provider.dart';
import '../models/anak_model.dart';

class DetailAnakScreen extends StatefulWidget {
  final String nikAnak;
  const DetailAnakScreen({super.key, required this.nikAnak});

  @override
  State<DetailAnakScreen> createState() => _DetailAnakScreenState();
}

class _DetailAnakScreenState extends State<DetailAnakScreen> {
  static const Color _primary    = Color(0xFF0D6EFD);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textGrey   = Color(0xFF64748B);
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _cardWhite  = Color(0xFFFFFFFF);
  static const Color _border     = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnakProvider>().loadAnakDetail(widget.nikAnak);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(title: const Text('Detail Balita')),
      body: Consumer<AnakProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: _primary));
          }

          if (provider.status == AnakStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(provider.errorMessage ?? 'Gagal memuat',
                      style: const TextStyle(color: _textGrey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        provider.loadAnakDetail(widget.nikAnak),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final anak = provider.selectedAnak;
          if (anak == null) return const SizedBox();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeaderCard(anak),
                const SizedBox(height: 16),
                _buildInfoCard(anak),
                const SizedBox(height: 16),
                _buildAksiCard(context, anak),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(AnakModel anak) {
    final color =
        anak.isLakiLaki ? _primary : const Color(0xFFE91E63);
    final bgColor = anak.isLakiLaki
        ? const Color(0xFFEAF2FF)
        : const Color(0xFFFCE4EC);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              anak.isLakiLaki
                  ? Icons.face_rounded
                  : Icons.face_3_rounded,
              color: color,
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            anak.namaAnak,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            anak.nikAnak,
            style: const TextStyle(fontSize: 13, color: _textGrey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(
                anak.jenisKelaminLabel,
                color,
                bgColor,
              ),
              if (anak.umurFormat != null) ...[
                const SizedBox(width: 8),
                _buildBadge(
                  anak.umurFormat!,
                  const Color(0xFF198754),
                  const Color(0xFFD1E7DD),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AnakModel anak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Balita',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tanggal Lahir', anak.tglLahir),
          _buildInfoRow('Nama Ayah', anak.namaAyah),
          _buildInfoRow('NIK Ibu', anak.nikOrangTua),
          if (anak.namaPosyandu != null)
            _buildInfoRow('Posyandu', anak.namaPosyandu!),
        ],
      ),
    );
  }

  Widget _buildAksiCard(BuildContext context, AnakModel anak) {
    return Column(
      children: [
        // Catat Pemeriksaan
        _buildAksiButton(
          icon: Icons.monitor_heart_outlined,
          label: 'Catat Pemeriksaan',
          subtitle: 'Input BB, TB, Lingkar Kepala',
          color: _primary,
          bgColor: const Color(0xFFEAF2FF),
          onTap: () => context
              .push('/pemeriksaan/catat?nik_anak=${anak.nikAnak}'),
        ),
        const SizedBox(height: 10),

        // Lihat KMS
        _buildAksiButton(
          icon: Icons.show_chart_rounded,
          label: 'Grafik KMS',
          subtitle: 'Kurva pertumbuhan WHO',
          color: const Color(0xFF198754),
          bgColor: const Color(0xFFD1E7DD),
          onTap: () => context.push('/kms/${anak.nikAnak}'),
        ),
        const SizedBox(height: 10),

        // Catat Imunisasi
        _buildAksiButton(
          icon: Icons.vaccines_outlined,
          label: 'Catat Imunisasi',
          subtitle: 'Riwayat pemberian vaksin',
          color: const Color(0xFF6F42C1),
          bgColor: const Color(0xFFF0EBFF),
          onTap: () => context
              .push('/imunisasi/catat?nik_anak=${anak.nikAnak}'),
        ),
        const SizedBox(height: 10),

        // Edit
        _buildAksiButton(
          icon: Icons.edit_outlined,
          label: 'Edit Data Balita',
          subtitle: 'Perbarui informasi balita',
          color: const Color(0xFF64748B),
          bgColor: const Color(0xFFF1F5F9),
          onTap: () => context.push('/anak/tambah', extra: anak),
        ),
      ],
    );
  }

  Widget _buildAksiButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
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
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _textDark)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: _textGrey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: _textGrey)),
          ),
          const Text(': ',
              style: TextStyle(color: _textGrey)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}