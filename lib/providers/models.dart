import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/util/diff.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    StudyDesign? design,
    @Default([]) List<StudyTools> tools,
    @Default("") String agentNotes,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}

@freezed
abstract class NoteContentState with _$NoteContentState {
  const factory NoteContentState({
    required TextEditingController editingController,
    required String previousContent,
  }) = _NoteContentState;
}

@freezed
abstract class PrincipleAgentState with _$PrincipleAgentState {
  const factory PrincipleAgentState.initial({
    @Default("") String agentNotes,
    UserDiff? diff,
  }) = PrincipleAgentStateInitial;
  const factory PrincipleAgentState.idle({
    required bool valid,
    required List<String> tool,
    @Default("") String agentNotes,
    UserDiff? diff,
  }) = PrincipleAgentStateIdle;
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

extension NoteContentStateX on NoteContentState {
  String get text => editingController.text;
}

extension AppStateX on AppState {
  String get toolsOverview => tools.fold(
    "",
    (overview, resource) =>
        "$overview,${resource.map(flashcards: (_) => "Flashcards:", qas: (_) => "QAs:", keywords: (_) => "Keywords:")}${resource.title}",
  );
}
