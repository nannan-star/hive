/// Date helpers using `YYYY-MM-DD` text storage.
String formatDateYmd(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime parseDateYmd(String ymd) {
  final parts = ymd.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String yearMonthPrefix(int year, int month) {
  final m = month.toString().padLeft(2, '0');
  return '$year-$m';
}
