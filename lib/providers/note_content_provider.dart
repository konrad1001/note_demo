import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:note_demo/providers/file_service_provider.dart';

class NoteContentNotifier extends StateNotifier<TextEditingController> {
  final Ref ref;

  NoteContentNotifier(this.ref) : super(TextEditingController()) {
    print("init");
  }

  void loadFromFile() async {
    final file = await ref.watch(fileServiceProvider).pickFile();

    if (file != null) {
      file.readAsString().then((result) {
        state = TextEditingController(text: result);
      });
    }
  }

  void updateText(String newText) {
    state = TextEditingController(text: newText);
  }
}

final noteContentProvider =
    StateNotifierProvider<NoteContentNotifier, TextEditingController>(
      (ref) => NoteContentNotifier(ref),
    );
