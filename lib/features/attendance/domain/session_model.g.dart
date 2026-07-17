// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionModel _$SessionModelFromJson(Map<String, dynamic> json) =>
    _SessionModel(
      id: (json['id'] as num?)?.toInt(),
      groupId: (json['group_id'] as num).toInt(),
      sessionDate: json['session_date'] as String,
      title: json['title'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$SessionModelToJson(_SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'session_date': instance.sessionDate,
      'title': instance.title,
      'created_at': instance.createdAt,
    };
