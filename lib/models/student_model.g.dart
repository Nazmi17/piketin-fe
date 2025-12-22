// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
  id: (json['id'] as num?)?.toInt(),
  nis: json['nis'] as String,
  name: json['name'] as String,
  classId: (json['class_id'] as num?)?.toInt(),
  className: json['class'] as String?,
);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
  'id': instance.id,
  'nis': instance.nis,
  'name': instance.name,
  'class_id': instance.classId,
  'class': instance.className,
};
