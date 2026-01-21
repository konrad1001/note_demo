part of 'menu_bar.dart';

class MacMenuBar extends StatelessWidget {
  const MacMenuBar({super.key, required this.child, required this.functions});

  final MenuBarFunctions functions;
  final Widget child;

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
        PlatformMenu(
          label: "Debug",
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: "Open Debug View",
                  onSelected: functions.openDebugView,
                ),
              ],
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}
