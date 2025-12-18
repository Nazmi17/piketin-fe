import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String fullname;
  final String? nip;

  // [FIX] Tambahkan defaultValue agar tidak crash jika backend mengirim null
  @JsonKey(defaultValue: [])
  final List<String> roles;

  User({
    required this.id,
    required this.username,
    required this.fullname,
    this.nip,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
