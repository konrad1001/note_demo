import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/models/models.dart';

class ChatTurn {
  final ChatRole role;
  final String? text;
  final GeminiFunctionResponse? functionCall;

  ChatTurn(this.role, this.text, this.functionCall);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> content = {'role': role.geminiName};
    if (text != null) {
      content['parts'] = [
        {'text': text},
      ];
    } else if (functionCall != null) {
      content['parts'] = [
        {
          'functionCall': {
            'name': functionCall?.name,
            'args': functionCall?.args,
          },
        },
      ];
    }

    return content;
  }
}
