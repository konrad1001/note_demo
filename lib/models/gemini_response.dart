import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

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
  String get firstCandidateText =>
      candidates.first.content.parts.first.text ??
      ""; // TODO: This will break things!

  Map<String, dynamic> get firstCandidateJSON {
    final cleaned = firstCandidateText
        .replaceAll(RegExp(r'```json|```'), '')
        .trim();

    // print(
    //   "first candidate json: ${json.decode(cleaned) as Map<String, dynamic>}",
    // );

    return json.decode(cleaned) as Map<String, dynamic>;
  }

  // TODO: should test this really
  List<GeminiFunctionResponse> get functionCalls {
    final allCalls = candidates.first.content.parts
        .map((part) => part.functionCall)
        .nonNulls;

    return allCalls
        .map(
          (call) => GeminiFunctionResponse(
            name: call.name,
            args: call.args.values.map((arg) => arg.toString()).toList(),
          ),
        )
        .toList();
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
  const factory Part({String? text, FunctionCall? functionCall}) = _Part;

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

@freezed
abstract class FunctionCall with _$FunctionCall {
  const factory FunctionCall({
    required String name,
    required Map<String, dynamic> args,
  }) = _FunctionCall;

  factory FunctionCall.fromJson(Map<String, dynamic> json) =>
      _$FunctionCallFromJson(json);
}

@freezed
abstract class GeminiFunctionResponse with _$GeminiFunctionResponse {
  const factory GeminiFunctionResponse({
    required String name,
    @Default([]) List<String> args,
  }) = _GeminiFunctionResponse;
}
