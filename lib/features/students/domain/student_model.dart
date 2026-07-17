import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_model.freezed.dart';
part 'student_model.g.dart';

@freezed
abstract class StudentModel with _$StudentModel {
  const factory StudentModel({
    int? id,
    @JsonKey(name: 'group_id') required int groupId,
    required String name,
    String? phone,
    @JsonKey(name: 'parent_name') String? parentName,
    @JsonKey(name: 'parent_phone') String? parentPhone,
    String? school,
    String? notes,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _StudentModel;

  factory StudentModel.fromJson(Map<String, dynamic> json) => _$StudentModelFromJson(json);
}
