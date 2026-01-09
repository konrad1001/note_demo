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
  Insight toInsight() => Insight.meta(created: DateTime.now());
}

@freezed
abstract class ExternalResearchResponse extends AgentResponse
    with _$ExternalResearchResponse {
  const ExternalResearchResponse._();
  const factory ExternalResearchResponse({required String content}) =
      _ExternalResearchResponse;

  @override
  Insight toInsight() =>
      Insight.research(research: content, created: DateTime.now());
}

@freezed
abstract class MindMapResponse extends AgentResponse with _$MindMapResponse {
  const MindMapResponse._();
  const factory MindMapResponse({
    required String id,
    required String title,
    required List<MindMapNode> nodes,
  }) = _MindMapResponse;

  factory MindMapResponse.fromJson(Map<String, dynamic> json) =>
      _$MindMapResponseFromJson(json);

  @override
  Insight toInsight() =>
      Insight.mindmap(title: title, created: DateTime.now(), mindmap: this);
}

@freezed
abstract class MindMapNode with _$MindMapNode {
  const factory MindMapNode({
    required String id,
    required String label,
    String? parentId,
  }) = _MindMapNode;

  factory MindMapNode.fromJson(Map<String, dynamic> json) =>
      _$MindMapNodeFromJson(json);
}

@freezed
abstract class TextResponse extends AgentResponse with _$TextResponse {
  const TextResponse._();
  const factory TextResponse({required String content}) = _TextResponse;

  @override
  Insight toInsight() => Insight.meta(created: DateTime.now());
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
  Insight toInsight() =>
      Insight.summary(title: title, body: summary, created: DateTime.now());
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
  Insight toInsight() =>
      Insight.resource(resource: this, created: DateTime.now());
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
    @JsonKey(name: "front") required String question,
    @JsonKey(name: "back") required String answer,
  }) = _QuestionAnswerItem;

  factory QuestionAnswerItem.fromJson(Map<String, dynamic> json) =>
      _$QuestionAnswerItemFromJson(json);
}

@freezed
abstract class KeywordItem with _$KeywordItem {
  const factory KeywordItem({
    @JsonKey(name: "front") required String keyword,
    @JsonKey(name: "back") required String definition,
  }) = _KeywordItem;

  factory KeywordItem.fromJson(Map<String, dynamic> json) =>
      _$KeywordItemFromJson(json);
}

@freezed
abstract class PipelineResult<T> with _$PipelineResult<T> {
  const factory PipelineResult.step({T? object, @Default(0) int index}) =
      PipelineStepResult;

  const factory PipelineResult.finished({
    required T object,
    @Default(0) int index,
  }) = PipelineFinishedResult;

  const factory PipelineResult.error({Object? error, @Default(0) int index}) =
      PipelineErrorResult;
}

extension StudyToolsX on StudyTools {
  Color get colour => map(
    flashcards: (_) => const Color.fromARGB(255, 255, 156, 123),
    qas: (_) => const Color.fromARGB(255, 77, 210, 150),
    keywords: (_) => const Color.fromARGB(255, 123, 198, 255),
  );
}

extension MindMapX on MindMapResponse {
  MindMapNode? get rootNode => nodes.firstWhere(
    (node) => node.parentId == null,
    orElse: () => nodes.first,
  );

  List<MindMapNode> getChildren(String parentId) {
    return nodes.where((node) => node.parentId == parentId).toList();
  }
}
