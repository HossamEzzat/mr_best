// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentModel _$StudentModelFromJson(Map<String, dynamic> json) =>
    _StudentModel(
      id: (json['id'] as num?)?.toInt(),
      groupId: (json['group_id'] as num).toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String?,
      parentName: json['parent_name'] as String?,
      parentPhone: json['parent_phone'] as String?,
      school: json['school'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$StudentModelToJson(_StudentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'name': instance.name,
      'phone': instance.phone,
      'parent_name': instance.parentName,
      'parent_phone': instance.parentPhone,
      'school': instance.school,
      'notes': instance.notes,
      'created_at': instance.createdAt,
    };
