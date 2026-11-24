import 'package:intl/intl.dart';

/// Formatos de fechas y números según el idioma de la app.
class Formatters {
  Formatters._();

  static String date(DateTime? value, String locale) {
    if (value == null) return '—';
    return DateFormat.yMMMd(locale).format(value.toLocal());
  }

  static String dateTime(DateTime? value, String locale) {
    if (value == null) return '—';
    return DateFormat.yMMMd(locale).add_jm().format(value.toLocal());
  }

  static String time(DateTime value, String locale) {
    return DateFormat.jm(locale).format(value.toLocal());
  }

  static String dayMonth(DateTime value, String locale) {
    return DateFormat.MMMd(locale).format(value);
  }

  static String weekdayDate(DateTime value, String locale) {
    return DateFormat.MMMEd(locale).format(value.toLocal());
  }

  static String number(num value, String locale) {
    return NumberFormat.decimalPattern(locale).format(value);
  }

  static String percent(num value, String locale, {int decimals = 0}) {
    final formatted = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimals,
    ).format(value);
    return '$formatted %';
  }

  /// Fecha en el formato que espera la API (yyyy-MM-dd).
  static String apiDate(DateTime value) =>
      DateFormat('yyyy-MM-dd').format(value);
}
