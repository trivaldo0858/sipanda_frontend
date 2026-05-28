import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AnakService {
  // Menggunakan instance dio global dari ApiClient yang sudah kamu buat
  final Dio _dio = ApiClient.instance.dio;

  /// Mengambil daftar anak yang terikat dengan akun Orang Tua yang sedang login
  Future<List<Map<String, dynamic>>> fetchAnakOrangTua() async {
    try {
      // Menembak endpoint API Laravel (Base URL otomatis diambil dari ApiClient)
      final response = await _dio.get('/orangtua/anak');

      if (response.statusCode == 200) {
        // Mengambil array data di dalam response JSON Laravel
        final List<dynamic> dataRaw = response.data['data'];
        
        // Memetakan data menjadi List<Map<String, dynamic>> agar siap dikonsumsi UI
        return dataRaw.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Gagal memuat data anak: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Memanfaatkan LogInterceptor kamu untuk memantau jika terjadi timeout/koneksi putus
      throw Exception('Terjadi kesalahan jaringan: ${e.message}');
    }
  }
}