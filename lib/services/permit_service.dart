import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
// import '../models/api_response.dart'; // Tidak wajib jika parsing manual
import '../models/student_permit_model.dart';

class PermitService {
  final DioClient dioClient;

  PermitService(this.dioClient);

  // 1. GET ALL PERMITS (Tetap sama)
  Future<List<StudentPermit>> getPermits({
    int page = 1,
    int limit = 10,
    String? search,
    List<String>? status,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.permits,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status[]': status,
        },
      );

      final List<dynamic> rawList = response.data['data'];
      return rawList
          .map((json) => StudentPermit.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Gagal mengambil data izin",
      );
    }
  }

  // 2. CREATE PERMIT (DIUBAH)
  // Return type diganti jadi Future<bool> agar tidak perlu parsing Model yang kompleks
  Future<bool> createPermit({
    required String studentNis,
    required String reason,
    required int hoursStart,
    required int mapelUserId,
    int? hoursEnd,
  }) async {
    try {
      // Kita tidak perlu menampung response ke variabel jika tidak diparsing
      await dioClient.dio.post(
        ApiConstants.permits,
        data: {
          "student_nis": studentNis,
          "reason": reason,
          "hours_start": hoursStart,
          "hours_end": hoursEnd,
          "mapel_user_id": mapelUserId,
        },
      );

      // Jika tidak ada error (exception), anggap sukses
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal membuat izin");
    }
  }

  // ... (method getPendingMapel, getPendingPiket, processPermit tetap sama) ...
  Future<List<StudentPermit>> getPendingMapel() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.permitsPendingMapel,
      );
      final List<dynamic> rawList = response.data['data'];
      return rawList.map((e) => StudentPermit.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<StudentPermit>> getPendingPiket() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.permitsPendingPiket,
      );
      final List<dynamic> rawList = response.data['data'];
      return rawList.map((e) => StudentPermit.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> processPermit({
    required int id,
    required String actionType,
    required String status,
  }) async {
    try {
      final String endpoint = actionType == 'mapel'
          ? ApiConstants.permitProcessMapel(id)
          : ApiConstants.permitProcessPiket(id);

      await dioClient.dio.patch(endpoint, data: {"status": status});
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal memproses izin");
    }
  }
}
