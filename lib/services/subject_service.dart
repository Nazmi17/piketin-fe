import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/subject_model.dart';

class SubjectService {
  final DioClient dioClient;

  SubjectService(this.dioClient);

  // GET LIST (Support Pagination & Search)
  Future<List<Subject>> getSubjects({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.subjects,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final apiResponse = ApiResponse<List<Subject>>.fromJson(response.data, (
        json,
      ) {
        if (json == null) return [];
        return (json as List)
            .map((e) => Subject.fromJson(e as Map<String, dynamic>))
            .toList();
      });

      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Gagal mengambil data mata pelajaran",
      );
    }
  }

  // CREATE
  Future<void> createSubject(String name) async {
    try {
      await dioClient.dio.post(ApiConstants.subjects, data: {"name": name});
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Gagal membuat mata pelajaran",
      );
    }
  }

  // UPDATE
  Future<void> updateSubject(int id, String name) async {
    try {
      await dioClient.dio.put(
        ApiConstants.subjectDetail(id),
        data: {"name": name},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Gagal update mata pelajaran",
      );
    }
  }

  // DELETE
  Future<void> deleteSubject(int id) async {
    try {
      await dioClient.dio.delete(ApiConstants.subjectDetail(id));
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Gagal menghapus mata pelajaran",
      );
    }
  }
}
