import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    int? id,
    @JsonKey(name: 'group_id') required int groupId,
    required String title,
    required String category, // 'الامتحان الشهري', 'التقييم الأسبوعي', 'اختبار الدرس', 'الواجب', 'امتحان نصف الترم', 'درجة المدرسة'
    @JsonKey(name: 'total_score') required double totalScore,
    @JsonKey(name: 'task_date') required String taskDate,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
}
