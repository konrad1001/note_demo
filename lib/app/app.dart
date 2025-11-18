import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';
import 'package:note_demo/providers/study_content_provider.dart';
import 'package:note_demo/screens/debug_screen.dart';
import 'package:note_demo/screens/notes_screen.dart';
import 'package:note_demo/screens/study_screen.dart';
import 'package:note_demo/widgets/menu_bar/menu_bar.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return OSMenuBar(
          functions: (
            newFile: ref.watch(appNotifierProvider.notifier).newFile,
            openFile: ref.watch(noteContentProvider.notifier).loadFromFile,
            saveFile: ref.watch(noteContentProvider.notifier).saveFile,
            openDebugView: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => DebugScreen()));
            },
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              toolbarHeight: 16,
              bottom: TabBar(
                controller: _tabController,
                onTap: (index) {
                  if (index == 1) {
                    ref.watch(principleAgentProvider.notifier).runPrinciple();
                  }
                },
                tabs: const <Widget>[
                  Tab(text: "Write"),
                  Tab(text: "Revise"),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                NotesScreen(controller: _notesController),
                StudyScreen(),
              ],
            ),
          ),
        );
      },
    );
  }
}
