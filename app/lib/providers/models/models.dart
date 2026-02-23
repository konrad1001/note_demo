import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:markdown_editor/markdown_editor.dart';
import 'package:note_demo/agents/utils/embedding_service.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/util/diff.dart';
import 'package:note_demo/util/error/errors.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    required NMetaData currentFileMetaData,
    String? autoFileName,
    String? userSetFileName,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}

@freezed
abstract class NMetaData with _$NMetaData {
  const factory NMetaData({
    String? userTitle,
    String? autoTitle,
    @Default([]) Insights insights,
    @Default([]) List<String> appHistory,
  }) = _NMetaData;

  factory NMetaData.fromJson(Map<String, dynamic> json) =>
      _$NMetaDataFromJson(json);
}

enum UserRating {
  like,
  dislike,
  neither;

  int get toValue => switch (this) {
    UserRating.like => 1,
    UserRating.dislike => -1,
    UserRating.neither => 0,
  };
}

enum ChatRole {
  user,
  agent;

  String get geminiName => switch (this) {
    ChatRole.agent => "model",
    _ => "user",
  };
}

// INSIGHTS

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

  // Use for agent responses that shouldn't be displayed to the user, like steps in agent pipeline
  const factory Insight.meta({
    String? notes,
    DateTime? created,
    required Embedding? queryEmbedding,
    @Default(UserRating.neither) UserRating rating,
    @Default(false) bool markForDeletion,
    @Default(false) bool stagedForDeletion,
  }) = _MetaInsight;

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
}

@freezed
abstract class NoteContentState with _$NoteContentState {
  const factory NoteContentState({
    required MarkdownTextEditingController editingController,
    required String previousContent,
    NError? error,
  }) = _NoteContentState;
}

// AGENT STATES

abstract class AgentState {
  const AgentState();

  bool get isLoading;
}

@freezed
abstract class PrincipleAgentState extends AgentState
    with _$PrincipleAgentState {
  const PrincipleAgentState._();

  const factory PrincipleAgentState({
    @Default([]) List<GeminiFunctionResponse> calls,
    @Default([]) List<String> callHistory,
    UserDiff? diff,
    @Default(false) bool isLoading,
  }) = _PrincipleAgentState;
}

extension PrincipleAgentStateX on PrincipleAgentState {
  GeminiFunctionResponse? callsMe(String name) {
    for (var call in calls) {
      if (call.name == name) return call;
    }
    return null;
  }
}

@freezed
abstract class ResearchAgentState extends AgentState with _$ResearchAgentState {
  const ResearchAgentState._();

  const factory ResearchAgentState({
    String? content,
    @Default(0) int pipeLevel,
    @Default(false) bool isLoading,
  }) = _ResearchAgentState;
}

@freezed
abstract class SummaryAgentState extends AgentState with _$SummaryAgentState {
  const SummaryAgentState._();

  const factory SummaryAgentState({@Default(false) bool isLoading}) =
      _SummaryAgentState;
}

@freezed
abstract class ResourceAgentState extends AgentState with _$ResourceAgentState {
  const ResourceAgentState._();

  const factory ResourceAgentState({@Default(false) bool isLoading}) =
      _ResourceAgentState;
}

@freezed
abstract class MindmapAgentState extends AgentState with _$MindmapAgentState {
  const MindmapAgentState._();

  const factory MindmapAgentState({@Default(false) bool isLoading}) =
      _MindmapAgentState;
}

@freezed
abstract class ConversationAgentState extends AgentState
    with _$ConversationAgentState {
  const ConversationAgentState._();

  const factory ConversationAgentState({
    @Default([]) List<GeminiFunctionResponse> calls,
    @Default(false) bool isLoading,
  }) = _ConversationAgentState;
}

extension ConversationAgentStateX on ConversationAgentState {
  GeminiFunctionResponse? callsMe(String name) {
    for (var call in calls) {
      if (call.name == name) return call;
    }
    return null;
  }
}

@freezed
abstract class ObserverAgentState with _$ObserverAgentState {
  const factory ObserverAgentState({
    @Default([]) List<String> history,
    @Default(false) bool isLoading,
  }) = _ObserverAgentState;
}

@freezed
abstract class FocusEvent with _$FocusEvent {
  const factory FocusEvent({
    required DateTime startTime,
    required Duration duration,
  }) = _FocusEvent;
}

@freezed
abstract class AppEvent with _$AppEvent {
  const factory AppEvent.loadedFromFile({required AppState state}) =
      _AppEventLoadedFromFile;
  const factory AppEvent.newFile() = _AppEventNewFile;
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
  );
}

extension NoteContentStateX on NoteContentState {
  String get text => editingController.text;
}

extension FocusEventX on FocusEvent {
  DateTime get endTime => startTime.add(duration);
}
