import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/class_model.dart';

class ClassService {
  final DioClient dioClient;

  ClassService(this.dioClient);

  Future<List<ClassModel>> getClasses() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.classes);

      // Parsing menggunakan ApiResponse helper yang sudah ada
      final apiResponse = ApiResponse<List<ClassModel>>.fromJson(
        response.data,
        (json) {
          if (json == null) return [];
          return (json as List)
              .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Gagal mengambil data kelas",
      );
    }
  }
}
