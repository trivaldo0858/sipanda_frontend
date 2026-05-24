// lib/features/kms/screens/kms_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../models/kms_model.dart';
import '../services/kms_service.dart';

class KmsScreen extends StatefulWidget {
  final String nikAnak;
  const KmsScreen({super.key, required this.nikAnak});

  @override
  State<KmsScreen> createState() => _KmsScreenState();
}

class _KmsScreenState extends State<KmsScreen> {
  final KmsService _service = KmsService();

  KmsModel? _data;
  bool      _isLoading = true;
  String?   _error;

  static const Color _primary     = Color(0xFF0D6EFD);
  static const Color _primaryDark = Color(0xFF0A58CA);
  static const Color _textDark    = Color(0xFF1E293B);
  static const Color _textGrey    = Color(0xFF64748B);
  static const Color _background  = Color(0xFFF7F9FC);
  static const Color _cardWhite   = Color(0xFFFFFFFF);
  static const Color _border      = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _service.getKms(widget.nikAnak);
      setState(() { _data = data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  String _formatTanggal(String tgl) {
    try {
      final dt = DateTime.parse(tgl);
      return DateFormat('d MMM yyyy', 'id_ID').format(dt);
    } catch (_) { return tgl; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(_data?.namaAnak ?? 'KMS Digital'),
        backgroundColor: _cardWhite,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(_error ?? 'Gagal memuat',
              style: const TextStyle(color: _textGrey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _data!;
    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderAnak(data),
          const SizedBox(height: 20),
          _buildGrafikSection(data),
          const SizedBox(height: 20),
          _buildKunjunganSection(data),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────
  Widget _buildHeaderAnak(KmsModel data) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            data.isLakiLaki
                ? Icons.face_rounded
                : Icons.face_3_rounded,
            color: data.isLakiLaki
                ? _primary
                : const Color(0xFFE91E63),
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.namaAnak,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              Text(
                data.umurFormat ?? '',
                style: const TextStyle(
                    fontSize: 13, color: _textGrey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'KMS Digital',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Grafik ────────────────────────────────────────────
  Widget _buildGrafikSection(KmsModel data) {
    return Container(
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
            'Grafik Tumbuh Kembang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegend('Berat (BB)', _primary),
              const SizedBox(width: 16),
              _buildLegend('Tinggi (TB)', const Color(0xFF6F42C1)),
            ],
          ),
          const SizedBox(height: 16),
          if (data.pemeriksaanUrut.isEmpty)
            Container(
              height: 160,
              alignment: Alignment.center,
              child: const Text('Belum ada data pemeriksaan',
                  style: TextStyle(color: _textGrey)),
            )
          else
            SizedBox(
              height: 180,
              child: _GrafikPertumbuhan(
                  pemeriksaan: data.pemeriksaanUrut),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: _textGrey)),
      ],
    );
  }

  // ── Kunjungan Rutin ───────────────────────────────────
  Widget _buildKunjunganSection(KmsModel data) {
    final list = data.pemeriksaan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kunjungan Rutin',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: const Center(
              child: Text('Belum ada data kunjungan',
                  style: TextStyle(color: _textGrey)),
            ),
          )
        else
          ...list.asMap().entries.map((entry) {
            return _buildKunjunganCard(
                entry.value, entry.key == 0);
          }),
      ],
    );
  }

  Widget _buildKunjunganCard(
      KmsPemeriksaan periksa, bool isFirst) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFirst
              ? _primary.withAlpha(80)
              : _border,
          width: isFirst ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFirst)
            const Text(
              'KUNJUNGAN TERAKHIR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _primary,
                letterSpacing: 0.5,
              ),
            ),
          Text(
            _formatTanggal(periksa.tglPeriksa),
            style: TextStyle(
              fontSize: isFirst ? 16 : 14,
              fontWeight: isFirst
                  ? FontWeight.w700
                  : FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  label: isFirst ? 'BERAT' : 'BB',
                  value: periksa.beratBadan != null
                      ? '${periksa.beratBadan} kg'
                      : '-',
                  isFirst: isFirst,
                ),
              ),
              Expanded(
                child: _buildDataItem(
                  label: isFirst ? 'TINGGI' : 'TB',
                  value: periksa.tinggiBadan != null
                      ? '${periksa.tinggiBadan} cm'
                      : '-',
                  isFirst: isFirst,
                ),
              ),
              Expanded(
                child: _buildDataItem(
                  label: isFirst ? 'L. KEPALA' : 'LK',
                  value: periksa.lingkarKepala != null
                      ? '${periksa.lingkarKepala} cm'
                      : '-',
                  isFirst: isFirst,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem({
    required String label,
    required String value,
    required bool isFirst,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textGrey,
            )),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isFirst ? 16 : 14,
            fontWeight: isFirst
                ? FontWeight.w700
                : FontWeight.w500,
            color: isFirst ? _primary : _textDark,
          ),
        ),
      ],
    );
  }
}

// ── Custom Grafik ─────────────────────────────────────────
class _GrafikPertumbuhan extends StatelessWidget {
  final List<KmsPemeriksaan> pemeriksaan;
  const _GrafikPertumbuhan({required this.pemeriksaan});

