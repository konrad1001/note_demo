import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/app/app_bar.dart';
import 'package:note_demo/providers/agent_providers/mindmap_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/observer_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/research_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/resource_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/summary_agent_provider.dart';
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

  var isRightPanelOpen = true;
  static const rightPanelAnimationDuration = 300;

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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DebugScreen()),
                  );
                },
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
              SizedBox(width: 1),
              Flexible(
                flex: 2,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: rightPanelAnimationDuration),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(right: isRightPanelOpen ? 0 : 0),
                  child: NotesScreen(controller: _notesController),
                ),
              ),
              Flexible(
                flex: isRightPanelOpen ? 1 : 0,
                child: ClipRect(
                  child: AnimatedContainer(
                    duration: Duration(
                      milliseconds: rightPanelAnimationDuration,
                    ),
                    curve: Curves.easeInOut,
                    width: isRightPanelOpen
                        ? MediaQuery.of(context).size.width / 3
                        : 0,
                    child: AnimatedOpacity(
                      opacity: isRightPanelOpen ? 1 : 0.6,
                      duration: Duration(milliseconds: 100),
                      child: OverflowBox(
                        minWidth: 0,
                        maxWidth: MediaQuery.of(context).size.width / 3,
                        child: InsightPanel(),
                      ),
                    ),
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
