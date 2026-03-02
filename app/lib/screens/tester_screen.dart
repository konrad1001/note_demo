import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/providers/app_notifier.dart';

class TesterScreen extends ConsumerWidget {
  const TesterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Test panel"),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(hintText: "Enter api key..."),
                    onChanged: (value) {
                      ref.read(appNotifierProvider.notifier).setApiKey(value);
                    },
                  ),
                ),
                SizedBox(width: 20),
                Flexible(
                  child: Opacity(
                    opacity:
                        (ref.read(appNotifierProvider).apiKey == null ||
                            ref.read(appNotifierProvider).apiKey == "")
                        ? 0.1
                        : 1.0,
                    child: Icon(Icons.check_circle_outline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
