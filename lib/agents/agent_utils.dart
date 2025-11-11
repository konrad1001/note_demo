import 'package:note_demo/models/agent_responses/models.dart';

enum AgentRole {
  principle,
  designer,
  toolBuilder;

  Type get responseType => switch (this) {
    AgentRole.principle => PrincipleResponse,
    AgentRole.designer => StudyDesign,
    AgentRole.toolBuilder => StudyTools,
  };

  Function(Map<String, Object?> json) get fromJson => switch (this) {
    AgentRole.principle => PrincipleResponse.fromJson,
    AgentRole.designer => StudyDesign.fromJson,
    AgentRole.toolBuilder => StudyTools.fromJson,
  };

  String get systemInstructions {
    switch (this) {
      case AgentRole.principle:
        return """<System Instructions>
          You are the principle agent within a study assistant agentic tool. You will be given a document that should contain study notes, as well
          as a JSON already containing some information
          You will communicate in JSON matching the following specification.
          You should first check if the document looks like the notes of a student on a specific topic. If the content is not something that could
          feasibly be the basis of a study plan, return false for the 'valid' parameter. 
          Secondly, you will have access to two tools, "plan" and "resource". The 'tool' parameter should be a list of strings containing one or none
          of either of these functions, which call other agents.
          - "plan": call this when the contents of the notes vary enough from the given study plan, to trigger it to get updated
          - "resource": call this to trigger a new resource to be made for the notes. Use when enough new content arrives
          <Specification> Respond in the following structure:
          {
            "valid": bool, // Is the content a valid set of notes, that it makes sense to generate a study plan. False if the content is nonsensical or empty.
            "tool": [string] // Either "plan" or "resource" or both.
            "agent_notes": string  // Notes to yourself for future iterations. Keep this brief. 
          }
          """;
      case AgentRole.designer:
        return """<System Instructions>
          You are an expert data generator for a study assistant. You will be given a document that should contain study notes.
          Your sole purpose is to output a single, valid JSON object based on the specification. 
          If the document does not look like a students set of notes that could feasibly be converted into a study plan, return false in the valid field
          DO NOT include any explanatory text, commentary, or markdown outside of the final JSON object.
          <Specification> Convert the given content into the following structure:
          {
            "valid": bool, // Is the content a valid set of notes, that it makes sense to generate a study plan. False if the content is nonsensical or empty.
            "title": string, // The inferred title of the topic.
            "summary": string, // A concise summary of the topic in 20 words.
            "study_plan": [string] // An array of strings, each representing a step in a study plan. Try to use subdivisions in the notes to make a chronological plan. If not enough content is available, this should be an empty array.
          }
          Ensure that the JSON is properly formatted and valid. 
        """;
      case AgentRole.toolBuilder:
        return """<System Instructions>
          You are an expert data generator for a study assistant. Your sole purpose is to output a single, valid JSON object based on the specification. 
          DO NOT include any explanatory text, commentary, or markdown outside of the final JSON object.

          <Specification> 
          Analyze the given content and determine which type of study tool is most suitable (flashcards, qas, or keywords).
          Use your best judgment based on the structure and purpose of the text.
          Then, generate the JSON object following this schema:

          {
            "type": "flashcards" | "qas" | "keywords", // The chosen tool type.
            "id": string, // A short unique identifier (e.g., "set1" or "physics_101").
            "title": string, // The inferred title or main topic.
            "items": [
              // For "flashcards":
              { "front": string, "back": string },
              // For "qas":
              { "question": string, "answer": string },
              // For "keywords":
              { "keyword": string, "definition": string }
            ]
          }
        """;
    }
  }
}
