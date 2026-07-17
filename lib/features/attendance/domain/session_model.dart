import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
abstract class SessionModel with _$SessionModel {
  const factory SessionModel({
    int? id,
    @JsonKey(name: 'group_id') required int groupId,
    @JsonKey(name: 'session_date') required String sessionDate,
    String? title,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);
}
