import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/study_tools_provider.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    // etc.
  };
}

class StudyToolsContainer extends StatelessWidget {
  const StudyToolsContainer({super.key, required this.state});

  final StudyToolsState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 1000,
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: AlwaysScrollableScrollPhysics(),
          child: Opacity(
            opacity: state.isLoading ? 0.5 : 1.0,
            child: Row(
              spacing: 12,
              key: ValueKey(state.tools.length),
              children: state.tools
                  .map(
                    (tool) => tool.map(
                      flashcards: (flashcards) => _ToolContainer(
                        tool: tool,
                        title: "flashcards",
                        subTitle: flashcards.title,
                        colour: const Color.fromARGB(255, 255, 156, 123),
                      ),
                      qas: (qas) => _ToolContainer(
                        tool: tool,
                        title: "qas",
                        subTitle: qas.title,
                        colour: const Color.fromARGB(255, 77, 210, 150),
                      ),
                      keywords: (keywords) => _ToolContainer(
                        tool: tool,
                        title: "keywords",
                        subTitle: keywords.title,
                        colour: const Color.fromARGB(255, 123, 198, 255),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolContainer extends StatelessWidget {
  const _ToolContainer({
    required this.tool,
    required this.title,
    required this.subTitle,
    required this.colour,
  });

  final String title;
  final String subTitle;
  final Color colour;
  final StudyTools tool;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [Text(title), Text(subTitle)]),
      ),
    );
  }
}
