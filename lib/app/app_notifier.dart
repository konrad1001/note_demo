import 'package:flutter_riverpod/legacy.dart';

class NoteContentNotifier extends StateNotifier<String> {
  NoteContentNotifier() : super("");

  void updateText(String newText) {
    state = newText;
  }
}

final appNotifierProvider = StateNotifierProvider<NoteContentNotifier, String>(
  (ref) => NoteContentNotifier(),
);

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
