import 'package:note_demo/agents/utils/tool_utils.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/providers/models/models.dart';

enum AgentRole {
  principle,
  designer,
  resourcer,
  researcher,
  observer,
  mapper,
  conversation,
  pipeline;

  List<Map<dynamic, dynamic>> get availableTools => switch (this) {
    AgentRole.principle => [
      invalidToolAsMap,
      overviewToolAsMap,
      resourcesToolAsMap,
      researchToolAsMap,
      mindmapToolAsMap,
    ],
    AgentRole.conversation => [
      overviewToolAsMap,
      resourcesToolAsMap,
      researchToolAsMap,
      mindmapToolAsMap,
      focusTimerToolAsMap,
    ],
    _ => [],
  };

  int get thinkingBudget => switch (this) {
    AgentRole.principle => 1024,
    AgentRole.conversation => 1024,
    _ => 0,
  };

  Map? get responseSchema => switch (this) {
    AgentRole.resourcer => kResourceSchema,
    AgentRole.designer => kOverviewSchema,
    AgentRole.mapper => kMindMapSchema,
    _ => null,
  };

  Type get responseType => switch (this) {
    AgentRole.principle => PrincipleResponse,
    AgentRole.designer => StudyDesign,
    AgentRole.resourcer => StudyTools,
    AgentRole.researcher => ExternalResearchResponse,
    AgentRole.mapper => MindMap,
    _ => TextResponse,
  };

  Function(GeminiResponse response) get convert => switch (this) {
    AgentRole.principle => (response) => PrincipleResponse(
      content: response.firstCandidateText,
      calls: response.functionCalls,
    ),
    AgentRole.designer => (response) => StudyDesign.fromJson(
      response.firstCandidateJSON,
    ),
    AgentRole.resourcer => (response) => StudyTools.fromJson(
      response.firstCandidateJSON,
    ),
    AgentRole.researcher => (response) => ExternalResearchResponse(
      content: response.firstCandidateText,
    ),
    AgentRole.mapper => (response) => MindMap.fromJson(
      response.firstCandidateJSON,
    ),
    _ => (response) => TextResponse(
      content: response.firstCandidateText,
      calls: response.functionCalls,
    ),
  };

  String get systemInstructions {
    switch (this) {
      case AgentRole.principle:
        return """
          You are the principal agent in a study-assistant system.
    
          You will receive:
          - A document containing possible study notes.
          - Additional history from previous iterations.

          First ensure the content can validly be interpreted as study notes. If the content
          is in any other format, call the invalid tool to signal the content is invalid.

          Next, consult the agent history to see which tools have been called in previous iterations.

          Finally, consult the user preferences dictionary, which will contain positive or negative integers
          relating to a users opinion of that tool, if any.

          <Tool-Calling Guidance>
          - You may choose multiple tools.
          - You may choose zero tools.
          - Always call overview for valid notes when there is no agent history, afterwards, call it rarely.
          - Use additional information arguments to breifly instruct sub agent tools on specific aspects of the notes. <20 words.
          - Look at agent history to avoid over calling the same tools.
          - Don't over call tools the user dislikes.
          - Never call the same tool more than 2 times in a row. 
          - Never call overview two times in a row.
          - Every 2 or 3 iterations call no tools.
          </Tool-Calling Guidance>
      """;
      case AgentRole.designer:
        return """
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
          
        """;
      case AgentRole.resourcer:
        return """
          Your task is to generate the most appropriate study tool from notes.
          
          One of flashcards | qas | keywords

          You may be provided with additional instructions you must follow.

          Generate a maximum of 4 items for each type of resource.

          
        """;
      case AgentRole.researcher:
        return """
        """;
      case AgentRole.observer:
        return """
        
        You are a member of an agentic workflow. 
        You will recieve an event that has occured in the system, which you will summarise into a 
        short format that will form a historic timeline of events within the systems run time.

        Events will be one of 
        - A tool call, with optional additional arguments. State the name of the tool and its arguments. 

        Use no more than 40 words. Don't include any formatting
        
        """;
      case AgentRole.mapper:
        return """
        
        Your task is to generate a mind map schema for the provided notes.

        Generate no more than 10 nodes.

        You are generating JSON that MUST strictly conform to the provided OpenAPI schema.
        - Do not include extra fields
        - Always include "children" arrays (empty if none)
        - Limit nesting depth to 4
        - Output valid JSON only
        
        """;
      case AgentRole.conversation:
        return """
        Your name is Cebes.
        You are a friendly, Socratic study assistant. You help users learn by thinking through their own notes. 
        Use questions, prompts, and concise explanations to deepen understanding, expose gaps, and encourage 
        active reasoning. Be curious, clear, with a target demographic of university students.

        - Prefer asking thoughtful, guiding questions over giving direct answers when appropriate.
        - Encourage the user to reason, explain concepts in their own words, and make connections.
        - When giving explanations, be concise, structured, and conceptually grounded.

        You always complete your answers in 2 paragraphs or less. You don't use markup unless necessary.

        
        """;
      case _:
        return "";
    }
  }
}

Insight createChatIntro() => Insight.chat(
  role: .agent,
  body: "Hello! Start writing to automatically generate AI insights.",
  created: DateTime.now(),
  queryEmbedding: null,
);

const kExternalResearchPromptPipe = [
  """
        You are the first step in a resource fetching and synthesising pipeline. 
        Your job is to return up to 4 links for online content related to the provided content.
        It can be blog posts, articles or youtube videos. 

        Respond in a comma seperated list.
         """,
  """
       You are the second step in a resource fetching and synthesising pipeline. 
      Based on this list of resources, visit each one, then rank them in order of usefulness. make sure the links are valid.
      """,
  """
       You are the final step in a resource fetching and synthesising pipeline.
      The final step is to synthesise the list of evaluated resources.
      Your output will be displayed to a student using an ai study companion app, under a helpful "Next Steps" section, 
      so it must follow the following criteria:

      - Under 20 words
      - Must include the link
      - .md format
     
    """,
];

const kOverviewSchema = {
  "type": "object",
  "properties": {
    "title": {"type": "string"},
    "summary": {"type": "string"},
  },
  "required": ["title", "summary"],
  "propertyOrdering": ["title", "summary"],
};

const kResourceSchema = {
  "type": "object",
  "properties": {
    "type": {
      "type": "string",
      "description": "One of flashcards | qas | keywords",
    },
    "id": {"type": "string"},
    "title": {"type": "string"},
    "items": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "front": {"type": "string"},
          "back": {"type": "string"},
        },
        "required": ["front", "back"],
        "propertyOrdering": ["front", "back"],
      },
    },
  },
  "required": ["type", "id", "title", "items"],
  "propertyOrdering": ["type", "id", "title", "items"],
};

const kMindMapSchema = {
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "description": "Unique identifier for the mind map",
    },
    "title": {"type": "string", "description": "Title of the mind map"},
    "nodes": {
      "type": "array",
      "description": "All nodes in the mind map",
      "items": {
        "type": "object",
        "properties": {
          "id": {"type": "string"},
          "label": {
            "type": "string",
            "description": "The text displayed on the node",
          },
          "parentId": {
            "type": "string",
            "description": "ID of parent node, null for root node",
          },
        },
        "required": ["id", "label"],
        "propertyOrdering": ["id", "label", "parentId"],
      },
    },
  },
  "required": ["id", "title", "nodes"],
  "propertyOrdering": ["id", "title", "nodes"],
};
