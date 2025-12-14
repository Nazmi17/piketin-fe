import 'package:json_annotation/json_annotation.dart';

part 'teacher_assignment_model.g.dart';

@JsonSerializable()
class TeacherAssignment {
  final int id;

  // Nested Objects
  final AssignmentTeacherDetail teacher;
  @JsonKey(name: 'class')
  final AssignmentClassDetail classInfo;
  final AssignmentSubjectDetail subject;

  @JsonKey(name: 'assignment_details')
  final String assignmentDetails;

  final String reason;

  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  TeacherAssignment({
    required this.id,
    required this.teacher,
    required this.classInfo,
    required this.subject,
    required this.assignmentDetails,
    required this.reason,
    this.dueDate,
    required this.createdAt,
  });

  factory TeacherAssignment.fromJson(Map<String, dynamic> json) =>
      _$TeacherAssignmentFromJson(json);
}

// --- Helper Models ---
@JsonSerializable()
class AssignmentTeacherDetail {
  final int id;
  final String username;
  final String fullname;
  AssignmentTeacherDetail({
    required this.id,
    required this.username,
    required this.fullname,
  });
  factory AssignmentTeacherDetail.fromJson(Map<String, dynamic> json) =>
      _$AssignmentTeacherDetailFromJson(json);
}

@JsonSerializable()
class AssignmentClassDetail {
  final int id;
  @JsonKey(name: 'class')
  final String className;
  AssignmentClassDetail({required this.id, required this.className});
  factory AssignmentClassDetail.fromJson(Map<String, dynamic> json) =>
      _$AssignmentClassDetailFromJson(json);
}

@JsonSerializable()
class AssignmentSubjectDetail {
  final int id;
  final String name;
  AssignmentSubjectDetail({required this.id, required this.name});
  factory AssignmentSubjectDetail.fromJson(Map<String, dynamic> json) =>
      _$AssignmentSubjectDetailFromJson(json);
}
