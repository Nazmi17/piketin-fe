import 'package:json_annotation/json_annotation.dart';

part 'piket_schedule_model.g.dart';

@JsonSerializable()
class PiketSchedule {
  final int id;

  // Backend mengembalikan object teacher sederhana (id, username, fullname)
  final PiketTeacherDetail teacher;

  @JsonKey(name: 'day_of_week')
  final int dayOfWeek; // 0 (Minggu) - 6 (Sabtu)

  @JsonKey(name: 'day_name')
  final String dayName; // "Senin", "Selasa", dst (dari backend)

  PiketSchedule({
    required this.id,
    required this.teacher,
    required this.dayOfWeek,
    required this.dayName,
  });

  factory PiketSchedule.fromJson(Map<String, dynamic> json) =>
      _$PiketScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$PiketScheduleToJson(this);
}

@JsonSerializable()
class PiketTeacherDetail {
  final int id;
  final String username;
  final String fullname;

  PiketTeacherDetail({
    required this.id,
    required this.username,
    required this.fullname,
  });

  factory PiketTeacherDetail.fromJson(Map<String, dynamic> json) =>
      _$PiketTeacherDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PiketTeacherDetailToJson(this);
}
