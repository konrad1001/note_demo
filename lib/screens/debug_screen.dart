import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:note_demo/db/util.dart';
import 'package:note_demo/providers/models/models.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<NMetaData>(kHashedFilesBoxName);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Text("Hive DB. Size: ${box.length}"),
                  ...box.keys.map((obj) => Text(obj.toString())),
                ],
              ),
            ),
            Row(
              spacing: 32,
              children: [
                Text("Clear Hive DB"),
                IconButton.outlined(
                  onPressed: () {
                    box.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.check),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
