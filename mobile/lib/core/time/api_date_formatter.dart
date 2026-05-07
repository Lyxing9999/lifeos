import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiDateFormatterProvider = Provider<ApiDateFormatter>((ref) {
  return const ApiDateFormatter();
});

class ApiDateFormatter {
  const ApiDateFormatter();

  String formatDate(DateTime date) {
    final localDate = DateTime(date.year, date.month, date.day);
    final y = localDate.year.toString().padLeft(4, '0');
    final m = localDate.month.toString().padLeft(2, '0');
    final d = localDate.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String? formatNullableDate(DateTime? date) {
    if (date == null) return null;
    return formatDate(date);
  }

  String? formatNullableDateTime(DateTime? dateTime) {
    if (dateTime == null) return null;

    // Keep this as local datetime unless backend confirms UTC is required.
    return dateTime.toIso8601String();
  }

  DateTime? parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  DateTime? parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
