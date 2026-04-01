class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.label,
  });

  final String code;
  final String symbol;
  final String label;

  static const defaultCurrency = CurrencyInfo(
    code: 'INR',
    symbol: 'Rs.',
    label: 'Indian Rupee',
  );

  static const popular = <CurrencyInfo>[
    CurrencyInfo(code: 'INR', symbol: 'Rs.', label: 'Indian Rupee'),
    CurrencyInfo(code: 'USD', symbol: '\$', label: 'US Dollar'),
    CurrencyInfo(code: 'EUR', symbol: 'EUR ', label: 'Euro'),
    CurrencyInfo(code: 'GBP', symbol: 'GBP ', label: 'British Pound'),
    CurrencyInfo(code: 'AED', symbol: 'AED ', label: 'UAE Dirham'),
    CurrencyInfo(code: 'SGD', symbol: 'SGD ', label: 'Singapore Dollar'),
    CurrencyInfo(code: 'JPY', symbol: 'JPY ', label: 'Japanese Yen'),
    CurrencyInfo(code: 'AUD', symbol: 'AUD ', label: 'Australian Dollar'),
  ];

  static CurrencyInfo? findByCode(String? code) {
    if (code == null) return null;
    for (final item in popular) {
      if (item.code == code) {
        return item;
      }
    }
    return null;
  }
}
