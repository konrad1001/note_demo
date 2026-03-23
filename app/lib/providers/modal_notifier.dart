import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModalNotifier extends Notifier<Widget?> {
  @override
  Widget? build() {
    return null;
  }

  set(Widget? widget) {
    state = widget;
  }
}

final modalProvider = NotifierProvider<ModalNotifier, Widget?>(
  () => ModalNotifier(),
);
