import 'package:flutter/material.dart';
import 'package:note_demo/widgets/demo_widget.dart';
import 'package:note_demo/widgets/text_editor.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: DemoWidget()));
  }
}
