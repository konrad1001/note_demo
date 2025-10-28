import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/note_taker/study_plan.json');
  }

  /// Reads and parses the JSON file
  Future<Map<String, dynamic>> readJson() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } else {
        return {
          "title": "Untitled",
          "content": "",
          "lastModified": DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      return {"error": "Error reading file: $e"};
    }
  }

  /// Writes data to JSON file
  Future<void> writeJson(Map<String, dynamic> data) async {
    try {
      final file = await _getFile();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await file.writeAsString(jsonString, flush: true);
    } catch (e) {
      throw Exception('Error writing file: $e');
    }
  }
}
