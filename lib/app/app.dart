import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/app/app_notifier.dart';
import 'package:note_demo/screens/notes_screen.dart';
import 'package:note_demo/screens/study_screen.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: const Text("Notes demo"),
            bottom: TabBar(
              controller: _tabController,
              onTap: (index) {
                ref
                    .read(appNotifierProvider.notifier)
                    .updateText(_notesController.text);
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
        );
      },
    );
  }
}
