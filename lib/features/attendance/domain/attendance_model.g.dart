// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    _AttendanceModel(
      id: (json['id'] as num?)?.toInt(),
      studentId: (json['student_id'] as num).toInt(),
      sessionId: (json['session_id'] as num).toInt(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$AttendanceModelToJson(_AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'session_id': instance.sessionId,
      'status': instance.status,
      'created_at': instance.createdAt,
    };
