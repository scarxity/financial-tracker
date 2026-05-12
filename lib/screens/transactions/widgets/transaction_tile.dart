import 'package:flutter/material.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/core/utils/currency_formatter.dart';

/// A single transaction row used in lists.
class TransactionTile extends StatelessWidget {
  final String subCategoryName;
  final IconData icon;
  final double amount;
  final bool isIncome;
  final String walletName;
  final String time;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.subCategoryName,
    required this.icon,
    required this.amount,
    required this.isIncome,
    required this.walletName,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isIncome ? AppTheme.income : AppTheme.expense;
    final sign = isIncome ? '+' : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.card : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),

            // Name + wallet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subCategoryName,
                    style: TextStyle(
                      color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$walletName • $time',
                    style: TextStyle(
                      color: isDark ? AppTheme.textHint : AppTheme.lightTextHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '$sign${CurrencyFormatter.format(amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.chevron_right_rounded,
                    color: isDark ? AppTheme.textHint : AppTheme.lightTextHint, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
