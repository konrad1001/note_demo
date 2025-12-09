import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_demo/util/future.dart';

void main() {
  group('retry()', () {
    test('returns value on first success without retries', () async {
      var callCount = 0;

      final result = await retry(() {
        callCount++;
        return Future.value('OK');
      });

      expect(result, 'OK');
      expect(callCount, 1);
    });

    test('retries until success', () async {
      var callCount = 0;

      final result = await retry(() {
        callCount++;
        if (callCount < 3) throw Exception('fail');
        return 'success on 3rd try';
      });

      expect(result, 'success on 3rd try');
      expect(callCount, 3);
    });

    test('calls onRetry for each retry attempt', () async {
      var callCount = 0;
      final retryEvents = <int>[];

      final result = await retry(
        () {
          callCount++;
          if (callCount < 4) throw Exception('fail');
          return 'done';
        },
        retries: 5,
        onRetry: (e, attempt) {
          retryEvents.add(attempt);
        },
      );

      expect(result, 'done');
      expect(callCount, 4);

      // Should have been called for attempts 1, 2, 3
      expect(retryEvents, [1, 2, 3]);
    });

    test('throws after exhausting retries', () async {
      var callCount = 0;

      expect(
        () => retry(() {
          callCount++;
          throw Exception('always fails');
        }, retries: 3),
        throwsA(isA<Exception>()),
      );

      expect(callCount, 3);
    });

    test('does not catch non-Exception errors', () async {
      expect(
        () => retry(() {
          throw Error(); // Should not be caught by "on Exception catch"
        }),
        throwsA(isA<Error>()),
      );
    });

    test('passes correct exception and attempt index to onRetry', () async {
      final exceptions = <Exception>[];
      final attempts = <int>[];

      await retry<Object?>(
        () {
          throw Exception('boom');
        },
        retries: 3,
        onRetry: (e, attempt) {
          exceptions.add(e);
          attempts.add(attempt);
        },
      ).catchError((_) {
        return null;
      }); // ignore final exception

      expect(
        exceptions.length,
        2,
      ); // retries = 3 → calls onRetry twice (attempts 1 and 2)
      expect(attempts, [1, 2]);
      expect(exceptions.first.toString(), contains('boom'));
    });
  });
}
