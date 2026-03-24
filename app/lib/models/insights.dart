import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/agents/utils/embedding_service.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';

part 'insights.freezed.dart';
part 'insights.g.dart';

@freezed
abstract class Insight with _$Insight {
  const factory Insight.summary({
    required String title,
    required String body,
    required DateTime created,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
  }) = _SummaryInsight;

  const factory Insight.resource({
    required StudyTools resource,
    required DateTime created,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
  }) = _ResourceInsight;

  const factory Insight.research({
    required String research,
    required DateTime created,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
  }) = _ResearchInsight;

  const factory Insight.mindmap({
    required String title,
    required DateTime created,
    required MindMap mindmap,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
  }) = _MindmapInsight;

  const factory Insight.chat({
    required ChatRole role,
    required String body,
    required DateTime created,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool isStreaming,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
  }) = _ChatInsight;

  const factory Insight.focusEvent({
    required DateTime startTime,
    required Duration duration,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
  }) = _FocusEventInsight;

  const factory Insight.functionCall({
    required GeminiFunctionResponse function,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
  }) = _FunctionCallInsight;

  const factory Insight.error({
    required String message,
    required int code,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
    required DateTime created,
  }) = _ErrorInsight;

  const factory Insight.setDate({
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
    required DateTime created,
  }) = _SetDateInsight;

  const factory Insight.overview({
    String? title,
    DateTime? keyDate,
    @Default([]) Insights recommendedInsights,
    @Default([]) Insights recommendedActions,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
    required DateTime created,
  }) = _OverviewInsight;

  // Use for agent responses that shouldn't be displayed to the user, like steps in agent pipeline
  const factory Insight.meta({
    String? notes,
    DateTime? created,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(ChatRole.agent) ChatRole role,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
  }) = _MetaInsight;

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
}

extension InsightX on Insight {
  String get name => map(
    summary: (_) => "Summary",
    resource: (_) => "Resource",
    research: (_) => "Research",
    mindmap: (_) => "Mindmap",
    chat: (_) => "Chat",
    focusEvent: (_) => "Focus Event",
    meta: (_) => "Meta step",
    functionCall: (_) => "Function call",
    error: (_) => "Error",
    setDate: (_) => "Set Date",
    overview: (_) => "Overview",
  );
}

extension InsightsX on Insights {
  Insights whereMaterial() => where(
    (insight) => (insight.maybeMap(
      resource: (_) => true,
      mindmap: (_) => true,
      research: (_) => true,
      orElse: () => false,
    )),
  ).toList();

  String print() => map((i) => i.name).join(", ");
}
