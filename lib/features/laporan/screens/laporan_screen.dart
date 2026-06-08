// lib/features/laporan/screens/laporan_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/laporan_service.dart';
import '../models/laporan_model.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/network/api_client.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final LaporanService _service = LaporanService();

  static const Color _primary    = Color(0xFF0D6EFD);
  static const Color _textDark   = Color(0xFF1E293B);
  static const Color _textGrey   = Color(0xFF64748B);
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _cardWhite  = Color(0xFFFFFFFF);
  static const Color _border     = Color(0xFFE2E8F0);

  // State form
  String _jenisLaporan = 'Gabungan';
  DateTime _periodeAwal  = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _periodeAkhir = DateTime.now();

  // State data
  bool _isLoading    = false;
  bool _isGenerating = false;
  String? _error;
  LaporanModel? _result;
  List<LaporanModel> _riwayat = [];

  // State multi-select
  bool _isSelectMode = false;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    try {
      final list = await _service.getLaporanList();
      if (mounted) setState(() => _riwayat = list);
    } catch (_) {}
  }

  Future<void> _generate() async {
    setState(() { _isGenerating = true; _error = null; _result = null; });
    try {
      final laporan = await _service.buatLaporan(
        jenis:        _jenisLaporan,
        periodeAwal:  DateFormat('yyyy-MM-dd').format(_periodeAwal),
        periodeAkhir: DateFormat('yyyy-MM-dd').format(_periodeAkhir),
      );
      setState(() { _result = laporan; _isGenerating = false; });
      _loadRiwayat();
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isGenerating = false; });
    }
  }



  Future<void> _hapusBulk() async {
    if (_selected.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Laporan Terpilih'),
        content: Text('Yakin ingin menghapus ${_selected.length} laporan yang dipilih?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Color(0xFFDC3545)))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isGenerating = true);
      int berhasil = 0;
      for (final id in _selected) {
        try {
          await _service.hapusLaporan(id);
          berhasil++;
        } catch (_) {}
      }
      _selected.clear();
      _isSelectMode = false;
      await _loadRiwayat();
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$berhasil laporan berhasil dihapus'),
              backgroundColor: const Color(0xFF198754)),
        );
      }
    }
  }

  Future<void> _hapusLaporan(int idLaporan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text('Yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Color(0xFFDC3545)))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.hapusLaporan(idLaporan);
        // Jika laporan yang dihapus adalah yang sedang ditampilkan, reset result
        if (_result?.idLaporan == idLaporan) setState(() => _result = null);
        _loadRiwayat();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan berhasil dihapus'),
                backgroundColor: Color(0xFF198754)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus laporan'),
                backgroundColor: Color(0xFFDC3545)),
          );
        }
      }
    }
  }

  Future<void> _openExport(int idLaporan, String format) async {
    setState(() => _isGenerating = true);
    try {
      final dio = ApiClient.instance.dio;
      final dir = await getTemporaryDirectory();
      final ext = format == 'excel' ? 'xlsx' : 'pdf';
      final path = '${dir.path}/laporan_$idLaporan.$ext';
      await dio.download(
        '/laporan/$idLaporan/export-$format',
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      setState(() => _isGenerating = false);
      await OpenFilex.open(path);
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal download: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: const Color(0xFFDC3545),
          ),
        );
      }
    }
  }

  Future<void> _pickDate(bool isAwal) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isAwal ? _periodeAwal : _periodeAkhir,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isAwal) _periodeAwal = picked;
        else _periodeAkhir = picked;
      });
    }
  }

  String _formatTgl(String tgl) {
    try {
      return DateFormat('d MMM yyyy', 'id_ID').format(DateTime.parse(tgl));
    } catch (_) { return tgl; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _cardWhite,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: const BackButton(color: _textDark),
        title: const Text('Laporan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Form Generate ─────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Buat Laporan Baru',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
                  const SizedBox(height: 16),

                  // Jenis laporan
                  const Text('JENIS LAPORAN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: _textGrey, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _jenisBtn('Pemeriksaan'),
                    const SizedBox(width: 8),
                    _jenisBtn('Imunisasi'),
                    const SizedBox(width: 8),
                    _jenisBtn('Gabungan'),
                  ]),
                  const SizedBox(height: 16),

                  // Periode
                  const Text('PERIODE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: _textGrey, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _datePicker('Dari', _periodeAwal, () => _pickDate(true))),
                    const SizedBox(width: 10),
                    Expanded(child: _datePicker('Sampai', _periodeAkhir, () => _pickDate(false))),
                  ]),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isGenerating
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.bar_chart_rounded, color: Colors.white),
                      label: Text(_isGenerating ? 'Memproses...' : 'Generate Laporan',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Error ──────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Color(0xFFDC3545), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                      style: const TextStyle(fontSize: 13, color: Color(0xFFDC3545)))),
                ]),
              ),
            ],

            // ── Hasil Laporan ─────────────────────────
            if (_result != null) ...[
              const SizedBox(height: 20),
              _buildHasilLaporan(_result!),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openExport(_result!.idLaporan, 'excel'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF198754)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.table_chart_outlined, color: Color(0xFF198754), size: 20),
                  label: const Text('Export Excel', style: TextStyle(
                      color: Color(0xFF198754), fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],

            // ── Riwayat ───────────────────────────────
            if (_riwayat.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Laporan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _isSelectMode = !_isSelectMode;
                      _selected.clear();
                    }),
                    icon: Icon(_isSelectMode ? Icons.close_rounded : Icons.checklist_rounded,
                        size: 16, color: _isSelectMode ? const Color(0xFFDC3545) : _primary),
                    label: Text(_isSelectMode ? 'Batal' : 'Pilih',
                        style: TextStyle(fontSize: 12,
                            color: _isSelectMode ? const Color(0xFFDC3545) : _primary)),
                  ),
                ],
              ),
              if (_isSelectMode && _selected.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _hapusBulk,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC3545),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 18),
                    label: Text('Hapus Terpilih (${_selected.length})',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ..._riwayat.map((l) => _buildRiwayatCard(l)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _jenisBtn(String jenis) {
    final isSelected = _jenisLaporan == jenis;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _jenisLaporan = jenis),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(jenis,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : _textGrey,
                )),
          ),
        ),
      ),
    );
  }

  Widget _datePicker(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: _primary),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 10, color: _textGrey)),
            Text(DateFormat('d MMM yyyy', 'id_ID').format(date),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildHasilLaporan(LaporanModel laporan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(laporan.jenis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _primary)),
            ),
            const Spacer(),
            Text(_formatTgl(laporan.tglCetak),
                style: const TextStyle(fontSize: 12, color: _textGrey)),
          ]),
          const SizedBox(height: 8),
          Text(
            '${_formatTgl(laporan.periodeAwal)} – ${_formatTgl(laporan.periodeAkhir)}',
            style: const TextStyle(fontSize: 13, color: _textGrey),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Ringkasan Pemeriksaan
          if (laporan.ringkasan?.pemeriksaan != null) ...[
            const Text('PEMERIKSAAN',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: _textGrey, letterSpacing: 1)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _statBox('Total Periksa',
                  '${laporan.ringkasan!.pemeriksaan!.total}', _primary)),
              const SizedBox(width: 10),
              Expanded(child: _statBox('Total Balita',
                  '${laporan.ringkasan!.pemeriksaan!.totalAnak}', const Color(0xFF198754))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _statBox('Rata BB',
                  '${laporan.ringkasan!.pemeriksaan!.rataBerat ?? "-"} kg',
                  const Color(0xFF6F42C1))),
              const SizedBox(width: 10),
              Expanded(child: _statBox('Rata TB',
                  '${laporan.ringkasan!.pemeriksaan!.rataTinggi ?? "-"} cm',
                  const Color(0xFFE85D04))),
            ]),
            const SizedBox(height: 16),
          ],

          // Ringkasan Imunisasi
          if (laporan.ringkasan?.imunisasi != null) ...[
            const Text('IMUNISASI',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: _textGrey, letterSpacing: 1)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _statBox('Total Imunisasi',
                  '${laporan.ringkasan!.imunisasi!.total}', _primary)),
              const SizedBox(width: 10),
              Expanded(child: _statBox('Total Balita',
                  '${laporan.ringkasan!.imunisasi!.totalAnak}', const Color(0xFF198754))),
            ]),
            if (laporan.ringkasan!.imunisasi!.perVaksin.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Per Vaksin:',
                  style: TextStyle(fontSize: 12, color: _textGrey)),
              const SizedBox(height: 6),
              ...laporan.ringkasan!.imunisasi!.perVaksin.entries.map((e) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Container(width: 8, height: 8,
                        decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(e.key, style: const TextStyle(fontSize: 13, color: _textDark)),
                    const Spacer(),
                    Text('${e.value} dosis',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
                  ]),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }

  Widget _buildRiwayatCard(LaporanModel laporan) {
    final isSelected = _selected.contains(laporan.idLaporan);
    return GestureDetector(
      onTap: _isSelectMode ? () {
        setState(() {
          if (isSelected) _selected.remove(laporan.idLaporan);
          else _selected.add(laporan.idLaporan);
        });
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected && _isSelectMode ? const Color(0xFFEAF2FF) : _cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected && _isSelectMode ? _primary : _border,
            width: isSelected && _isSelectMode ? 1.5 : 1,
          ),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              // Checkbox saat mode select, ikon biasa saat normal
              if (_isSelectMode)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? _primary : Colors.transparent,
                      border: Border.all(color: isSelected ? _primary : _textGrey, width: 2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : null,
                  ),
                )
              else
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.description_outlined, color: _primary, size: 20),
                ),
              if (!_isSelectMode) const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Laporan ${laporan.jenis}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                Text('${_formatTgl(laporan.periodeAwal)} – ${_formatTgl(laporan.periodeAkhir)}',
                    style: const TextStyle(fontSize: 12, color: _textGrey)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(6)),
                child: Text(laporan.jenis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _primary)),
              ),
            ]),
          ),
          // Tombol aksi hanya muncul saat bukan mode select
          if (!_isSelectMode) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(children: [
                Expanded(child: TextButton.icon(
                  onPressed: () async {
                    final detail = await _service.getDetail(laporan.idLaporan);
                    if (mounted) setState(() => _result = detail);
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16, color: _primary),
                  label: const Text('Detail', style: TextStyle(fontSize: 12, color: _primary)),
                )),
                Container(width: 1, height: 24, color: _border),
                Expanded(child: TextButton.icon(
                  onPressed: () => _openExport(laporan.idLaporan, 'excel'),
                  icon: const Icon(Icons.table_chart_outlined, size: 16, color: Color(0xFF198754)),
                  label: const Text('Excel', style: TextStyle(fontSize: 12, color: Color(0xFF198754))),
                )),
                Container(width: 1, height: 24, color: _border),
                Expanded(child: TextButton.icon(
                  onPressed: () => _hapusLaporan(laporan.idLaporan),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC3545)),
                  label: const Text('Hapus', style: TextStyle(fontSize: 12, color: Color(0xFFDC3545))),
                )),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}