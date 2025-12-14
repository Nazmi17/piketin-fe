import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_constants.dart';

class DioClient {
  late Dio _dio;
  late PersistCookieJar _cookieJar;

  Dio get dio => _dio;

  // Fungsi inisialisasi (harus dipanggil di main.dart)
  Future<void> init() async {
    // 1. Tentukan lokasi penyimpanan cookie di memory HP
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    // 2. Setup CookieJar agar cookie awet meski aplikasi ditutup
    _cookieJar = PersistCookieJar(
      storage: FileStorage("$appDocPath/.cookies/"),
    );

    // 3. Konfigurasi Dio
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 4. Pasang Interceptor Cookie
    // Ini otomatis mengirim cookie ke backend jika sudah ada,
    // dan menyimpan cookie baru jika ada set-cookie dari backend.
    _dio.interceptors.add(CookieManager(_cookieJar));

    // 5. Tambahkan logger untuk mempermudah debugging saat development
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🌐 API_LOG: $obj'),
      ),
    );
  }

  // Helper untuk menghapus session (saat logout)
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }
}
