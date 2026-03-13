import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/agents/utils/embedding_service.dart';
import 'package:note_demo/models/agent_responses/models.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';

void handleException(Object e, Ref ref) {
  if (e is NException) {
    ref.read(insightProvider.notifier).append(insight: e.toInsight(null));
  } else if (e is Exception) {
    ref
        .read(insightProvider.notifier)
        .append(
          insight: Insight.error(
            message: e.toString(),
            code: 800,
            queryEmbedding: null,
            created: DateTime.now(),
          ),
        );
  }
}

abstract class NException extends InsightConvertable implements Exception {
  final String message;
  final int code;

  const NException({required this.message, required this.code});

  @override
  toInsight(Embedding? queryEmbedding) => Insight.error(
    message: message,
    code: code,
    queryEmbedding: queryEmbedding,
    created: DateTime.now(),
  );
}

class ApiException extends NException {
  final int statusCode;
  const ApiException(this.statusCode, String? message)
    : super(message: message ?? "API exception.", code: statusCode);
}

class LogicException extends NException {
  LogicException.missingApiToken()
    : super(message: "Missing API token.", code: 901);
}
