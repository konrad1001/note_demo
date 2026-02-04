import 'package:note_demo/providers/models/models.dart';

class ChatTurn {
  final ChatRole role;
  final String text;

  ChatTurn(this.role, this.text);

  Map<String, dynamic> toJson() {
    return {
      'role': role.geminiName,
      'parts': [
        {'text': text},
      ],
    };
  }
}
