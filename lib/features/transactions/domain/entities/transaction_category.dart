import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'transaction_type.dart';

enum TransactionCategory {
  food,
  transport,
  shopping,
  bills,
  health,
  entertainment,
  salary,
  freelance,
  savings,
  other,
}

extension TransactionCategoryX on TransactionCategory {
  String get label => switch (this) {
    TransactionCategory.food => 'Food',
    TransactionCategory.transport => 'Transport',
    TransactionCategory.shopping => 'Shopping',
    TransactionCategory.bills => 'Bills',
    TransactionCategory.health => 'Health',
    TransactionCategory.entertainment => 'Fun',
    TransactionCategory.salary => 'Salary',
    TransactionCategory.freelance => 'Freelance',
    TransactionCategory.savings => 'Savings',
    TransactionCategory.other => 'Other',
  };

  IconData get icon => switch (this) {
    TransactionCategory.food => Icons.restaurant_rounded,
    TransactionCategory.transport => Icons.directions_bus_rounded,
    TransactionCategory.shopping => Icons.shopping_bag_rounded,
    TransactionCategory.bills => Icons.receipt_long_rounded,
    TransactionCategory.health => Icons.favorite_rounded,
    TransactionCategory.entertainment => Icons.movie_rounded,
    TransactionCategory.salary => Icons.payments_rounded,
    TransactionCategory.freelance => Icons.laptop_mac_rounded,
    TransactionCategory.savings => Icons.savings_rounded,
    TransactionCategory.other => Icons.apps_rounded,
  };

  Color get color => switch (this) {
    TransactionCategory.food => AppColors.catFood,
    TransactionCategory.transport => AppColors.catTransport,
    TransactionCategory.shopping => AppColors.catShopping,
    TransactionCategory.bills => AppColors.catBills,
    TransactionCategory.health => AppColors.catHealth,
    TransactionCategory.entertainment => AppColors.catEntertain,
    TransactionCategory.salary => AppColors.catSalary,
    TransactionCategory.freelance => AppColors.catFreelance,
    TransactionCategory.savings => AppColors.catSavings,
    TransactionCategory.other => AppColors.catOther,
  };

  TransactionType get defaultType => switch (this) {
    TransactionCategory.salary ||
    TransactionCategory.freelance ||
    TransactionCategory.savings => TransactionType.income,
    _ => TransactionType.expense,
  };

  static List<TransactionCategory> forType(TransactionType type) {
    if (type == TransactionType.income) {
      return const [
        TransactionCategory.salary,
        TransactionCategory.freelance,
        TransactionCategory.savings,
        TransactionCategory.other,
      ];
    }

    return const [
      TransactionCategory.food,
      TransactionCategory.transport,
      TransactionCategory.shopping,
      TransactionCategory.bills,
      TransactionCategory.health,
      TransactionCategory.entertainment,
      TransactionCategory.other,
    ];
  }
}
