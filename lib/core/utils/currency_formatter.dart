import 'package:intl/intl.dart';

import '../../shared/models/currency_info.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static String format(
    double amount,
    CurrencyInfo currency, {
    bool compact = false,
  }) {
    final formatter = compact
        ? NumberFormat.compactCurrency(
            symbol: currency.symbol,
            decimalDigits: 1,
          )
        : NumberFormat.currency(
            symbol: currency.symbol,
            decimalDigits: amount.abs() >= 1000 ? 0 : 2,
          );
    return formatter.format(amount);
  }
}
