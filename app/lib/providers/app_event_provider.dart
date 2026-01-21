import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/models/models.dart';

final appEventControllerProvider = Provider<StreamController<AppEvent>>((ref) {
  final controller = StreamController<AppEvent>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

final appEventStreamProvider = StreamProvider<AppEvent>((ref) {
  return ref.watch(appEventControllerProvider).stream;
});
