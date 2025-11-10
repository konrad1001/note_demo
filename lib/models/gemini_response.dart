import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note_demo/models/study_design.dart';
import 'package:note_demo/models/study_tools.dart';

part 'gemini_response.freezed.dart';
part 'gemini_response.g.dart';

@freezed
abstract class GeminiResponse with _$GeminiResponse {
  const factory GeminiResponse({
    required List<Candidate> candidates,
    required UsageMetadata usageMetadata,
    required String modelVersion,
    required String responseId,
  }) = _GeminiResponse;

  factory GeminiResponse.fromJson(Map<String, dynamic> json) =>
      _$GeminiResponseFromJson(json);
}

extension GeminiResponseX on GeminiResponse {
  String get firstCandidateText => candidates.first.content.parts.first.text;

  Map<String, dynamic> get firstCandidateJSON {
    final cleaned = firstCandidateText
        .replaceAll(RegExp(r'```json|```'), '')
        .trim();
    return json.decode(cleaned) as Map<String, dynamic>;
  }

  StudyDesign getStudyDesign() {
    try {
      final cleaned = firstCandidateText
          .replaceAll(RegExp(r'```json|```'), '')
          .trim();
      final jsonMap = json.decode(cleaned) as Map<String, dynamic>;
      return StudyDesign.fromJson(jsonMap);
    } catch (e) {
      return StudyDesign.error(e);
    }
  }
}

@freezed
abstract class Candidate with _$Candidate {
  const factory Candidate({
    required Content content,
    required String finishReason,
    required int index,
  }) = _Candidate;

  factory Candidate.fromJson(Map<String, dynamic> json) =>
      _$CandidateFromJson(json);
}

@freezed
abstract class Content with _$Content {
  const factory Content({required List<Part> parts, String? role}) = _Content;

  factory Content.fromJson(Map<String, dynamic> json) =>
      _$ContentFromJson(json);
}

@freezed
abstract class Part with _$Part {
  const factory Part({required String text}) = _Part;

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);
}

@freezed
abstract class UsageMetadata with _$UsageMetadata {
  const factory UsageMetadata({
    required int promptTokenCount,
    required int candidatesTokenCount,
    required int totalTokenCount,
  }) = _UsageMetadata;

  factory UsageMetadata.fromJson(Map<String, dynamic> json) =>
      _$UsageMetadataFromJson(json);
}
