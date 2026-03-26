import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:markdown_editor/markdown_editor.dart';
import 'package:note_demo/agents/utils/embedding_service.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/models/insights.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/util/diff.dart';
import 'package:note_demo/util/error/errors.dart';

part 'models.freezed.dart';
part 'models.g.dart';

enum Build { mock, dev, test }

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    required NMetaData currentFileMetaData,
    required Build build,
    String? autoFileName,
    String? userSetFileName,
    String? apiKey,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}

@freezed
abstract class NMetaData with _$NMetaData {
  const factory NMetaData({
    String? userTitle,
    String? autoTitle,
    DateTime? keyDate,
    @Default([]) List<Insight> insights,
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
  function,
  agent;

  String get geminiName => switch (this) {
    ChatRole.agent => "model",
    _ => name,
  };
}

@freezed
abstract class NoteContentState with _$NoteContentState {
  const factory NoteContentState({
    required MarkdownTextEditingController editingController,
    required String previousContent,
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
    @Default(true) bool isOn,
    String? fingerprint,
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
    void Function(String?)? callback,
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

extension NoteContentStateX on NoteContentState {
  String get text => editingController.text;
}

extension FocusEventX on FocusEvent {
  DateTime get endTime => startTime.add(duration);
}
