import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
abstract class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    int? id,
    @JsonKey(name: 'student_id') required int studentId,
    @JsonKey(name: 'session_id') required int sessionId,
    required String status, // 'حاضر', 'غائب', 'متأخر'
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);
}
