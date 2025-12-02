import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:gemini_agent_tools/tool_annotation.dart';

enum AgentRole {
  principle,
  designer,
  toolBuilder,
  researcher,
  pipeline;

  bool get canCallTools => switch (this) {
    AgentRole.principle => true,
    _ => false,
  };

  Type get responseType => switch (this) {
    AgentRole.principle => PrincipleResponse,
    AgentRole.designer => StudyDesign,
    AgentRole.toolBuilder => StudyTools,
    AgentRole.researcher => ExternalResearchResponse,
    _ => BaseResponse,
  };

  Function(GeminiResponse response) get convert => switch (this) {
    AgentRole.principle => (response) => PrincipleResponse(
      content: response.firstCandidateText,
      calls: response.functionCalls,
    ),
    AgentRole.designer => (response) => StudyDesign.fromJson(
      response.firstCandidateJSON,
    ),
    AgentRole.toolBuilder => (response) => StudyTools.fromJson(
      response.firstCandidateJSON,
    ),
    AgentRole.researcher => (response) => ExternalResearchResponse(
      content: response.firstCandidateText,
    ),
    _ => (response) => BaseResponse(content: response.firstCandidateText),
  };

  String get systemInstructions {
    switch (this) {
      case AgentRole.principle:
        return """<System Instructions>
          You are the principal agent in a study-assistant system.
    
          You will receive:
          - A document containing possible study notes.
          - Additional information from previous iterations

          <Tool-Calling Guidance>
          **You must save you thought process as well as which tools you have used at each turn, to aid future iterations.**
          **You are highly encouraged to use the provided tools if they can help fulfill the user's request, especially for generating resources, research, or an overview.**
          You may choose multiple tools.
          </Tool-Calling Guidance>
      """;
      case AgentRole.designer:
        return """<System Instructions>
          You update the study-plan metadata based on student notes.

          Rules:
          - Output ONLY valid JSON. No explanations.
          - Preserve previous fields unless the new notes clearly change the topic.
          - Use simple, concise language.

          <Schema>
          {
            "title": string,         // Infer from dominant topic or heading
            "summary": string        // ≤40 words, plain-language explanation
          }

          Validity rule:
          If the text is not recognizable as study notes (see principal agent criteria), set valid=false in the JSON.
          </System Instructions>
        """;
      case AgentRole.toolBuilder:
        return """<System Instructions>
          Your task is to generate the most appropriate study tool from notes.

          Output only valid JSON.

          Tool Selection:
          - Use "keywords" for concept-heavy or definition-like content.
          - Use "flashcards" for fact-based or term–explanation pairs.
          - Use "qas" when the notes can naturally form questions.

          Variety Rule:
          Prefer a tool type not yet used. Avoid repeating the same type consecutively unless the content strongly demands it.

          <Schema>
          {
            "type": "flashcards" | "qas" | "keywords",
            "id": string,
            "title": string,
            "items": [
              // For "flashcards":
              { "front": string, "back": string },
              // For "qas":
              { "question": string, "answer": string },
              // For "keywords":
              { "keyword": string, "definition": string }
            ]
          }
          </System Instructions>
        """;
      case AgentRole.researcher:
        return """<System Instructions>
        You are the first step in a resource fetching and evaluating pipeline. 
        Your job is to return up to 5 links for online content related to the provided content.
        It can be blog posts, articles or youtube videos. 

        Respond in a comma seperated list.
        </System Instructions>
        """;
      case AgentRole.pipeline:
        return "";
    }
  }
}
