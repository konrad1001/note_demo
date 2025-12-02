import 'package:gemini_agent_tools/tool_annotation.dart';

part 'tool_utils.tools.g.dart';

@Tool(
  name: "overview",
  description:
      "This function updates the title and short summary of the full notes document. ",
)
class OverviewTool {
  final String? additionalInstructions;

  OverviewTool(this.additionalInstructions);
}

@Tool(
  name: "resources",
  description:
      "This function generates resources to supplement the users study. They can be one of flashcards, q&as or keywords. Use the additional instructions parameter to specify further instructions as to which of these should be generated.",
)
class ResourcesTool {
  final String? additionalInstructions;

  ResourcesTool(this.additionalInstructions);
}

@Tool(
  name: "research",
  description:
      "This function triggers a search for additional material online to supplement the users notes.",
)
class ResearchTool {
  final String? additionalInstructions;

  ResearchTool(this.additionalInstructions);
}
