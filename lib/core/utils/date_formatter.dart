import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static final _dayHeader = DateFormat('EEE, d MMM');
  static final _month = DateFormat('MMMM yyyy');
  static final _compactMonth = DateFormat('MMM yyyy');

  static String transactionHeader(DateTime date) => _dayHeader.format(date);

  static String fullMonth(DateTime date) => _month.format(date);

  static String compactMonth(DateTime date) => _compactMonth.format(date);
}
