import 'dart:async';

Future<T> retry<T>(
  FutureOr<T> Function() fn, {
  int retries = 3,
  FutureOr<void> Function(Exception, int)? onRetry,
}) async {
  var attempts = 0;
  while (true) {
    attempts++;
    try {
      return await fn();
    } on Exception catch (e) {
      if (attempts >= retries) {
        rethrow;
      }

      if (onRetry != null) {
        await onRetry(e, attempts);
      }
    }
  }
}
