import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/student_model.dart';

class StudentService {
  final DioClient dioClient;

  StudentService(this.dioClient);

 Future<List<Student>> getStudents() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.students,
        // [FIX] Tambahkan queryParameters limit 1000 (atau sesuai kebutuhan)
        queryParameters: {'limit': 1000},
      );

      final apiResponse = ApiResponse<List<Student>>.fromJson(response.data, (
        json,
      ) {
        if (json == null) return [];
        return (json as List)
            .map((e) => Student.fromJson(e as Map<String, dynamic>))
            .toList();
      });

      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Gagal mengambil data siswa",
      );
    }
  }
}
