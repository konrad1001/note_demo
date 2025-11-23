import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';

class AgentPipeline {
  final role = AgentRole.pipeline;
  final promptPipe = [
    """<System Instructions>
        You are the first step in a resource fetching and synthesising pipeline. 
        Your job is to return up to 4 links for online content related to the provided content.
        It can be blog posts, articles or youtube videos. 

        Respond in a comma seperated list.
        </System Instructions> """,
    """
      <System Instructions> You are the second step in a resource fetching and synthesising pipeline. 
      Based on this list of resources, visit each one, then rank them in order of usefulness. make sure the links are valid.
      </System Instructions>""",
    """
      <System Instructions> You are the final step in a resource fetching and synthesising pipeline.
      The final step is to synthesise the list of evaluated resources.
      Your output will be displayed to a student using an ai study companion app, under a helpful "Next Steps" section, 
      so it must follow the following criteria:

      - Under 20 words
      - Must include the link
      - .md format
     </System Instructions>
    """,
  ];

  Future<String> fetch(String initial) async {
    final agents = List.generate(
      promptPipe.length,
      (_) => GPTAgent<BaseResponse>(role: role),
    );
    var responseChain = [initial];

    for (var i in Iterable.generate(agents.length)) {
      final agent = agents[i];
      final prompt = promptPipe[i];

      try {
        final next = await agent.fetch('$prompt ${responseChain.last}');
        responseChain.add(next.content);
        print("pipeline ${i + 1} success, returned: ${next.content}");
      } catch (e) {
        responseChain.add(e.toString());
      }
    }
    return responseChain.last;
  }
}
