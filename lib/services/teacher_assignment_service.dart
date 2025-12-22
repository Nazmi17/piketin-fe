import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/teacher_assignment_model.dart';

class TeacherAssignmentService {
  final DioClient dioClient;

  TeacherAssignmentService(this.dioClient);

  // GET ALL with Pagination & Filters
  Future<List<TeacherAssignment>> getAssignments({
    int page = 1,
    String? search,
    int? classId,
    int? subjectId,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.teacherAssignments,
        queryParameters: {
          'page': page,
          if (search != null && search.isNotEmpty) 'search': search,
          if (classId != null) 'class_id': classId,
          if (subjectId != null) 'subject_id': subjectId,
        },
      );

      final List<dynamic> rawList = response.data['data'];
      return rawList.map((e) => TeacherAssignment.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal memuat tugas guru");
    }
  }

  // CREATE
  Future<bool> createAssignment({
    required int teacherUserId,
    required int classId,
    required int subjectId,
    required String details,
    required String reason,
    DateTime? dueDate,
  }) async {
    try {
      await dioClient.dio.post(
        ApiConstants.teacherAssignments,
        data: {
          "teacher_user_id": teacherUserId,
          "class_id": classId,
          "subject_id": subjectId,
          "assignment_details": details,
          "reason": reason,
          if (dueDate != null) "due_date": dueDate.toIso8601String(),
        },
      );
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal membuat tugas");
    }
  }

  Future<bool> updateAssignment({
    required int id,
    required int teacherUserId,
    required int classId,
    required int subjectId,
    required String details,
    required String reason,
    DateTime? dueDate,
  }) async {
    try {
      await dioClient.dio.put(
        '${ApiConstants.teacherAssignments}/$id',
        data: {
          "teacher_user_id": teacherUserId,
          "class_id": classId,
          "subject_id": subjectId,
          "assignment_details": details,
          "reason": reason,
          if (dueDate != null) "due_date": dueDate.toIso8601String(),
        },
      );
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal memperbarui tugas");
    }
  }

  // UPDATE & DELETE similar pattern...
  Future<bool> deleteAssignment(int id) async {
    try {
      await dioClient.dio.delete(ApiConstants.teacherAssignmentDetail(id));
      return true;
    } catch (e) {
      return false;
    }
  }
}
