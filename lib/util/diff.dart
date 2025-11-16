import 'package:diff_match_patch/diff_match_patch.dart';

class DiffTool {
  final DiffMatchPatch _dmp = DiffMatchPatch();

  UserDiff diff(String text1, String text2) {
    final diffs = _dmp.diff(text1, text2).where((d) => d.operation != 0);

    return UserDiff.fromDmp(dmp: diffs.toList());
  }
}

class UserDiff {
  final String additions;
  final String deletions;
  final int size;

  UserDiff._(this.size, this.additions, this.deletions);

  factory UserDiff.fromDmp({required List<Diff> dmp}) {
    String additions = "";
    String deletions = "";
    int size = 0;

    for (final diff in dmp) {
      if (diff.operation == 1) {
        additions += diff.text;
        size += diff.text.length;
      } else if (diff.operation == -1) {
        deletions += diff.text;
        size += diff.text.length;
      }
    }

    return UserDiff._(size, additions, deletions);
  }

  String get all => additions + deletions;
}
