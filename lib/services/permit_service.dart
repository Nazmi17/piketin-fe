import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/student_permit_model.dart';

class PermitService {
  final DioClient dioClient;

  PermitService(this.dioClient);

  // 1. GET ALL PERMITS (dengan Pagination & Filter)
  // Endpoint: /student-permits
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
          // Backend Express membaca array query seperti status[]=PENDING&status[]=APPROVED
          if (status != null && status.isNotEmpty) 'status[]': status,
        },
      );

      // Backend response: { success: true, message: "...", data: [...list...], meta: {...} }
      // Kita ambil bagian 'data' yang berisi List
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

  // 2. CREATE PERMIT
  // Endpoint: /student-permits
  Future<StudentPermit> createPermit({
    required String studentNis,
    required String reason,
    required int hoursStart,
    required int mapelUserId,
    int? hoursEnd,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.permits,
        data: {
          "student_nis": studentNis,
          "reason": reason,
          "hours_start": hoursStart,
          "hours_end": hoursEnd,
          "mapel_user_id": mapelUserId,
        },
      );

      // Mengembalikan data permit yang baru dibuat
      final apiResponse = ApiResponse<StudentPermit>.fromJson(
        response.data,
        (json) => StudentPermit.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse.data!;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal membuat izin");
    }
  }

  // 3. GET PENDING MAPEL (Khusus Guru Mapel)
  // Endpoint: /student-permits/mapel/pending
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

  // 4. GET PENDING PIKET (Khusus Guru Piket)
  // Endpoint: /student-permits/piket/ready-to-approve
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

  // 5. PROCESS PERMIT (Approve/Reject)
  // Endpoint: /student-permits/:id/process/:type
  // Type: 'mapel' atau 'piket'
  Future<bool> processPermit({
    required int id,
    required String actionType, // 'mapel' atau 'piket'
    required String status, // e.g. 'APPROVED', 'REJECTED', 'PENDING_PIKET'
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
