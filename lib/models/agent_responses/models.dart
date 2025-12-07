import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/models/models.dart';

part 'models.freezed.dart';
part 'models.g.dart';

abstract class AgentResponse {
  const AgentResponse();

  Insight toInsight();
}

@freezed
abstract class PrincipleResponse extends AgentResponse
    with _$PrincipleResponse {
  const PrincipleResponse._();
  const factory PrincipleResponse({
    String? content,
    @Default([]) List<GeminiFunctionResponse> calls,
  }) = _PrincipleResponse;

  @override
  Insight toInsight() => Insight.meta();
}

@freezed
abstract class ExternalResearchResponse extends AgentResponse
    with _$ExternalResearchResponse {
  const ExternalResearchResponse._();
  const factory ExternalResearchResponse({required String content}) =
      _ExternalResearchResponse;

  @override
  Insight toInsight() => Insight.research(research: content);
}

@freezed
abstract class BaseResponse extends AgentResponse with _$BaseResponse {
  const BaseResponse._();
  const factory BaseResponse({required String content}) = _BaseResponse;

  @override
  Insight toInsight() => Insight.meta();
}

@freezed
abstract class StudyDesign extends AgentResponse with _$StudyDesign {
  const StudyDesign._();

  const factory StudyDesign({required String title, required String summary}) =
      _StudyDesign;

  factory StudyDesign.fromJson(Map<String, Object?> json) =>
      _$StudyDesignFromJson(json);

  static StudyDesign error(Object e) =>
      StudyDesign(title: e.toString(), summary: e.toString());

  static StudyDesign empty() => StudyDesign(title: '', summary: '');

  @override
  Insight toInsight() => Insight.summary(title: title, body: summary);
}

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.snake)
abstract class StudyTools extends AgentResponse with _$StudyTools {
  const StudyTools._();

  @FreezedUnionValue('flashcards')
  const factory StudyTools.flashcards({
    required String id,
    required String title,
    required List<FlashcardItem> items,
  }) = FlashcardGroup;

  @FreezedUnionValue('qas')
  const factory StudyTools.qas({
    required String id,
    required String title,
    required List<QuestionAnswerItem> items,
  }) = QAGroup;

  @FreezedUnionValue('keywords')
  const factory StudyTools.keywords({
    required String id,
    required String title,
    required List<KeywordItem> items,
  }) = KeywordGroup;

  factory StudyTools.fromJson(Map<String, dynamic> json) =>
      _$StudyToolsFromJson(json);

  @override
  Insight toInsight() => Insight.resource(resource: this);
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

extension StudyToolsX on StudyTools {
  Color get colour => map(
    flashcards: (_) => const Color.fromARGB(255, 255, 156, 123),
    qas: (_) => const Color.fromARGB(255, 77, 210, 150),
    keywords: (_) => const Color.fromARGB(255, 123, 198, 255),
  );
}
