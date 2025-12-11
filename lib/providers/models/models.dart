import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
    @Default("") String currentFileName,
    @Default("") String enhancedNotes,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}

@freezed
abstract class Insight with _$Insight {
  const factory Insight.summary({
    required String title,
    required String body,
    DateTime? created,
  }) = _SummaryInsight;

  const factory Insight.resource({
    required StudyTools resource,
    DateTime? created,
  }) = _ResourceInsight;

  const factory Insight.research({
    required String research,
    DateTime? created,
  }) = _ResearchInsight;

  // Use for agent responses that shouldn't be displayed to the user, like steps in agent pipeline
  const factory Insight.meta({String? notes, DateTime? created}) = _MetaInsight;

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
}

@freezed
abstract class NMetaData with _$NMetaData {
  const factory NMetaData({
    StudyDesign? design,
    @Default([]) List<StudyTools> tools,
    @Default("") String agentNotes,
    String? externalResearch,
    @Default([]) Insights insights,
    @Default([]) List<String> appHistory,
  }) = _NMetaData;

  factory NMetaData.fromJson(Map<String, dynamic> json) =>
      _$NMetaDataFromJson(json);
}

@freezed
abstract class NoteContentState with _$NoteContentState {
  const factory NoteContentState({
    required TextEditingController editingController,
    required String previousContent,
    NError? error,
  }) = _NoteContentState;
}

@freezed
abstract class PrincipleAgentState with _$PrincipleAgentState {
  const factory PrincipleAgentState({
    required bool valid,
    @Default([]) List<GeminiFunctionResponse> calls,
    @Default("") String agentNotes,
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
abstract class ResearchAgentState with _$ResearchAgentState {
  const factory ResearchAgentState({
    String? content,
    @Default(0) int pipeLevel,
    @Default(false) bool isLoading,
  }) = _ResearchAgentState;
}

@freezed
abstract class SummaryAgentState with _$SummaryAgentState {
  const factory SummaryAgentState.empty() = SummaryAgentStateEmpty;
  const factory SummaryAgentState.loading() = SummaryAgentStateLoading;
  const factory SummaryAgentState.idle({
    required StudyDesign design,
    @Default(false) bool isLoading,
  }) = SummaryAgentStateIdle;
  const factory SummaryAgentState.error({required Object error}) =
      SummaryAgentStateError;
}

@freezed
abstract class ResourceAgentState with _$ResourceAgentState {
  const factory ResourceAgentState({
    @Default([]) List<StudyTools> tools,
    @Default(false) bool isLoading,
  }) = _ResourceAgentState;
}

@freezed
abstract class ObserverAgentState with _$ObserverAgentState {
  const factory ObserverAgentState({
    @Default([]) List<String> history,
    @Default(false) bool isLoading,
  }) = _ObserverAgentState;
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
    meta: (_) => "Meta step",
  );
}

extension NoteContentStateX on NoteContentState {
  String get text => editingController.text;
}

extension AppStateX on AppState {
  bool get hasMetaData => currentFileMetaData.design != null;

  String get toolsOverview => currentFileMetaData.tools.fold(
    "",
    (overview, resource) =>
        "$overview,${resource.map(flashcards: (_) => "Flashcards:", qas: (_) => "QAs:", keywords: (_) => "Keywords:")}${resource.title}",
  );
}
