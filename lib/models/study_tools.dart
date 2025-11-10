import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_tools.freezed.dart';
part 'study_tools.g.dart';

/// Represents grouped collections of study tools.
/// Each factory holds a list of its own type.
@freezed
abstract class StudyTools with _$StudyTools {
  /// A group of flashcards.
  const factory StudyTools.flashcards({
    required String id,
    required String title,
    required List<FlashcardItem> items,
  }) = FlashcardGroup;

  /// A group of Q&A pairs.
  const factory StudyTools.qas({
    required String id,
    required String title,
    required List<QuestionAnswerItem> items,
  }) = QAGroup;

  /// A group of keywords.
  const factory StudyTools.keywords({
    required String id,
    required String title,
    required List<KeywordItem> items,
  }) = KeywordGroup;

  factory StudyTools.fromJson(Map<String, dynamic> json) =>
      _$StudyToolsFromJson(json);
}

/// A single flashcard.
@freezed
abstract class FlashcardItem with _$FlashcardItem {
  const factory FlashcardItem({required String front, required String back}) =
      _FlashcardItem;

  factory FlashcardItem.fromJson(Map<String, dynamic> json) =>
      _$FlashcardItemFromJson(json);
}

/// A single question/answer item.
@freezed
abstract class QuestionAnswerItem with _$QuestionAnswerItem {
  const factory QuestionAnswerItem({
    required String question,
    required String answer,
  }) = _QuestionAnswerItem;

  factory QuestionAnswerItem.fromJson(Map<String, dynamic> json) =>
      _$QuestionAnswerItemFromJson(json);
}

/// A single keyword/definition item.
@freezed
abstract class KeywordItem with _$KeywordItem {
  const factory KeywordItem({
    required String keyword,
    required String definition,
  }) = _KeywordItem;

  factory KeywordItem.fromJson(Map<String, dynamic> json) =>
      _$KeywordItemFromJson(json);
}
