// lib/features/jadwal/screens/jadwal_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/jadwal_provider.dart';
import '../models/jadwal_model.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  static const Color _primary     = Color(0xFF0D6EFD);
  static const Color _primaryDark = Color(0xFF0A58CA);
  static const Color _textDark    = Color(0xFF1E293B);
  static const Color _textGrey    = Color(0xFF64748B);
  static const Color _background  = Color(0xFFF4F7FB);
  static const Color _cardWhite   = Color(0xFFFFFFFF);
  static const Color _border      = Color(0xFFE2E8F0);
  static const Color _danger      = Color(0xFFDC3545);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JadwalProvider>().loadList();
    });
  }

  // ── Hari-hari dalam bulan ─────────────────────────────
  List<DateTime?> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay  = DateTime(month.year, month.month + 1, 0);
    // Minggu = 0, offset hari pertama (Minggu=0, Senin=1, dst)
    final startOffset = firstDay.weekday % 7;
    final days = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) {
      days.add(null);
    }
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    return days;
  }

  bool _hasJadwal(DateTime day, List<JadwalModel> list) {
    return list.any((j) {
      final jdt = j.tglDateTime;
      return jdt.year == day.year &&
          jdt.month == day.month &&
          jdt.day == day.day;
    });
  }

  List<JadwalModel> _jadwalOnDay(
      DateTime day, List<JadwalModel> list) {
    return list.where((j) {
      final jdt = j.tglDateTime;
      return jdt.year == day.year &&
          jdt.month == day.month &&
          jdt.day == day.day;
    }).toList();
  }

  void _showFormJadwal({JadwalModel? jadwal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JadwalFormSheet(jadwal: jadwal),
    );
  }

  Future<void> _konfirmasiHapus(JadwalModel jadwal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text(
            'Yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<JadwalProvider>();
      final success  = await provider.hapus(jadwal.idJadwal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Jadwal berhasil dihapus.'
                : provider.errorMessage ?? 'Gagal menghapus.'),
            backgroundColor:
                success ? const Color(0xFF198754) : _danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: _background,
    body: Consumer<JadwalProvider>(
      builder: (context, provider, _) {
        return SafeArea(
          child: RefreshIndicator(
            color: _primary,
            onRefresh: () => provider.loadList(),
            child: CustomScrollView(
              slivers: [
                // ── AppBar pinned ────────────────────
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  automaticallyImplyLeading: false,
                  backgroundColor: _background,
                  elevation: 0,
                  centerTitle: false,  // ← tambah ini
                  title: const Text(
                    'Kelola Jadwal Kegiatan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ),

                // ── Kalender ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: _buildCalendar(provider.list),
                  ),
                ),

                // ── Agenda Terdekat ──────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agenda Terdekat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Lihat Semua',
                              style: TextStyle(
                                  color: _primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── List Jadwal ──────────────────────
                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  )
                else if (provider.upcoming.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          const Text('Belum ada jadwal mendatang',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark)),
                          const SizedBox(height: 8),
                          const Text('Tap + untuk membuat jadwal baru',
                              style: TextStyle(color: _textGrey)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final jadwal = provider.upcoming[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: _buildJadwalCard(jadwal),
                          );
                        },
                        childCount: provider.upcoming.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showFormJadwal(),
      backgroundColor: _primaryDark,
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    ),
  );
}

  // ── Kalender ──────────────────────────────────────────
  Widget _buildCalendar(List<JadwalModel> jadwalList) {
    final days      = _getDaysInMonth(_focusedMonth);
    final dayNames  = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    final today     = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', 'id_ID')
        .format(_focusedMonth);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month - 1);
                    }),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.chevron_left_rounded,
                          color: _textDark,
                          size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() {
                      _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + 1);
                    }),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.chevron_right_rounded,
                          color: _textDark,
                          size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Header hari
          Row(
            children: dayNames.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textGrey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Grid tanggal
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) return const SizedBox();

              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final isSelected = _selectedDay != null &&
                  day.year == _selectedDay!.year &&
                  day.month == _selectedDay!.month &&
                  day.day == _selectedDay!.day;
              final hasJadwal =
                  _hasJadwal(day, jadwalList);

              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedDay = day),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primary
                            : isToday
                                ? const Color(0xFFEAF2FF)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? _primary
                                    : day.month !=
                                            _focusedMonth.month
                                        ? _textGrey
                                        : _textDark,
                          ),
                        ),
                      ),
                    ),
                    if (hasJadwal)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : _primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Kartu Jadwal ──────────────────────────────────────
  Widget _buildJadwalCard(JadwalModel jadwal) {
    final dt = jadwal.tglDateTime;
    final tglStr =
        DateFormat('d MMMM yyyy', 'id_ID').format(dt);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.emoji_emotions_outlined,
                color: _primary, size: 22),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        jadwal.lokasi,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ),
                    // Edit & Hapus
                    GestureDetector(
                      onTap: () =>
                          _showFormJadwal(jadwal: jadwal),
                      child: const Icon(Icons.edit_outlined,
                          color: _textGrey, size: 18),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _konfirmasiHapus(jadwal),
                      child: const Icon(
                          Icons.delete_outline_rounded,
                          color: _danger,
                          size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Tanggal
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: _textGrey),
                    const SizedBox(width: 4),
                    Text(tglStr,
                        style: const TextStyle(
                            fontSize: 12, color: _textGrey)),
                  ],
                ),
                const SizedBox(height: 4),

                // Agenda/Lokasi detail
                if (jadwal.agenda != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: _textGrey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            jadwal.agenda!,
                            style: const TextStyle(
                                fontSize: 12, color: _textGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Sheet Form Jadwal ──────────────────────────────
class _JadwalFormSheet extends StatefulWidget {
  final JadwalModel? jadwal;
  const _JadwalFormSheet({this.jadwal});

  @override
  State<_JadwalFormSheet> createState() =>
      _JadwalFormSheetState();
}

class _JadwalFormSheetState extends State<_JadwalFormSheet> {
  final _judulCtrl   = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  DateTime? _tglKegiatan;

  bool get isEdit => widget.jadwal != null;

  static const Color _primary  = Color(0xFF0D6EFD);
  static const Color _primaryDark = Color(0xFF0A58CA);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGrey = Color(0xFF64748B);
  static const Color _inputBg  = Color(0xFFF1F5F9);
  static const Color _border   = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _judulCtrl.text    = widget.jadwal!.lokasi;
      _deskripsiCtrl.text = widget.jadwal!.agenda ?? '';
      _tglKegiatan        = widget.jadwal!.tglDateTime;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  String get _tglDisplay {
    if (_tglKegiatan == null) return 'Pilih Tanggal';
    return DateFormat('d MMMM yyyy', 'id_ID')
        .format(_tglKegiatan!);
  }

  String get _tglFormatted {
    if (_tglKegiatan == null) return '';
    return '${_tglKegiatan!.year}-'
        '${_tglKegiatan!.month.toString().padLeft(2, '0')}-'
        '${_tglKegiatan!.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglKegiatan ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tglKegiatan = picked);
  }

  Future<void> _submit() async {
    if (_judulCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul kegiatan wajib diisi'),
          backgroundColor: Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_tglKegiatan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal kegiatan'),
          backgroundColor: Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<JadwalProvider>();
    bool success;

    if (isEdit) {
      success = await provider.update(
        idJadwal:    widget.jadwal!.idJadwal,
        tglKegiatan: _tglFormatted,
        lokasi:      _judulCtrl.text.trim(),
        agenda:      _deskripsiCtrl.text.trim().isEmpty
            ? null : _deskripsiCtrl.text.trim(),
      );
    } else {
      success = await provider.buat(
        tglKegiatan: _tglFormatted,
        lokasi:      _judulCtrl.text.trim(),
        agenda:      _deskripsiCtrl.text.trim().isEmpty
            ? null : _deskripsiCtrl.text.trim(),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? provider.successMessage ?? 'Berhasil!'
              : provider.errorMessage ?? 'Gagal menyimpan.'),
          backgroundColor: success
              ? const Color(0xFF198754)
              : const Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      if (success && mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JadwalProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Judul form
                Text(
                  isEdit ? 'Edit Jadwal' : 'Tambah Jadwal Baru',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Buat agenda kegiatan Posyandu mendatang.',
                  style: TextStyle(
                      fontSize: 13, color: _textGrey),
                ),
                const SizedBox(height: 24),

                // ── Judul Kegiatan ────────────────────
                _buildLabel('JUDUL KEGIATAN'),
                const SizedBox(height: 8),
                TextField(
                  controller: _judulCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Posyandu Balita Melati',
                    hintStyle: const TextStyle(
                        color: Color(0xFFCBD5E1)),
                    filled: true,
                    fillColor: _inputBg,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: _primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Tanggal ───────────────────────────
                _buildLabel('TANGGAL KEGIATAN'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    height: 52,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _inputBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _tglKegiatan != null
                            ? _primary
                            : _border,
                        width: _tglKegiatan != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tglDisplay,
                          style: TextStyle(
                            fontSize: 14,
                            color: _tglKegiatan != null
                                ? _textDark
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        Icon(
                          Icons.calendar_month_outlined,
                          color: _tglKegiatan != null
                              ? _primary
                              : const Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Deskripsi ─────────────────────────
                _buildLabel('DESKRIPSI'),
                const SizedBox(height: 8),
                TextField(
                  controller: _deskripsiCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Tambahkan catatan singkat mengenai kegiatan...',
                    hintStyle: const TextStyle(
                        color: Color(0xFFCBD5E1)),
                    filled: true,
                    fillColor: _inputBg,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: _primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Tombol Tambah ─────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: provider.isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryDark,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14)),
                    ),
                    child: provider.isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5))
                        : Text(
                            isEdit
                                ? 'Simpan Perubahan'
                                : 'Tambah Jadwal',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal',
                        style: TextStyle(
                            fontSize: 14, color: _textGrey)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _textGrey,
        letterSpacing: 1,
      ),
    );
  }
}