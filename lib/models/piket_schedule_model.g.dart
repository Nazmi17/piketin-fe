// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piket_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PiketSchedule _$PiketScheduleFromJson(Map<String, dynamic> json) =>
    PiketSchedule(
      id: (json['id'] as num).toInt(),
      teacher: PiketTeacherDetail.fromJson(
        json['teacher'] as Map<String, dynamic>,
      ),
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      dayName: json['day_name'] as String,
    );

Map<String, dynamic> _$PiketScheduleToJson(PiketSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacher': instance.teacher,
      'day_of_week': instance.dayOfWeek,
      'day_name': instance.dayName,
    };

PiketTeacherDetail _$PiketTeacherDetailFromJson(Map<String, dynamic> json) =>
    PiketTeacherDetail(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      fullname: json['fullname'] as String,
    );

Map<String, dynamic> _$PiketTeacherDetailToJson(PiketTeacherDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'fullname': instance.fullname,
    };
