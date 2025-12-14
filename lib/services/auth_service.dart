import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

class AuthService {
  final DioClient dioClient;

  AuthService(this.dioClient);

  // Login: Mengirim username & password, lalu menyimpan data User
  // Cookie otomatis disimpan oleh DioClient (CookieManager)
  Future<User?> login(String username, String password) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.authLogin,
        data: {"username": username, "password": password},
      );

      // Backend kamu mengembalikan struktur:
      // { success: true, message: "...", data: { id, username, ... } }
      final apiResponse = ApiResponse<User>.fromJson(
        response.data,
        (json) => User.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse.data;
    } on DioException catch (e) {
      // Menangkap error dari backend (misal: 401 Invalid password)
      final errorMessage =
          e.response?.data['message'] ?? "Terjadi kesalahan saat login";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Gagal terhubung ke server");
    }
  }

  // Get Me: Mengecek apakah user masih login (session valid)
  // Endpoint ini diproteksi oleh authMiddleware di backend
  Future<User?> getMe() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.authMe);

      final apiResponse = ApiResponse<User>.fromJson(
        response.data,
        (json) => User.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse.data;
    } catch (e) {
      // Jika error (misal 401 Unauthorized), berarti session habis/belum login
      return null;
    }
  }

  // Logout: Menghapus session di backend dan cookie di HP
  Future<void> logout() async {
    try {
      await dioClient.dio.post(ApiConstants.authLogout);
    } catch (e) {
      // Ignore error logout
    } finally {
      // Selalu hapus cookie di lokal, sukses atau gagal requestnya
      await dioClient.clearCookies();
    }
  }
}
