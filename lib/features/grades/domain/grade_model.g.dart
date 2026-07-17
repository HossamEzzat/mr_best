// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GradeModel _$GradeModelFromJson(Map<String, dynamic> json) => _GradeModel(
  id: (json['id'] as num?)?.toInt(),
  studentId: (json['student_id'] as num).toInt(),
  taskId: (json['task_id'] as num).toInt(),
  score: (json['score'] as num).toDouble(),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$GradeModelToJson(_GradeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'task_id': instance.taskId,
      'score': instance.score,
      'created_at': instance.createdAt,
    };
