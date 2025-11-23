import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';

enum AgentRole {
  principle,
  designer,
  toolBuilder,
  researcher,
  pipeline;

  Type get responseType => switch (this) {
    AgentRole.principle => PrincipleResponse,
    AgentRole.designer => StudyDesign,
    AgentRole.toolBuilder => StudyTools,
    AgentRole.researcher => ExternalResearchResponse,
    _ => BaseResponse,
  };

  Function(GeminiResponse response) get convert => switch (this) {
    AgentRole.principle => (response) => PrincipleResponse.fromJson(
      response.firstCandidateJSON,
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
          - Sections with previously generated information.

          Your job:
          1. Validate whether the document is appropriate as student study notes.
          2. Decide whether to trigger the “plan” and/or “tools” and/or "research" tool.
          3. Output strictly valid JSON matching the schema.

          <Validation Criteria>
          Return valid = false if ANY of the following:
          - The text is empty or consists of fewer than 10 meaningful words.
          - It contains no identifiable topic or subject.
          - It is purely narrative fiction, unrelated code, chat, or random text.
          - It cannot be used to generate a study plan.

          <Tool-Calling Rules>
          You may include at most ONE of each tool per iteration.  
          You may choose none.

          Use **"plan"** if:
          - The new notes introduce ≥2 new concepts not in the existing plan, OR
          - The summary no longer matches ≥20% of the introduced content.

          Use **"“tools”"** if:
          - The new notes add ≥2 new subtopics, OR
          - The user is building detail that would benefit from flashcards/Q&A/keywords.

          Use **""research""** if:
          - The new notes introduce content that would benefit from explanatory youtube videos or online articles. 

          <Schema>
          {
            "valid": boolean,
            "tool": string[], 
            "agent_notes": string
          }
          </System Instructions>

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
