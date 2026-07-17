// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => _TaskModel(
  id: (json['id'] as num?)?.toInt(),
  groupId: (json['group_id'] as num).toInt(),
  title: json['title'] as String,
  category: json['category'] as String,
  totalScore: (json['total_score'] as num).toDouble(),
  taskDate: json['task_date'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$TaskModelToJson(_TaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'title': instance.title,
      'category': instance.category,
      'total_score': instance.totalScore,
      'task_date': instance.taskDate,
      'created_at': instance.createdAt,
    };
