import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../models/role_model.dart';

class UserService {
  final DioClient _dioClient;

  UserService(this._dioClient);

  // --- USER DATA ---

  Future<List<User>> getUsers({int page = 1, int limit = 10}) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.users,
        queryParameters: {'page': page, 'limit': limit},
      );

      final apiResponse = ApiResponse<List<User>>.fromJson(response.data, (
        json,
      ) {
        if (json == null) return [];
        return (json as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal mengambil data user',
      );
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      await _dioClient.dio.post(ApiConstants.users, data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal membuat user');
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      await _dioClient.dio.put(ApiConstants.userDetail(id), data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal update user');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dioClient.dio.delete(ApiConstants.userDetail(id));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus user');
    }
  }

 // GET LIST GURU MAPEL
  Future<List<User>> getMapelUsers() async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.usersMapel,
        // [FIX] Tambahkan queryParameters limit 1000
        queryParameters: {'limit': 1000},
      );

      final apiResponse = ApiResponse<List<User>>.fromJson(response.data, (
        json,
      ) {
        if (json == null) return [];
        return (json as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
      });

      return apiResponse.data ?? [];
    } catch (e) {
      return [];
    }
  }

  // --- ROLE MANAGEMENT ---

  // Ambil semua role yang tersedia (Master Data)
  Future<List<Role>> getMasterRoles() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.roles);
      final list = response.data['data'] as List;
      return list.map((e) => Role.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Ambil role yang dimiliki user saat ini (Return List<Role> agar kita tahu ID-nya)
  Future<List<Role>> getUserRoles(int userId) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.userRoles(userId));
      final list = response.data['data'] as List;

      // Backend response structure check:
      // Bisa jadi { id: 1, role_id: 2, role: { id: 2, name: "ADMIN" } }
      // Kita ambil object 'role' nya.
      return list.map((e) {
        if (e['role'] != null) {
          return Role.fromJson(e['role']);
        }
        return Role.fromJson(e); // Fallback
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Tambah Role ke User
  Future<void> addUserRole(int userId, int roleId) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.userRoles(userId),
        data: {"role_id": roleId},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menambahkan role');
    }
  }

  // Hapus Role dari User
  Future<void> removeUserRole(int userId, int roleId) async {
    try {
      await _dioClient.dio.delete(ApiConstants.deleteUserRole(userId, roleId));
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus role');
    }
  }
}
