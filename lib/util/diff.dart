import 'package:diff_match_patch/diff_match_patch.dart';

class DiffTool {
  final DiffMatchPatch _dmp = DiffMatchPatch();

  (int, String) diff(String text1, String text2) {
    final diffs = _dmp.diff(text1, text2).where((d) => d.operation != 0);

    final diffLength = diffs.fold(0, (count, diff) {
      return count + diff.text.length;
    });

    return (diffLength, diffs.join());
  }
}
