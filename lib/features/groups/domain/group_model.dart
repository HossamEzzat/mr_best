import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
abstract class GroupModel with _$GroupModel {
  const factory GroupModel({
    int? id,
    required String name,
    @JsonKey(name: 'grade_level') required String gradeLevel,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) => _$GroupModelFromJson(json);
}
