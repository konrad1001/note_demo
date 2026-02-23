import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:note_demo/db/util.dart';
import 'package:note_demo/providers/agent_providers/observer_agent_provider.dart';
import 'package:note_demo/providers/agent_providers/principle_agent_provider.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final box = Hive.box<NMetaData>(kHashedFilesBoxName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            Column(
              children: [
                Text("Hive DB. Size: ${box.length}"),
                ...box.keys.map((obj) => Text(obj.toString())),
              ],
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
            _DebugResponseInfo(),
          ],
        ),
      ),
    );
  }
}

class _DebugResponseInfo extends ConsumerWidget {
  const _DebugResponseInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightProvider);
    final principle = ref.watch(principleAgentProvider);

    return SizedBox(
      height: 320,
      child: ListView(
        children: [
          Text("Insights:"),
          Row(
            spacing: 8.0,
            children: [...insights.map((item) => Text(item.name))],
          ),
          Text("History:"),
          ...principle.callHistory.map((item) => Text(item)),
          Divider(),
          Text("User fingerprint:"),
          Text(
            principle.fingerprint ?? "Empty",
            style: GoogleFonts.googleSansCode(
              color: Colors.deepOrangeAccent,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
