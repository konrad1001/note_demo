import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class NoteContentNotifier extends StateNotifier<String> {
  NoteContentNotifier() : super("") {
    print("init");
  }

  void updateText(String newText) {
    state = newText;
  }
}

final noteContentProvider = StateNotifierProvider<NoteContentNotifier, String>(
  (ref) => NoteContentNotifier(),
);

// final noteContentLoader = FutureProvider<String>((ref) async {

// })

class NoteState {
  final String content;
  final int tabIndex;

  NoteState(this.tabIndex, {required this.content});

  NoteState copyWith({String? content, int? tabIndex}) {
    return NoteState(
      tabIndex ?? this.tabIndex,
      content: content ?? this.content,
    );
  }
}
