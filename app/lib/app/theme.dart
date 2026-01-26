import 'package:flutter/material.dart';

const Color _appBlack = Color.fromARGB(255, 32, 32, 32);

abstract class NTheme {
  static Color primary = Colors.blueAccent;
  static Color greyed = Colors.black54;
  static Color panelBackground = const Color.fromARGB(255, 197, 197, 197);
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  unselectedWidgetColor: Colors.black54,
  canvasColor: Color.fromARGB(255, 245, 244, 240),
  cardColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    foregroundColor: Colors.black,
  ),
  colorScheme: ColorScheme.light(primary: Colors.blueAccent),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blueGrey,
  scaffoldBackgroundColor: _appBlack,
  unselectedWidgetColor: Colors.white.withValues(alpha: 0.5),
  canvasColor: const Color.fromARGB(255, 52, 52, 52),
  cardColor: _appBlack,
  appBarTheme: AppBarTheme(
    backgroundColor: _appBlack,
    surfaceTintColor: _appBlack,
    foregroundColor: Colors.white,
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.blueGrey,
    secondary: Colors.tealAccent,
  ),
);
