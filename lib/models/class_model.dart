import 'package:json_annotation/json_annotation.dart';

part 'class_model.g.dart';

@JsonSerializable()
class ClassModel {
  final int id;

  // Sesuaikan 'name' ini dengan key JSON dari backend kamu
  // (biasanya 'name', 'class_name', atau 'name_class')
  // Berdasarkan pola backend kamu sebelumnya, mungkin backend mengirim key 'name' atau 'class'.
  @JsonKey(name: 'class')
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClassModelToJson(this);
}
