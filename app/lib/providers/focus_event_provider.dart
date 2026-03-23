import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/models/gemini_response.dart';
import 'package:note_demo/models/insights.dart';
import 'package:note_demo/providers/agent_providers/conversation_agent_provider.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';

const kFocusTimerToolName = "focusTimer";

class FocusEventNotifier extends Notifier<FocusEvent?> {
  @override
  FocusEvent? build() {
    _subscribe();
    return null;
  }

  void _subscribe() {
    ref.listen<ConversationAgentState>(conversationAgentProvider, (prev, next) {
      final call = next.callsMe(kFocusTimerToolName);
      if (call != null) {
        _runFromCall(call, next.callback);
      }
    });
  }

  setEvent(FocusEvent event) async {
    if (isActive()) return;
    state = event;

    ref
        .read(insightProvider.notifier)
        .append(
          insight: Insight.focusEvent(
            startTime: event.startTime,
            duration: event.duration,
            queryEmbedding: null,
          ),
        );

    _runCountdown(event.duration, () {
      print("Event finished");
      state = null;
    });
  }

  cancelCurrentEvent() {
    state = null;
  }

  bool isActive() {
    final event = state;
    if (event == null) return false;

    if (DateTime.now().isAfter(event.endTime)) {
      state = null;
      return false;
    } else {
      print(
        "Event active. Time left: ${event.endTime.difference(DateTime.now())}",
      );
      return true;
    }
  }

  _runFromCall(GeminiFunctionResponse call, VoidCallback? callback) async {
    print(call.args);
    final args = call.args.values.toList();
    print(args);
    if (args.length == 1) {
      final minutes = args[0];
      setEvent(
        FocusEvent(
          startTime: DateTime.now(),
          duration: Duration(minutes: int.parse(minutes)),
        ),
      );
    } else if (args.length == 2) {
      final minutes = args[0];
      final seconds = args[1];
      setEvent(
        FocusEvent(
          startTime: DateTime.now(),
          duration: Duration(
            minutes: int.parse(minutes),
            seconds: int.parse(seconds),
          ),
        ),
      );
    } else {
      setEvent(
        FocusEvent(startTime: DateTime.now(), duration: Duration(seconds: 20)),
      );
    }

    ref
        .read(insightProvider.notifier)
        .append(
          insight: Insight.functionCall(function: call, queryEmbedding: null),
        );

    callback?.call();
  }

  Future<void> _runCountdown(
    Duration duration,
    VoidCallback? onComplete,
  ) async {
    await Future.delayed(duration);
    if (onComplete != null) {
      onComplete();
    }
  }
}

final focusEventProvider = NotifierProvider<FocusEventNotifier, FocusEvent?>(
  () => FocusEventNotifier(),
);
