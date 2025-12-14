import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/piket_schedule_model.dart';

class PiketScheduleService {
  final DioClient dioClient;

  PiketScheduleService(this.dioClient);

  // GET ALL (Bisa filter by day)
  Future<List<PiketSchedule>> getSchedules({int? dayOfWeek}) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.piketSchedules,
        queryParameters: {if (dayOfWeek != null) 'day': dayOfWeek},
      );

      final List<dynamic> rawList = response.data['data'];
      return rawList.map((e) => PiketSchedule.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? "Gagal memuat jadwal piket",
      );
    }
  }

  // CREATE
  Future<bool> createSchedule({
    required int teacherId,
    required int dayOfWeek,
  }) async {
    try {
      await dioClient.dio.post(
        ApiConstants.piketSchedules,
        data: {"teacher_user_id": teacherId, "day_of_week": dayOfWeek},
      );
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal membuat jadwal");
    }
  }

  // UPDATE
  Future<bool> updateSchedule({
    required int id,
    required int teacherId,
    required int dayOfWeek,
  }) async {
    try {
      await dioClient.dio.put(
        ApiConstants.piketScheduleDetail(id),
        data: {"teacher_user_id": teacherId, "day_of_week": dayOfWeek},
      );
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Gagal update jadwal");
    }
  }

  // DELETE
  Future<bool> deleteSchedule(int id) async {
    try {
      await dioClient.dio.delete(ApiConstants.piketScheduleDetail(id));
      return true;
    } catch (e) {
      return false;
    }
  }
}
