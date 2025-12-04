import 'dart:convert';

import 'package:crypto/crypto.dart';

abstract class NoteContentHasher {
  static String hash(String content) {
    // final normalized = content.replaceAll('\r\n', '\n');
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }
}
