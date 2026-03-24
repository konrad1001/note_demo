import 'dart:ffi';

extension DateTimeX on DateTime {
  String _two(int n) => n.toString().padLeft(2, '0');

  String _month(int m) => [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ][m - 1];

  String formatHmDM() {
    final hour = _two(this.hour);
    final minute = _two(this.minute);
    final day = _two(this.day);
    final month = _two(this.month);

    return "$hour:$minute $day/$month";
  }

  String formatHm() {
    final hour = _two(this.hour);
    final minute = _two(this.minute);

    return "$hour:$minute";
  }

  String formatDM() {
    final day = _two(this.day);
    final month = _month(this.month);

    return "$month $day";
  }

  int formatDaysFromNow() {
    final timeLeft = difference(DateTime.now());
    return timeLeft.inDays;
  }
}
