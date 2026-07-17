import 'package:freezed_annotation/freezed_annotation.dart';

part 'grade_model.freezed.dart';
part 'grade_model.g.dart';

@freezed
abstract class GradeModel with _$GradeModel {
  const factory GradeModel({
    int? id,
    @JsonKey(name: 'student_id') required int studentId,
    @JsonKey(name: 'task_id') required int taskId,
    required double score,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _GradeModel;

  factory GradeModel.fromJson(Map<String, dynamic> json) => _$GradeModelFromJson(json);
}
