import 'package:note_demo/agents/utils/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';

typedef PipelineStatus<T> = ({int index, T object, bool finished});

class AgentPipeline {
  int pipeLength;
  List<String> promptPipe;
  String? additionalPromptInput;

  final agent = GPTAgent<TextResponse>(role: AgentRole.pipeline);

  AgentPipeline(
    this.pipeLength, {
    required this.promptPipe,
    this.additionalPromptInput,
  }) {
    assert(
      pipeLength == promptPipe.length,
      "Pipelength must be equal to prompt number in pipe!",
    );

    promptPipe = promptPipe;
  }

  Stream<PipelineStatus<String>> fetch(String initial) async* {
    var responseChain = [initial];

    for (var i in Iterable.generate(pipeLength)) {
      var prompt = promptPipe[i];

      if (i == 0 && additionalPromptInput != null) {
        prompt = "$additionalPromptInput $prompt";
      }

      try {
        final next = await agent.fetch('$prompt ${responseChain.last}');
        responseChain.add(next.content);
        yield (index: i + 1, object: next.content, finished: false);
      } catch (e) {
        responseChain.add(e.toString());
        yield (index: 0, object: e.toString(), finished: true);
      }
    }
    yield (index: 0, object: responseChain.last, finished: true);
  }
}
