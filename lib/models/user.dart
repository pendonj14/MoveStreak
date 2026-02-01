import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? displayName;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

DateTime _dateTimeFromJson(dynamic json) {
  if (json is String) {
    return DateTime.parse(json);
  }
  return json as DateTime;
}

String _dateTimeToJson(DateTime dateTime) {
  return dateTime.toIso8601String();
}
