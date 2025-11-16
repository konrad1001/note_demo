import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:note_demo/app/app.dart';
import 'package:note_demo/db/models/app_state_adapter.dart';
import 'package:note_demo/db/util.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Init hive DB
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  final _ = Hive.openBox<AppState>(kHashedFilesBoxName);

  Hive.registerAdapter(AppStateAdapter());

  // Init window
  WindowOptions windowOptions = WindowOptions(
    title: "Note GPT",
    size: Size(1000, 600),
    minimumSize: Size(400, 300),
    center: true,
    skipTaskbar: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: "Note GPT", home: App());
  }
}
