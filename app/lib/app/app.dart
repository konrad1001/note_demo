import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/app/app_bar.dart';
import 'package:note_demo/app/theme.dart';
import 'package:note_demo/providers/agent_providers/mindmap_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/observer_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/research_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/resource_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/summary_agent_provider.dart';
import 'package:note_demo/providers/focus_event_provider.dart';
import 'package:note_demo/providers/theme_mode_provider.dart';
import 'package:note_demo/screens/debug_screen.dart';
import 'package:note_demo/screens/notes_screen.dart';
import 'package:note_demo/widgets/insights/insight_panel.dart';
import 'package:note_demo/widgets/menu_bar/menu_bar.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _notesController = TextEditingController();

  var isRightPanelOpen = !(Platform.isAndroid || Platform.isIOS);

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
        final _ = ref.watch(observerAgentProvider);
        final _ = ref.watch(researchAgentProvider);
        final _ = ref.watch(resourceAgentProvider);
        final _ = ref.watch(mindmapAgentProvider);
        final _ = ref.watch(focusEventProvider);
        final theme = ref.watch(themeModeProvider);
        final themeNotifier = ref.watch(themeModeProvider.notifier);

        final isMobile = (Platform.isAndroid || Platform.isIOS);

        final screenWidth = MediaQuery.of(context).size.width;
        double noteScreenWidthCondensed = isMobile
            ? 0
            : screenWidth * (1.9 / 3);
        double insightPanelWidthExpanded = isMobile
            ? screenWidth
            : screenWidth * (1.1 / 3);

        int insightPanelAnimationDuration = isMobile ? 500 : 300;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Note GPT",
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: theme,
          home: Scaffold(
            onDrawerChanged: (_) {
              FocusScope.of(context).unfocus();
            },
            drawer: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: SidePanelWidget(
                currentTheme: theme,
                functions: (
                  newFile: ref.watch(appNotifierProvider.notifier).newFile,
                  openFile: ref
                      .watch(appNotifierProvider.notifier)
                      .loadFromFile,
                  saveFile: ref.watch(appNotifierProvider.notifier).saveFile,
                  toggleTheme: (mode) {
                    themeNotifier.toggle();
                  },
                  openDebugView: () {},
                ),
              ),
            ),

            appBar: NoteAppBar(
              isRightPanelOpen: isRightPanelOpen,
              onTap: () {
                setState(() {
                  isRightPanelOpen = !isRightPanelOpen;
                });
              },
            ),
            body: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 0,
                  child: AnimatedContainer(
                    duration: Duration(
                      milliseconds: insightPanelAnimationDuration,
                    ),
                    width: isRightPanelOpen
                        ? noteScreenWidthCondensed
                        : screenWidth,
                    curve: Curves.easeInOut,
                    child: OverflowBox(
                      minWidth: 0,
                      maxWidth: screenWidth,
                      child: NotesScreen(controller: _notesController),
                    ),
                  ),
                ),
                Flexible(
                  flex: 0,
                  child: ClipRect(
                    child: AnimatedContainer(
                      duration: Duration(
                        milliseconds: insightPanelAnimationDuration,
                      ),
                      curve: Curves.easeInOut,
                      width: isRightPanelOpen ? insightPanelWidthExpanded : 0,
                      child: AnimatedOpacity(
                        opacity: isRightPanelOpen ? 1 : 1,
                        duration: Duration(milliseconds: 100),
                        child: OverflowBox(
                          minWidth: 0,
                          maxWidth: insightPanelWidthExpanded,
                          child: InsightPanel(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SidePanelWidget extends StatelessWidget {
  const SidePanelWidget({
    super.key,
    required this.functions,
    required this.currentTheme,
  });

  final MenuBarFunctions functions;
  final ThemeMode currentTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => DebugScreen()));
              },
              context,
              dontAutoPop: true,
            ),
            _themeToggle(context, functions.toggleTheme),
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

  Widget _themeToggle(
    BuildContext context,
    Function(ThemeMode) onValueChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text("Theme", style: TextStyle(fontWeight: FontWeight.w600)),
          Spacer(),
          CupertinoSegmentedControl<ThemeMode>(
            groupValue: currentTheme,
            onValueChanged: (ThemeMode mode) {
              onValueChanged(mode);
            },
            children: const {
              ThemeMode.light: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Light'),
              ),
              ThemeMode.dark: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Dark'),
              ),
            },
          ),
        ],
      ),
    );
  }
}
