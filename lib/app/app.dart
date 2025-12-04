import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/providers/note_content_provider.dart';
import 'package:note_demo/providers/principle_agent_provider.dart';
import 'package:note_demo/providers/study_content_provider.dart';
import 'package:note_demo/screens/debug_screen.dart';
import 'package:note_demo/screens/notes_screen.dart';
import 'package:note_demo/screens/study_screen.dart';
import 'package:note_demo/widgets/agent_status_bar.dart';
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
        final studyContent = ref.watch(studyContentProvider);

        return Scaffold(
          backgroundColor: Colors.white,
          drawer: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: SidePanelWidget(
              functions: (
                newFile: ref.watch(appNotifierProvider.notifier).newFile,
                openFile: ref.watch(noteContentProvider.notifier).loadFromFile,
                saveFile: ref.watch(noteContentProvider.notifier).saveFile,
                openDebugView: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DebugScreen()),
                  );
                },
              ),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 64,
            flexibleSpace: PreferredSize(
              preferredSize: Size(0, 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const SizedBox(width: 48),
                      SizedBox(
                        width: 100,
                        child: TabBar(
                          controller: _tabController,
                          dividerHeight: 0,
                          onTap: (index) {
                            if (index == 1) {
                              ref
                                  .watch(principleAgentProvider.notifier)
                                  .runPrinciple();
                            }
                          },
                          indicatorWeight: 1,
                          tabs: const <Widget>[
                            Tab(icon: Icon(Icons.edit, size: 16)),
                            Tab(icon: Icon(Icons.auto_awesome, size: 16)),
                          ],
                        ),
                      ),
                      studyContent.maybeWhen(
                        idle: (design, isLoading) => Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Opacity(
                              opacity: isLoading ? 0.5 : 1.0,
                              child: Text(
                                design.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0),
                      Colors.black.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: AgentStatusBar(),
                  ),
                ),
              ),
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
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    String name,
    VoidCallback onPressed,
    BuildContext context,
  ) {
    return MenuItemButton(
      onPressed: () {
        onPressed();
        Navigator.of(context).pop();
      },
      child: Text(name),
    );
  }
}
