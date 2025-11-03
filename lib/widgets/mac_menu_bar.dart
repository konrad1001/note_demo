import 'package:flutter/widgets.dart';

typedef MenuBarFunctions = ({Function() openFile, Function() saveFile});

class MacMenuBar extends StatelessWidget {
  const MacMenuBar({super.key, this.child, required this.functions});

  final MenuBarFunctions functions;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: <PlatformMenuItem>[
        PlatformMenu(
          label: "APP",
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: [PlatformMenuItem(label: "About", onSelected: () {})],
            ),
            if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.quit,
            ))
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit,
              ),
          ],
        ),
        PlatformMenu(
          label: "File",
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: "Open...",
                  onSelected: functions.openFile,
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(label: "Save", onSelected: functions.saveFile),
              ],
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}
