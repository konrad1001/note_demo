import 'package:freezed_annotation/freezed_annotation.dart';
import 'agent_response.dart';

part 'study_tools.freezed.dart';
part 'study_tools.g.dart';

@freezed
abstract class StudyTools extends AgentResponse with _$StudyTools {
  StudyTools._();

  const factory StudyTools.flashcards({
    required String id,
    required String title,
    required List<FlashcardItem> items,
  }) = FlashcardGroup;

  const factory StudyTools.qas({
    required String id,
    required String title,
    required List<QuestionAnswerItem> items,
  }) = QAGroup;

  const factory StudyTools.keywords({
    required String id,
    required String title,
    required List<KeywordItem> items,
  }) = KeywordGroup;

  factory StudyTools.fromJson(Map<String, dynamic> json) =>
      _$StudyToolsFromJson(json);
}

@freezed
abstract class FlashcardItem with _$FlashcardItem {
  const factory FlashcardItem({required String front, required String back}) =
      _FlashcardItem;

  factory FlashcardItem.fromJson(Map<String, dynamic> json) =>
      _$FlashcardItemFromJson(json);
}

@freezed
abstract class QuestionAnswerItem with _$QuestionAnswerItem {
  const factory QuestionAnswerItem({
    required String question,
    required String answer,
  }) = _QuestionAnswerItem;

  factory QuestionAnswerItem.fromJson(Map<String, dynamic> json) =>
      _$QuestionAnswerItemFromJson(json);
}

@freezed
abstract class KeywordItem with _$KeywordItem {
  const factory KeywordItem({
    required String keyword,
    required String definition,
  }) = _KeywordItem;

  factory KeywordItem.fromJson(Map<String, dynamic> json) =>
      _$KeywordItemFromJson(json);
}
