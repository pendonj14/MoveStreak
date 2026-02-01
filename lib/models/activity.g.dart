// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      date: _dateTimeFromJson(json['date']),
      createdAt: _dateTimeFromJson(json['createdAt']),
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'notes': instance.notes,
      'durationMinutes': instance.durationMinutes,
      'date': _dateTimeToJson(instance.date),
      'createdAt': _dateTimeToJson(instance.createdAt),
    };
