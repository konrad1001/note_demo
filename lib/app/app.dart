import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/app/app_bar.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/summary_agent_provider.dart';
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
        final studyContent = ref.watch(summaryAgentProvider);
        final principle = ref.watch(principleAgentProvider);

        return Scaffold(
          backgroundColor: Colors.white,
          drawer: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: SidePanelWidget(
              functions: (
                newFile: ref.watch(appNotifierProvider.notifier).newFile,
                openFile: ref.watch(appNotifierProvider.notifier).loadFromFile,
                saveFile: ref.watch(appNotifierProvider.notifier).saveFile,
                openDebugView: () {
                  print("pushing");

                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DebugScreen()),
                  );
                },
              ),
            ),
          ),
          appBar: NoteAppBar(
            tabController: _tabController,
            studyContent: studyContent,
            isLoading: principle.isLoading,
            onTap: (index) {
              if (index == 1) {
                ref.watch(principleAgentProvider.notifier).runPrinciple();
              }
            },
          ),
          body: Stack(
            alignment: AlignmentGeometry.bottomCenter,
            children: [
              TabBarView(
                controller: _tabController,
                children: <Widget>[
                  Align(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 700),
                      child: NotesScreen(controller: _notesController),
                    ),
                  ),

                  StudyScreen(),
                ],
              ),

              // Container(
              //   height: 120,
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //       colors: [
              //         Colors.black.withValues(alpha: 0),
              //         Colors.black.withValues(alpha: 0.2),
              //       ],
              //     ),
              //   ),
              //   child: Align(
              //     alignment: Alignment.bottomCenter,
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 32,
              //         vertical: 16,
              //       ),
              //       child: AgentStatusBar(),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}

class SidePanelWidget extends StatelessWidget {
  const SidePanelWidget({super.key, required this.functions});

  final MenuBarFunctions functions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 64,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            _menuButton("Open File", functions.openFile, context),
            _menuButton("Save", functions.saveFile, context),
            _menuButton("New", functions.newFile, context),
            _menuButton(
              "Open Debug",
              functions.openDebugView,
              context,
              dontAutoPop: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    String name,
    VoidCallback onPressed,
    BuildContext context, {
    bool dontAutoPop = false,
  }) {
    return MenuItemButton(
      onPressed: () {
        onPressed();
        if (!dontAutoPop) Navigator.of(context).pop();
      },
      child: Text(name),
    );
  }
}
