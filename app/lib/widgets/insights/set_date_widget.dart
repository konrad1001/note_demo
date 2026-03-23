import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_demo/models/insights.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/insight_notifier.dart';
import 'package:note_demo/util/date_time.dart';

class KeyDateWidget extends ConsumerStatefulWidget {
  const KeyDateWidget({
    super.key,
    required this.created,
    required this.insight,
  });

  final DateTime created;
  final Insight insight;

  @override
  ConsumerState<KeyDateWidget> createState() => _KeyDateWidgetState();
}

class _KeyDateWidgetState extends ConsumerState<KeyDateWidget> {
  DateTime? chosenDate;

  String _label(DateTime? date) {
    if (date == null) {
      return "Would you like to set a new Key date?";
    } else {
      return "You've got a key date set for ...";
    }
  }

  String _submissionString(DateTime date) {
    final timeLeft = date.difference(DateTime.now());
    final days = timeLeft.inDays;

    return "Got it. I've set your key date to ${date.formatDM()}. $days days to go!";
  }

  @override
  Widget build(BuildContext context) {
    final keyDate = ref.watch(appNotifierProvider).currentFileMetaData.keyDate;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          Text(_label(keyDate), style: GoogleFonts.ptSerif()),
          _CompactDatePicker(
            initialDate: keyDate,
            onDateChanged: (value) {
              setState(() {
                chosenDate = value;
              });
            },
          ),
          Text(
            "Set a key date to tell Cebes an important date or deadline you'd like to prepare for.",
            style: GoogleFonts.ptSerif(
              fontStyle: FontStyle.italic,
              textStyle: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withAlpha(150),
              ),
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  final date = chosenDate ?? keyDate;

                  print("Sending choice: $date");

                  if (date == null) return;

                  ref.read(appNotifierProvider.notifier).setKeyDate(date);
                  ref
                      .read(insightProvider.notifier)
                      .updateLatest(
                        insight: Insight.chat(
                          role: .agent,
                          body: _submissionString(date!),
                          created: DateTime.now(),
                          queryEmbedding: null,
                        ),
                      );
                },
                child: Text(
                  "Update",
                  style: GoogleFonts.ptSerif(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
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
                widget.created.formatHmDM(),
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

class _CompactDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?>? onDateChanged;
  final String dayLabel;
  final String monthLabel;

  const _CompactDatePicker({
    this.initialDate,
    this.onDateChanged,
    this.dayLabel = 'DD',
    this.monthLabel = 'MM',
  });

  @override
  State<_CompactDatePicker> createState() => _CompactDatePickerState();
}

class _CompactDatePickerState extends State<_CompactDatePicker> {
  late TextEditingController _dayController;
  late TextEditingController _monthController;
  late FocusNode _dayFocusNode;
  late FocusNode _monthFocusNode;

  @override
  void initState() {
    super.initState();
    _dayController = TextEditingController(
      text: widget.initialDate?.day.toString().padLeft(2, '0') ?? '',
    );
    _monthController = TextEditingController(
      text: widget.initialDate?.month.toString().padLeft(2, '0') ?? '',
    );
    _dayFocusNode = FocusNode();
    _monthFocusNode = FocusNode();

    _dayController.addListener(_notifyDateChange);
    _monthController.addListener(_notifyDateChange);
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _dayFocusNode.dispose();
    _monthFocusNode.dispose();
    super.dispose();
  }

  void _notifyDateChange() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);

    if (day != null &&
        month != null &&
        day >= 1 &&
        day <= 31 &&
        month >= 1 &&
        month <= 12) {
      final now = DateTime.now();
      try {
        var date = DateTime(now.year, month, day);

        if (date.isBefore(now)) {
          date = DateTime(now.year + 1, month, day);
        }
        widget.onDateChanged?.call(date);
      } catch (e) {
        widget.onDateChanged?.call(null);
      }
    } else {
      widget.onDateChanged?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: GoogleFonts.ptSerif(textStyle: TextStyle(fontSize: 14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            child: TextField(
              controller: _dayController,
              focusNode: _dayFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 2,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _DayInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: widget.dayLabel,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                isDense: true,
                helperStyle: GoogleFonts.ptSerif(
                  textStyle: TextStyle(fontSize: 14),
                ),
                labelStyle: GoogleFonts.ptSerif(),
                hintStyle: GoogleFonts.ptSerif(
                  textStyle: TextStyle(fontSize: 14),
                ),
              ),
              onChanged: (value) {
                if (value.length == 2) {
                  _monthFocusNode.requestFocus();
                }
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('/', style: TextStyle(fontSize: 18)),
          ),

          SizedBox(
            width: 40,
            child: TextField(
              controller: _monthController,
              focusNode: _monthFocusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 2,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _MonthInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: widget.monthLabel,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                isDense: true,
                hintStyle: GoogleFonts.ptSerif(
                  textStyle: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int? value = int.tryParse(newValue.text);

    if (value == null) return newValue;

    // Limit to 31
    if (value > 31) {
      return oldValue;
    }

    return newValue;
  }
}

class _MonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int? value = int.tryParse(newValue.text);

    if (value == null) return newValue;

    // Limit to 12
    if (value > 12) {
      return oldValue;
    }

    return newValue;
  }
}
