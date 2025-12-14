// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_assignment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherAssignment _$TeacherAssignmentFromJson(Map<String, dynamic> json) =>
    TeacherAssignment(
      id: (json['id'] as num).toInt(),
      teacher: AssignmentTeacherDetail.fromJson(
        json['teacher'] as Map<String, dynamic>,
      ),
      classInfo: AssignmentClassDetail.fromJson(
        json['class'] as Map<String, dynamic>,
      ),
      subject: AssignmentSubjectDetail.fromJson(
        json['subject'] as Map<String, dynamic>,
      ),
      assignmentDetails: json['assignment_details'] as String,
      reason: json['reason'] as String,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TeacherAssignmentToJson(TeacherAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacher': instance.teacher,
      'class': instance.classInfo,
      'subject': instance.subject,
      'assignment_details': instance.assignmentDetails,
      'reason': instance.reason,
      'due_date': instance.dueDate?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

AssignmentTeacherDetail _$AssignmentTeacherDetailFromJson(
  Map<String, dynamic> json,
) => AssignmentTeacherDetail(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  fullname: json['fullname'] as String,
);

Map<String, dynamic> _$AssignmentTeacherDetailToJson(
  AssignmentTeacherDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'fullname': instance.fullname,
};

AssignmentClassDetail _$AssignmentClassDetailFromJson(
  Map<String, dynamic> json,
) => AssignmentClassDetail(
  id: (json['id'] as num).toInt(),
  className: json['class'] as String,
);

Map<String, dynamic> _$AssignmentClassDetailToJson(
  AssignmentClassDetail instance,
) => <String, dynamic>{'id': instance.id, 'class': instance.className};

AssignmentSubjectDetail _$AssignmentSubjectDetailFromJson(
  Map<String, dynamic> json,
) => AssignmentSubjectDetail(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
);

Map<String, dynamic> _$AssignmentSubjectDetailToJson(
  AssignmentSubjectDetail instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
