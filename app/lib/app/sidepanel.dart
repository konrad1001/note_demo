import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:note_demo/screens/debug_screen.dart';
import 'package:note_demo/screens/tester_screen.dart';
import 'package:note_demo/widgets/menu_bar/menu_bar.dart';

typedef MenuBarFunctions = ({
  Function() newFile,
  Function() openFile,
  Function() saveFile,
  Function(ThemeMode) toggleTheme,
  Function() openDebugView,
  Function() openTestView,
});

class SidePanelWidget extends ConsumerWidget {
  const SidePanelWidget({
    super.key,
    required this.functions,
    required this.currentTheme,
    required this.buildType,
  });

  final MenuBarFunctions functions;
  final ThemeMode currentTheme;
  final Build buildType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrincipleOn = ref.watch(principleAgentProvider).isOn;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _menuButton("Open File", functions.openFile, context),
            _menuButton("Save", functions.saveFile, context),
            _menuButton("New", functions.newFile, context),
            if (buildType != Build.test)
              _menuButton(
                "Open Debug",
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DebugScreen()),
                  );
                },
                context,
                dontAutoPop: true,
              ),
            _themeToggle(context, functions.toggleTheme),
            _principleToggle(
              context,
              value: isPrincipleOn,
              onValueChanged: (newValue) {
                ref.read(principleAgentProvider.notifier).setIsOn(newValue);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              child: Opacity(opacity: 0.5, child: Divider()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  "TEST COMMANDS",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _menuButton("Generate daily overview", () {
              ref.read(appNotifierProvider.notifier).createOverview();
            }, context),
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
            selectedColor: null,
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

  Widget _principleToggle(
    BuildContext context, {
    required bool value,
    required Function(bool) onValueChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            "Autorun insights",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Spacer(),
          CupertinoSegmentedControl<bool>(
            groupValue: value,
            onValueChanged: (bool newValue) {
              onValueChanged(newValue);
            },
            children: const {
              true: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('On'),
              ),
              false: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Off'),
              ),
            },
          ),
        ],
      ),
    );
  }
}
