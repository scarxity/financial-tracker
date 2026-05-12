import 'package:flutter/material.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/core/utils/currency_formatter.dart';
import 'dart:math' as math;

/// Expense comparison chart — shows two bars side-by-side
/// comparing "last period" vs "this period" spending.
class ComparisonChart extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final double leftExpense;
  final double rightExpense;

  const ComparisonChart({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftExpense,
    required this.rightExpense,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxVal = math.max(leftExpense, rightExpense);
    final safeMax = maxVal == 0 ? 1.0 : maxVal;
    final leftRatio = (leftExpense / safeMax).clamp(0.0, 1.0);
    final rightRatio = (rightExpense / safeMax).clamp(0.0, 1.0);

    // Determine change percentage
    String changeText = '';
    Color changeColor = AppTheme.textSecondary;
    IconData changeIcon = Icons.remove_rounded;
    if (leftExpense > 0) {
      final pct = ((rightExpense - leftExpense) / leftExpense * 100);
      if (pct > 0) {
        changeText = '+${pct.toStringAsFixed(0)}%';
        changeColor = AppTheme.expense;
        changeIcon = Icons.trending_up_rounded;
      } else if (pct < 0) {
        changeText = '${pct.toStringAsFixed(0)}%';
        changeColor = AppTheme.income;
        changeIcon = Icons.trending_down_rounded;
      } else {
        changeText = '0%';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.card : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  color: AppTheme.expense.withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 8),
              Text(
                'Spending Comparison',
                style: TextStyle(
                  color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (changeText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(changeIcon, color: changeColor, size: 14),
                      const SizedBox(width: 2),
                      Text(changeText,
                          style: TextStyle(
                              color: changeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Bars side by side
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: _ExpenseBar(
                    label: leftLabel,
                    amount: leftExpense,
                    ratio: leftRatio,
                    isDark: isDark,
                    isHighlighted: false,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _ExpenseBar(
                    label: rightLabel,
                    amount: rightExpense,
                    ratio: rightRatio,
                    isDark: isDark,
                    isHighlighted: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseBar extends StatelessWidget {
  final String label;
  final double amount;
  final double ratio;
  final bool isDark;
  final bool isHighlighted;

  const _ExpenseBar({
    required this.label,
    required this.amount,
    required this.ratio,
    required this.isDark,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = isHighlighted
        ? AppTheme.expense
        : AppTheme.expense.withValues(alpha: 0.4);
    final bgColor = isDark
        ? AppTheme.surfaceVariant
        : AppTheme.lightSurfaceVariant;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Amount
        Text(
          CurrencyFormatter.compact(amount),
          style: TextStyle(
            color: isHighlighted
                ? AppTheme.expense
                : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),

        // Bar with background track
        Expanded(
          child: Container(
            width: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                width: 48,
                height: math.max(8, ratio * 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      barColor,
                      barColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isHighlighted
                      ? [
                          BoxShadow(
                            color: AppTheme.expense.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Label
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
            fontSize: 12,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
