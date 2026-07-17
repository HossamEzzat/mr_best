// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => _GroupModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  gradeLevel: json['grade_level'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$GroupModelToJson(_GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'grade_level': instance.gradeLevel,
      'created_at': instance.createdAt,
    };
