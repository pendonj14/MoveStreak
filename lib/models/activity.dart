import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final String? id;
  final String userId;
  final String name;
  final String? notes;
  final int? durationMinutes;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime date;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  Activity({
    this.id,
    required this.userId,
    required this.name,
    this.notes,
    this.durationMinutes,
    required this.date,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  Activity copyWith({
    String? id,
    String? userId,
    String? name,
    String? notes,
    int? durationMinutes,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      date: date ?? this.date,
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
