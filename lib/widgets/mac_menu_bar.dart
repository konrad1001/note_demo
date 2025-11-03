import 'package:flutter/widgets.dart';

class MacMenuBar extends StatelessWidget {
  const MacMenuBar({super.key, this.child});

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
              members: [PlatformMenuItem(label: "Open...", onSelected: () {})],
            ),
            PlatformMenuItemGroup(
              members: [PlatformMenuItem(label: "Save", onSelected: () {})],
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}
