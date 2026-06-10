import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static final DateFormat _date = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dateShort = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthYear = DateFormat('MMM yyyy', 'id_ID');

  static String formatCurrency(double amount) {
    return _currency.format(amount);
  }

  static String formatDate(DateTime date) {
    return _date.format(date);
  }

  static String formatDateShort(DateTime date) {
    return _dateShort.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }
}
