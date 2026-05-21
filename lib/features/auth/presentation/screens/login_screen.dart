import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controller Input Form
  final TextEditingController _usernameBidanController =
      TextEditingController();
  final TextEditingController _passwordBidanController =
      TextEditingController();
  final TextEditingController _passwordPosyanduController =
      TextEditingController();
  final TextEditingController _nikBalitaController = TextEditingController();
  final TextEditingController _tglLahirBalitaController =
      TextEditingController();

  String? _selectedPosyandu;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Membuat 3 Tab sesuai Aktor di SRS: 0 = Posyandu (Kader), 1 = Bidan, 2 = Orang Tua
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameBidanController.dispose();
    _passwordBidanController.dispose();
    _passwordPosyanduController.dispose();
    _nikBalitaController.dispose();
    _tglLahirBalitaController.dispose();
    super.dispose();
  }

  // Fungsi Pembantu Membuka Date Picker untuk Orang Tua
  Future<void> _pilihTanggalLahir(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tglLahirBalitaController.text = DateFormat(
          'dd-MM-yyyy',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'SIPANDA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text(
                  'Sistem Informasi Posyandu Anak Digital',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Posyandu'),
                      Tab(text: 'Bidan'),
                      Tab(text: 'Orang Tua'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Isi Form sesuai Tab Aktif
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPosyanduForm(),
                      _buildBidanForm(),
                      _buildOrangTuaForm(),
                    ],
                  ),
                ),

                // Tombol Submit Utama
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Jalankan fungsi login menembak API Laravel
                    }
                  },
                  child: const Text(
                    'Masuk Aplikasi',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // OPSI SSO GOOGLE (Wajib Ada Sesuai SRS Poin 4)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Jalankan fungsi repositori remoteDataSource.loginGoogle
                  },
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: Colors.red,
                    size: 30,
                  ),
                  label: const Text(
                    'Masuk dengan Akun Google',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. FORM POSYANDU: Dropdown Lokasi + Password
  Widget _buildPosyanduForm() {
    return ListView(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedPosyandu,
          hint: const Text('Pilih Lokasi Posyandu'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: const [
            DropdownMenuItem(
              value: 'posyandu_anggrek',
              child: Text('Posyandu Anggrek (Lohbener)'),
            ),
            DropdownMenuItem(
              value: 'posyandu_mawar',
              child: Text('Posyandu Mawar (Langut)'),
            ),
            DropdownMenuItem(
              value: 'posyandu_melati',
              child: Text('Posyandu Melati (Larangan)'),
            ),
          ],
          onChanged: (value) => setState(() => _selectedPosyandu = value),
          validator: (value) =>
              value == null ? 'Lokasi posyandu wajib dipilih' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordPosyanduController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            labelText: 'Password Posyandu',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) => value!.isEmpty ? 'Password wajib diisi' : null,
        ),
      ],
    );
  }

  // 2. FORM BIDAN: Username + Password
  Widget _buildBidanForm() {
    return ListView(
      children: [
        TextFormField(
          controller: _usernameBidanController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person),
            labelText: 'Username Bidan',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) => value!.isEmpty ? 'Username wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordBidanController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) => value!.isEmpty ? 'Password wajib diisi' : null,
        ),
      ],
    );
  }

  // 3. FORM ORANG TUA: NIK Balita + Date Picker Tanggal Lahir Balita
  Widget _buildOrangTuaForm() {
    return ListView(
      children: [
        TextFormField(
          controller: _nikBalitaController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.badge),
            labelText: 'NIK Balita',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) =>
              value!.isEmpty ? 'NIK Balita wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tglLahirBalitaController,
          readOnly: true,
          onTap: () => _pilihTanggalLahir(context),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_month),
            labelText: 'Tanggal Lahir Balita',
            hintText: 'Pilih Tanggal',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) =>
              value!.isEmpty ? 'Tanggal lahir balita wajib diisi' : null,
        ),
      ],
    );
  }
}
