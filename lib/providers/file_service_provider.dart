import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/util/file_service.dart';

final fileServiceProvider = Provider<FileService>((ref) => FileService());

class JsonFileNotifier extends AsyncNotifier<Map<String, dynamic>> {
  late final FileService _fileService;

  @override
  Future<Map<String, dynamic>> build() async {
    _fileService = ref.watch(fileServiceProvider);
    return _fileService.readJson();
  }

  Future<void> saveGeminiResponse(GeminiResponse response) async {
    final data = response.firstCandidateText;
    // Exctract json from the response text, may be within markdown code block
    final Map<String, dynamic> jsonData;
    try {
      final cleaned = data.replaceAll(RegExp(r'```json|```'), '').trim();
      jsonData = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse Gemini response: $e');
    }
    save(jsonData);
  }

  Future<void> save(Map<String, dynamic> data) async {
    await _fileService.writeJson(data);
    state = AsyncData(data);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    try {
      final data = await _fileService.readJson();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final jsonFileProvider =
    AsyncNotifierProvider<JsonFileNotifier, Map<String, dynamic>>(
      JsonFileNotifier.new,
    );
