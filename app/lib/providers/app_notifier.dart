import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:note_demo/db/note_content_hasher.dart';
import 'package:note_demo/db/util.dart';
import 'package:note_demo/providers/app_event_provider.dart';
import 'package:note_demo/providers/file_service_provider.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';

class AppNotifier extends Notifier<AppState> {
  var titleController = TextEditingController();

  @override
  AppState build() {
    return AppState(currentFileMetaData: NMetaData());
  }

  void loadFromFile() async {
    final File? file = await ref.watch(fileServiceProvider).pickFile();
    final noteContentNotifer = ref.read(noteContentProvider.notifier);
    final insightsNotifier = ref.read(insightProvider.notifier);

    if (file != null) {
      file
          .readAsString()
          .then((result) {
            final hash = NoteContentHasher.hash(result);
            final box = Hive.box<NMetaData>(kHashedFilesBoxName);

            final metadata = box.get(hash);
            state = state.copyWith(
              autoFileName: metadata?.autoTitle,
              userSetFileName: metadata?.userTitle,
            );

            if (metadata != null) {
              print("Load file: found existing record of ${file.absolute}");

              state = state.copyWith(currentFileMetaData: metadata);
              insightsNotifier.set(metadata.insights);

              // Assign loaded text to edit controller.
              noteContentNotifer.setText(result, previousText: result);
              titleController = TextEditingController(
                text:
                    state.userSetFileName ??
                    state.autoFileName ??
                    _getFileNameFromPath(file.path),
              );
            } else {
              print("Load file: no existing record of ${file.absolute} found");

              state = state.copyWith(currentFileMetaData: NMetaData());
              insightsNotifier.set([]);

              // Assign loaded text to edit controller.
              noteContentNotifer.setText(result, previousText: "");

              titleController = TextEditingController(
                text: _getFileNameFromPath(file.path),
              );

              // Run principle on new content
              ref.read(principleAgentProvider.notifier).runPrinciple(hash);
            }
          })
          .onError((e, st) {
            print("$e, $st");
          });
    }
  }

  void saveFile() async {
    final noteContent = ref.read(noteContentProvider);
    final insights = ref.read(insightProvider);

    if (state.currentFileMetaData.insights.isNotEmpty) {
      final hash = NoteContentHasher.hash(noteContent.text);
      final box = Hive.box<NMetaData>(kHashedFilesBoxName);
      final metadata = state.currentFileMetaData.copyWith(insights: insights);

      box.put(hash, metadata).then((onValue) {
        print("successfully saved $hash");
      }, onError: (e) => print("error saving $hash: $e"));
    }

    ref
        .watch(fileServiceProvider)
        .saveFile(
          noteContent.text,
          state.userSetFileName ?? state.autoFileName ?? "Untitled",
        );
  }

  void newFile() async {
    print("New file");
    state = state.copyWith(currentFileMetaData: NMetaData());
    ref.read(noteContentProvider.notifier).setText("");
    ref.read(noteContentProvider.notifier).setPreviousContent("");

    ref.read(insightProvider.notifier).set([]);

    titleController = TextEditingController();
  }

  void setUserTitle(String newTitle) {
    state = state.copyWith(userSetFileName: newTitle);
    state = state.copyWith(
      currentFileMetaData: state.currentFileMetaData.copyWith(
        userTitle: newTitle,
      ),
    );
  }

  void setAutoTitle(String newTitle) {
    if (state.userSetFileName == null) {
      titleController = TextEditingController(text: newTitle);
      state = state.copyWith(
        currentFileMetaData: state.currentFileMetaData.copyWith(
          autoTitle: newTitle,
        ),
      );
    }
    state = state.copyWith(autoFileName: newTitle);
  }

  String _getFileNameFromPath(String path) {
    if (Platform.isWindows) {
      return path.split("\\").last.split(".").first;
    } else {
      return path.split("/").last.split(".").first;
    }
  }
}

final appNotifierProvider = NotifierProvider<AppNotifier, AppState>(
  AppNotifier.new,
);
