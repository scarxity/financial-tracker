import 'package:flutter/material.dart';

/// Transaction type enum used across the app.
enum TransactionType {
  expense,
  income;

  String get label {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.expense:
        return Icons.arrow_downward_rounded;
      case TransactionType.income:
        return Icons.arrow_upward_rounded;
    }
  }
}

/// Summary period filter for the Home screen.
enum SummaryPeriod {
  week,
  month,
  all;

  String get label {
    switch (this) {
      case SummaryPeriod.week:
        return 'This Week';
      case SummaryPeriod.month:
        return 'This Month';
      case SummaryPeriod.all:
        return 'All Time';
    }
  }
}

/// Predefined icon set for wallets and categories.
class AppIcons {
  AppIcons._();

  /// Icons available for wallet selection.
  static const Map<String, IconData> walletIcons = {
    'wallet': Icons.account_balance_wallet_rounded,
    'bank': Icons.account_balance_rounded,
    'cash': Icons.payments_rounded,
    'card': Icons.credit_card_rounded,
    'savings': Icons.savings_rounded,
    'money': Icons.attach_money_rounded,
    'euro': Icons.euro_rounded,
    'piggy_bank': Icons.savings_outlined,
  };

  /// Icons available for category selection.
  static const Map<String, IconData> categoryIcons = {
    'food': Icons.restaurant_rounded,
    'electricity': Icons.bolt_rounded,
    'internet': Icons.wifi_rounded,
    'water': Icons.water_drop_rounded,
    'laundry': Icons.local_laundry_service_rounded,
    'rent': Icons.home_rounded,
    'transport': Icons.directions_bus_rounded,
    'streaming': Icons.subscriptions_rounded,
    'gaming': Icons.sports_esports_rounded,
    'hobbies': Icons.palette_rounded,
    'clothing': Icons.checkroom_rounded,
    'health': Icons.fitness_center_rounded,
    'education': Icons.school_rounded,
    'transfer_out': Icons.call_made_rounded,
    'transfer_in': Icons.call_received_rounded,
    'salary': Icons.work_rounded,
    'freelance': Icons.laptop_rounded,
    'allowance': Icons.card_giftcard_rounded,
    'gift': Icons.redeem_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'entertainment': Icons.movie_rounded,
    'personal': Icons.person_rounded,
    'other': Icons.more_horiz_rounded,
    'category': Icons.category_rounded,
  };

  /// Resolve an icon name to IconData. Falls back to a default icon.
  static IconData resolve(String name, {bool isWallet = false}) {
    if (isWallet) {
      return walletIcons[name] ?? Icons.account_balance_wallet_rounded;
    }
    return categoryIcons[name] ?? Icons.category_rounded;
  }
}
