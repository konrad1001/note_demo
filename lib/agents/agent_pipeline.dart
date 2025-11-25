import 'package:note_demo/agents/agent_utils.dart';
import 'package:note_demo/agents/gpt_agent.dart';
import 'package:note_demo/models/agent_responses/models.dart';

typedef PipelineStatus<T> = ({int index, T object, bool finished});

class AgentPipeline {
  int pipeLength;
  List<String> promptPipe;

  final role = AgentRole.pipeline;

  AgentPipeline(this.pipeLength, {required this.promptPipe}) {
    assert(
      pipeLength == promptPipe.length,
      "Pipelength must be equal to prompt number in pipe!",
    );
    promptPipe = promptPipe;
  }

  Stream<PipelineStatus<String>> fetch(String initial) async* {
    final agents = List.generate(
      pipeLength,
      (_) => GPTAgent<BaseResponse>(role: role),
    );
    var responseChain = [initial];

    for (var i in Iterable.generate(pipeLength)) {
      final agent = agents[i];
      final prompt = promptPipe[i];

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