  @override
  Widget build(BuildContext context) {
    if (pemeriksaan.isEmpty) return const SizedBox();
    final bbData = pemeriksaan
        .where((p) => p.beratBadan != null)
        .map((p) => p.beratBadan!)
        .toList();
    final tbData = pemeriksaan
        .where((p) => p.tinggiBadan != null)
        .map((p) => p.tinggiBadan!)
        .toList();
    final labels = pemeriksaan.map((p) {
      try {
        final dt = DateTime.parse(p.tglPeriksa);
        return '${dt.month}/${dt.year.toString().substring(2)}';
      } catch (_) { return ''; }
    }).toList();

    return CustomPaint(
      painter: _GrafikPainter(
          bbData: bbData, tbData: tbData, labels: labels),
      child: const SizedBox.expand(),
    );
  }
}

class _GrafikPainter extends CustomPainter {
  final List<double> bbData;
  final List<double> tbData;
  final List<String> labels;

  _GrafikPainter({
    required this.bbData,
    required this.tbData,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 10.0, padR = 10.0, padT = 10.0, padB = 30.0;
    final w = size.width  - padL - padR;
    final h = size.height - padT - padB;

    final paintBB = Paint()
      ..color = const Color(0xFF0D6EFD)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintTB = Paint()
      ..color = const Color(0xFF6F42C1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background area BB
    if (bbData.length > 1) {
      final minBB = bbData.reduce(math.min);
      final maxBB = bbData.reduce(math.max);
      final range = (maxBB - minBB).clamp(1.0, double.infinity);
      final bgPath = Path();
      for (int i = 0; i < bbData.length; i++) {
        final x = padL + (i / (bbData.length - 1)) * w;
        final y = padT + h - ((bbData[i] - minBB) / range) * h;
        i == 0 ? bgPath.moveTo(x, y) : bgPath.lineTo(x, y);
      }
      bgPath.lineTo(padL + w, padT + h);
      bgPath.lineTo(padL, padT + h);
      bgPath.close();
      canvas.drawPath(bgPath,
          Paint()
            ..color = const Color(0xFFEAF2FF).withAlpha(150)
            ..style = PaintingStyle.fill);
    }

    _drawLine(canvas, bbData, paintBB,
        const Color(0xFF0D6EFD), padL, padR, padT, padB, size);
    _drawDashedLine(canvas, tbData, paintTB,
        padL, padR, padT, padB, size);

    // Label X
    if (labels.isNotEmpty) {
      final count = math.min(labels.length, 5);
      for (int i = 0; i < count; i++) {
        final idx = labels.length == 1
            ? 0
            : (i * (labels.length - 1) / (count - 1))
                .round()
                .clamp(0, labels.length - 1);
        final x = labels.length == 1
            ? padL + w / 2
            : padL + (idx / (labels.length - 1)) * w;
        final tp = TextPainter(
          text: TextSpan(
            text: labels[idx],
            style: const TextStyle(
                fontSize: 9, color: Color(0xFF94A3B8)),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas,
            Offset(x - tp.width / 2, size.height - padB + 6));
      }
    }
  }

  void _drawLine(Canvas canvas, List<double> data, Paint paint,
      Color dotColor, double padL, double padR,
      double padT, double padB, Size size) {
    if (data.length < 1) return;
    final w = size.width  - padL - padR;
    final h = size.height - padT - padB;
    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).clamp(1.0, double.infinity);

    if (data.length == 1) {
      final x = padL + w / 2;
      final y = padT + h / 2;
      canvas.drawCircle(
          Offset(x, y), 5,
          Paint()..color = dotColor..style = PaintingStyle.fill);
      canvas.drawCircle(
          Offset(x, y), 2.5,
          Paint()..color = Colors.white..style = PaintingStyle.fill);
      return;
    }

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = padL + (i / (data.length - 1)) * w;
      final y = padT + h - ((data[i] - minV) / range) * h;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < data.length; i++) {
      final x = padL + (i / (data.length - 1)) * w;
      final y = padT + h - ((data[i] - minV) / range) * h;
      dotPaint.color = dotColor;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      dotPaint.color = Colors.white;
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, List<double> data, Paint paint,
      double padL, double padR, double padT, double padB, Size size) {
    if (data.length < 2) return;
    final w = size.width  - padL - padR;
    final h = size.height - padT - padB;
    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).clamp(1.0, double.infinity);

    for (int i = 0; i < data.length - 1; i++) {
      final x1 = padL + (i / (data.length - 1)) * w;
      final y1 = padT + h - ((data[i] - minV) / range) * h;
      final x2 = padL + ((i + 1) / (data.length - 1)) * w;
      final y2 = padT + h - ((data[i + 1] - minV) / range) * h;
      final dx = x2 - x1, dy = y2 - y1;
      final dist = math.sqrt(dx * dx + dy * dy);
      var drawn = 0.0; var isDash = true;
      while (drawn < dist) {
        final len = math.min(isDash ? 8.0 : 4.0, dist - drawn);
        final t1 = drawn / dist, t2 = (drawn + len) / dist;
        if (isDash) {
          canvas.drawLine(
            Offset(x1 + dx * t1, y1 + dy * t1),
            Offset(x1 + dx * t2, y1 + dy * t2),
            paint,
          );
        }
        drawn += len; isDash = !isDash;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}