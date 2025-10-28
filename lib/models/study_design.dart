import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_design.freezed.dart';
part 'study_design.g.dart';

@freezed
abstract class StudyDesign with _$StudyDesign {
  const factory StudyDesign({
    required String title,
    required String summary,
    @JsonKey(name: "study_plan") required List<String> studyPlan,
  }) = _StudyDesign;

  factory StudyDesign.fromJson(Map<String, Object?> json) =>
      _$StudyDesignFromJson(json);

  static StudyDesign error(Object e) =>
      StudyDesign(title: e.toString(), summary: e.toString(), studyPlan: []);
}
