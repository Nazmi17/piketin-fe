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
    // [FIX 1] Gunakan getApplicationSupportDirectory alih-alih Documents.
    // Di Windows, ini mengarah ke AppData/Roaming yang aman dari OneDrive.
    // Di Android/iOS, ini mengarah ke folder internal aplikasi yang aman.
    final Directory appDocDir = await getApplicationSupportDirectory();
    final String appDocPath = appDocDir.path;

    // 2. Setup CookieJar
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
    _dio.interceptors.add(CookieManager(_cookieJar));

    // 5. Logger
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
    // [FIX 2] Bungkus dengan try-catch.
    // Jika file terkunci (OS Error), aplikasi tidak akan crash,
    // dan user tetap bisa logout secara logika di aplikasi.
    try {
      await _cookieJar.deleteAll();
    } catch (e) {
      print("⚠️ Gagal menghapus file cookie fisik (aman untuk diabaikan): $e");
    }
  }
}
