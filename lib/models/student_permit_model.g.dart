// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_permit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentPermit _$StudentPermitFromJson(Map<String, dynamic> json) =>
    StudentPermit(
      id: (json['id'] as num).toInt(),
      student: PermitStudentDetail.fromJson(
        json['student'] as Map<String, dynamic>,
      ),
      mapel: PermitUserDetail.fromJson(json['mapel'] as Map<String, dynamic>),
      piket: PermitUserDetail.fromJson(json['piket'] as Map<String, dynamic>),
      status: json['status'] as String,
      reason: json['reason'] as String,
      hoursStart: (json['hours_start'] as num).toInt(),
      hoursEnd: (json['hours_end'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$StudentPermitToJson(StudentPermit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student': instance.student,
      'mapel': instance.mapel,
      'piket': instance.piket,
      'status': instance.status,
      'reason': instance.reason,
      'hours_start': instance.hoursStart,
      'hours_end': instance.hoursEnd,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

PermitStudentDetail _$PermitStudentDetailFromJson(Map<String, dynamic> json) =>
    PermitStudentDetail(
      nis: json['nis'] as String,
      name: json['name'] as String,
      className: json['class'] as String?,
    );

Map<String, dynamic> _$PermitStudentDetailToJson(
  PermitStudentDetail instance,
) => <String, dynamic>{
  'nis': instance.nis,
  'name': instance.name,
  'class': instance.className,
};

PermitUserDetail _$PermitUserDetailFromJson(Map<String, dynamic> json) =>
    PermitUserDetail(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      fullname: json['fullname'] as String,
    );

Map<String, dynamic> _$PermitUserDetailToJson(PermitUserDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'fullname': instance.fullname,
    };
