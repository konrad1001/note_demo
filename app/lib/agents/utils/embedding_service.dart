import 'dart:convert';
import 'package:http/http.dart' as http;

const kGeminiEmbeddingModel = 'models/gemini-embedding-001';

const kEmbeddingUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent';

typedef Embedding = List<double>;

class EmbeddingService {
  Future<Embedding?> embed(String text, {bool verbose = false}) async {
    if (text.isEmpty) return null;

    final response = await http.post(
      Uri.parse(kEmbeddingUrl),
      headers: _headers,
      body: _body(text),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Embedding failed (${response.statusCode}): ${response.body}',
      );
    }

    if (verbose) {
      print(response.body);
    }

    final data = jsonDecode(response.body);

    return _parseEmbedding(data);
  }

  Map<String, String> get _headers {
    const apiKey = String.fromEnvironment('GEMINI_KEY');

    return {'Content-Type': 'application/json', 'x-goog-api-key': apiKey};
  }

  String _body(String text) {
    return jsonEncode({
      'model': kGeminiEmbeddingModel,
      'content': {
        'parts': [
          {'text': text},
        ],
      },
      // "output_dimensionality": 768
    });
  }

  List<double> _parseEmbedding(Map<String, dynamic> json) {
    final embedding = json['embedding'];

    if (embedding == null || embedding['values'] == null) {
      throw Exception('Invalid embedding response format');
    }

    return List<double>.from(embedding['values']);
  }
}
