import 'package:flutter_test/flutter_test.dart';
import 'package:note_demo/util/diff.dart';

void main() {
  final tool = DiffTool();

  test('identical strings produce empty UserDiff', () {
    final d = tool.diff('hello', 'hello');
    expect(d.size, 0);
    expect(d.additions, '');
    expect(d.deletions, '');
    expect(d.all, '');
  });

  test('addition only yields additions and size equals additions length', () {
    final d = tool.diff('hello', 'hello world');
    expect(d.additions.isNotEmpty, true);
    expect(d.deletions, '');
    expect(d.size, d.additions.length + d.deletions.length);
  });

  test('deletion only yields deletions and size equals deletions length', () {
    final d = tool.diff('hello world', 'hello');
    expect(d.deletions.isNotEmpty, true);
    expect(d.additions, '');
    expect(d.size, d.deletions.length);
    expect(d.size, " world".length);
  });

  test(
    'mixed changes produce both additions and deletions and size is sum',
    () {
      final a = 'The quick brown fox jumps over the lazy dog';
      final b = 'The quick red fox leaped over a lazy cat';
      final d = tool.diff(a, b);
      expect(d.additions.isNotEmpty, true);
      expect(d.deletions.isNotEmpty, true);
      expect(d.size, d.additions.length + d.deletions.length);
    },
  );
}
