import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency_info.dart';
import 'user_provider.dart';

final selectedCurrencyProvider = Provider<CurrencyInfo>(
  (ref) => ref.watch(appSessionProvider).selectedCurrency,
);
