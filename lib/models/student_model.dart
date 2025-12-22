import 'package:json_annotation/json_annotation.dart';

part 'student_model.g.dart';

@JsonSerializable()
class Student {
  final int? id; // <--- UBAH JADI NULLABLE (tambah tanda tanya)
  final String nis;
  final int? classId;
  final String name;

  @JsonKey(name: 'class')
  final String? className;

  Student({
    this.id, // <--- Hapus 'required'
    required this.nis,
    required this.name,
    this.classId,
    this.className,
  });

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
//