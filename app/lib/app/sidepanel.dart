import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class SidePanelWidget extends StatelessWidget {
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
            _menuButton(
              "Open Test Panel",
              () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => TesterScreen()));
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
