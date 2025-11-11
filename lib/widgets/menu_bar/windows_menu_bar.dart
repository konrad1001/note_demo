part of 'menu_bar.dart';

class WindowsMenuBar extends StatelessWidget {
  const WindowsMenuBar({
    super.key,
    required this.functions,
    required this.child,
  });

  final MenuBarFunctions functions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: MenuBar(
                style: MenuStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                  side: WidgetStatePropertyAll(
                    const BorderSide(color: Colors.grey),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
                children: [
                  SubmenuButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                    // ignore: sort_child_properties_last
                    child: Text("File", style: TextStyle(fontSize: 12.0)),
                    menuChildren: [
                      MenuItemButton(
                        onPressed: functions.openFile,
                        child: const Text(
                          "Open...",
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      MenuItemButton(
                        onPressed: functions.saveFile,
                        child: const Text(
                          "Save",
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(child: child),
      ],
    );
  }
}
