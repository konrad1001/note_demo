import 'dart:io';

import 'package:flutter/material.dart';

part 'mac_menu_bar.dart';
part 'windows_menu_bar.dart';

typedef MenuBarFunctions = ({
  Function() newFile,
  Function() openFile,
  Function() saveFile,
  Function() openDebugView,
});

class OSMenuBar extends StatelessWidget {
  final MenuBarFunctions functions;
  final Widget child;

  const OSMenuBar({super.key, required this.functions, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return MacMenuBar(functions: functions, child: child);
    } else {
      return WindowsMenuBar(functions: functions, child: child);
    }
  }
}
