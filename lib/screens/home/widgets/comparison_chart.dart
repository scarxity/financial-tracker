import 'package:flutter/material.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/core/utils/currency_formatter.dart';
import 'dart:math' as math;

/// Comparison chart widget — shows two bar groups side-by-side
/// comparing "last period" vs "this period" for income/expense.
class ComparisonChart extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final double leftIncome;
  final double leftExpense;
  final double rightIncome;
  final double rightExpense;

  const ComparisonChart({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftIncome,
    required this.leftExpense,
    required this.rightIncome,
    required this.rightExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(
            children: [
              _LegendDot(color: AppTheme.income, label: 'Income'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.expense, label: 'Expense'),
            ],
          ),
          const SizedBox(height: 20),

          // Bars
          SizedBox(
            height: 140,
            child: Row(
              children: [
                Expanded(
                  child: _BarGroup(
                    label: leftLabel,
                    income: leftIncome,
                    expense: leftExpense,
                    maxValue: _maxVal,
                  ),
                ),
                const SizedBox(width: 16),
                // Divider line
                Container(
                  width: 1,
                  height: 120,
                  color: AppTheme.divider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _BarGroup(
                    label: rightLabel,
                    income: rightIncome,
                    expense: rightExpense,
                    maxValue: _maxVal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double get _maxVal {
    final all = [leftIncome, leftExpense, rightIncome, rightExpense];
    final m = all.reduce(math.max);
    return m == 0 ? 1 : m;
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _BarGroup extends StatelessWidget {
  final String label;
  final double income;
  final double expense;
  final double maxValue;

  const _BarGroup({
    required this.label,
    required this.income,
    required this.expense,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final incomeRatio = (income / maxValue).clamp(0.0, 1.0);
    final expenseRatio = (expense / maxValue).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Amounts on top
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                CurrencyFormatter.compact(income),
                style: const TextStyle(
                    color: AppTheme.income,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                CurrencyFormatter.compact(expense),
                style: const TextStyle(
                    color: AppTheme.expense,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Bars
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AnimatedBar(
                  color: AppTheme.income,
                  ratio: incomeRatio),
              const SizedBox(width: 6),
              _AnimatedBar(
                  color: AppTheme.expense,
                  ratio: expenseRatio),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Period label
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final Color color;
  final double ratio;

  const _AnimatedBar({required this.color, required this.ratio});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      width: 24,
      height: math.max(4, ratio * 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            color.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
