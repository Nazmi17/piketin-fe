import 'package:json_annotation/json_annotation.dart';

part 'student_permit_model.g.dart';

@JsonSerializable()
class StudentPermit {
  final int id;

  final PermitStudentDetail student;

  // Objek Mapel User & Piket User
  final PermitUserDetail mapel;
  final PermitUserDetail piket;

  final String
  status; // PENDING_MAPEL, PENDING_PIKET, APPROVED, REJECTED, CANCELED
  final String reason;

  @JsonKey(name: 'hours_start')
  final int hoursStart;

  @JsonKey(name: 'hours_end')
  final int? hoursEnd; // Bisa null (optional di backend)

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  StudentPermit({
    required this.id,
    required this.student,
    required this.mapel,
    required this.piket,
    required this.status,
    required this.reason,
    required this.hoursStart,
    this.hoursEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentPermit.fromJson(Map<String, dynamic> json) =>
      _$StudentPermitFromJson(json);
  Map<String, dynamic> toJson() => _$StudentPermitToJson(this);
}

// --- Nested Model untuk Detail Siswa ---
@JsonSerializable()
class PermitStudentDetail {
  final String nis;
  final String name;

  @JsonKey(name: 'class') // Backend mengirim key "class" (bukan className)
  final String? className;

  PermitStudentDetail({required this.nis, required this.name, this.className});

  factory PermitStudentDetail.fromJson(Map<String, dynamic> json) =>
      _$PermitStudentDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PermitStudentDetailToJson(this);
}

// --- Nested Model untuk Detail User (Guru) ---
@JsonSerializable()
class PermitUserDetail {
  final int id;
  final String username;
  final String fullname;

  PermitUserDetail({
    required this.id,
    required this.username,
    required this.fullname,
  });

  factory PermitUserDetail.fromJson(Map<String, dynamic> json) =>
      _$PermitUserDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PermitUserDetailToJson(this);
}
