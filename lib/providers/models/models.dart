import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
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
abstract class NMetaData with _$NMetaData {
  const factory NMetaData({
    StudyDesign? design,
    @Default([]) List<StudyTools> tools,
    @Default("") String agentNotes,
    String? externalResearch,
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
  const factory PrincipleAgentState.initial({
    @Default("") String agentNotes,
    UserDiff? diff,
    @Default(false) bool isLoading,
  }) = PrincipleAgentStateInitial;

  const factory PrincipleAgentState.idle({
    required bool valid,
    @Default([]) List<GeminiFunctionResponse> calls,
    @Default("") String agentNotes,
    UserDiff? diff,
    @Default(false) bool isLoading,
  }) = PrincipleAgentStateIdle;
}

extension PrincipleAgentStateX on PrincipleAgentState {
  GeminiFunctionResponse? callsMe(String name) => map(
    initial: (_) => null,
    idle: (idle) {
      for (var call in idle.calls) {
        if (call.name == name) return call;
      }
      return null;
    },
  );
}

@freezed
abstract class ExternalResearchState with _$ExternalResearchState {
  const factory ExternalResearchState({
    String? content,
    @Default(0) int pipeLevel,
    @Default(false) bool isLoading,
  }) = _ExternalResearchState;
}

@freezed
abstract class StudyContentState with _$StudyContentState {
  const factory StudyContentState.empty() = StudyContentStateEmpty;
  const factory StudyContentState.loading() = StudyContentStateLoading;
  const factory StudyContentState.idle({
    required StudyDesign design,
    @Default(false) bool isLoading,
  }) = StudyContentStateIdle;
  const factory StudyContentState.error({required Object error}) =
      StudyContentStateError;
}

@freezed
abstract class StudyToolsState with _$StudyToolsState {
  const factory StudyToolsState({
    @Default([]) List<StudyTools> tools,
    @Default(false) bool isLoading,
  }) = _StudyToolsState;
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

extension AppStateX on AppState {
  bool get hasMetaData => currentFileMetaData.design != null;

  String get toolsOverview => currentFileMetaData.tools.fold(
    "",
    (overview, resource) =>
        "$overview,${resource.map(flashcards: (_) => "Flashcards:", qas: (_) => "QAs:", keywords: (_) => "Keywords:")}${resource.title}",
  );
}
