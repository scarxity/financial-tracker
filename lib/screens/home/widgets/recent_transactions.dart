import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_tracker/core/constants/app_constants.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/core/utils/currency_formatter.dart';
import 'package:financial_tracker/core/utils/date_formatter.dart';
import 'package:financial_tracker/providers/transaction_provider.dart';
import 'package:financial_tracker/providers/category_provider.dart';
import 'package:financial_tracker/providers/wallet_provider.dart';

/// Displays the most recent transactions on the home dashboard.
/// Reads directly from [TransactionProvider].
class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final transactions = txProvider.recentTransactions;

    if (txProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Text(
              'No transactions yet.\nTap + to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textHint, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: AppTheme.divider,
          ),
          itemBuilder: (context, index) {
            return _RecentTile(transaction: transactions[index]);
          },
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final dynamic transaction;

  const _RecentTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final walletProvider = context.watch<WalletProvider>();

    final isIncome = transaction.type == 1;
    final amountColor = isIncome ? AppTheme.income : AppTheme.expense;
    final sign = isIncome ? '+' : '-';

    // Resolve sub-category from cached provider data
    String name = 'Transaction';
    IconData icon = Icons.category_rounded;

    for (final entry in [
      ...categoryProvider.expenseCategoriesWithSubs.values,
      ...categoryProvider.incomeCategoriesWithSubs.values,
    ]) {
      for (final sub in entry) {
        if (sub.id == transaction.subCategoryId) {
          name = sub.name;
          icon = AppIcons.resolve(sub.icon);
          break;
        }
      }
    }

    final wallet = walletProvider.getWalletById(transaction.walletId);
    final walletName = wallet?.name ?? 'Unknown';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: amountColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: amountColor, size: 22),
      ),
      title: Text(
        name,
        style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14),
      ),
      subtitle: Text(
        '$walletName • ${DateFormatter.time(transaction.createdAt)}',
        style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
      ),
      trailing: Text(
        '$sign${CurrencyFormatter.format(transaction.amount)}',
        style: TextStyle(
            color: amountColor, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}
