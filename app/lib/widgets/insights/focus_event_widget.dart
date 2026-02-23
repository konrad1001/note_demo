import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/providers/models/models.dart';

class FocusEventWidget extends ConsumerStatefulWidget {
  const FocusEventWidget({
    super.key,
    required this.event,
    required this.insight,
  });

  final FocusEvent event;
  final Insight insight;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FocusEventWidgetState();
}

class _FocusEventWidgetState extends ConsumerState<FocusEventWidget> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _complete = false;

  DateTime get _endTime => widget.event.endTime;

  @override
  void initState() {
    super.initState();
    _updateRemaining();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final remaining = _endTime.difference(DateTime.now());

    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });

    if (remaining.isNegative) {
      _timer?.cancel();
      _complete = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime date, {int mode = 0}) {
    String two(int n) => n.toString().padLeft(2, '0');

    final hour = two(date.hour);
    final minute = two(date.minute);
    final day = two(date.day);
    final month = two(date.month);

    if (mode == 0) {
      return "$hour:$minute $day/$month";
    } else {
      return "$hour:$minute";
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes == 1 ? "minute" : "minutes";
    final d = duration - Duration(minutes: duration.inMinutes);

    final seconds = d.inSeconds == 1 ? "second" : "seconds";

    if (duration.inMinutes == 0) return "${d.inSeconds} $seconds";
    if (d.inSeconds == 0) return "${duration.inMinutes} $minutes";

    return "${duration.inMinutes} $minutes ${d.inSeconds} $seconds";
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(
            "Time to lock in.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          if (_complete)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.check, size: 18),
                    Text(
                      "Timer Complete",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    style: GoogleFonts.notoSerif(
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                    ),
                    "A Timer ran from ${_formatDateTime(widget.event.startTime, mode: 1)} for ${_formatDuration(widget.event.duration)}. Well done! Remember to take frequent breaks inbetween work.",
                  ),
                ),
              ],
            )
          else
            Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    style: GoogleFonts.notoSerif(
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                    ),
                    "Free yourself from distractions. I won't generate any insights for you during this time, unless you ask.",
                  ),
                ),
              ],
            ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ref
                      .read(insightProvider.notifier)
                      .deleteInsight(widget.insight);
                },
                icon: Icon(Icons.delete_sharp, size: 18),
              ),
              Spacer(),
              Text(
                _formatDateTime(widget.event.startTime),
                style: TextStyle(
                  fontSize: 11.0,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
