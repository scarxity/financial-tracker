import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_tracker/core/constants/app_constants.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/core/utils/currency_formatter.dart';
import 'package:financial_tracker/providers/transaction_provider.dart';
import 'package:financial_tracker/providers/category_provider.dart';

/// Report screen showing pie charts for expense and income breakdown.
class ReportScreen extends StatelessWidget {
  final DateTimeRange dateRange;
  final String periodLabel;

  const ReportScreen({
    super.key,
    required this.dateRange,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Gather transactions in range
    final txns = txProvider.transactions.where((t) =>
        !t.createdAt.isBefore(dateRange.start) &&
        !t.createdAt.isAfter(dateRange.end)).toList();

    // Build category breakdowns
    final expenseMap = <String, double>{};
    final incomeMap = <String, double>{};
    final expenseIconMap = <String, String>{};
    final incomeIconMap = <String, String>{};

    for (final tx in txns) {
      String name = 'Other';
      String iconName = 'other';
      for (final entry in [
        ...catProvider.expenseCategoriesWithSubs.values,
        ...catProvider.incomeCategoriesWithSubs.values,
      ]) {
        for (final sub in entry) {
          if (sub.id == tx.subCategoryId) {
            name = sub.name;
            iconName = sub.icon;
            break;
          }
        }
      }
      if (tx.type == 0) {
        expenseMap[name] = (expenseMap[name] ?? 0) + tx.amount;
        expenseIconMap[name] = iconName;
      } else {
        incomeMap[name] = (incomeMap[name] ?? 0) + tx.amount;
        incomeIconMap[name] = iconName;
      }
    }

    final totalExpense = expenseMap.values.fold(0.0, (a, b) => a + b);
    final totalIncome = incomeMap.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.background : AppTheme.lightBackground,
      appBar: AppBar(
        title: Text('Report — $periodLabel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Expense pie
            _PieSection(
              title: 'Spending',
              total: totalExpense,
              data: expenseMap,
              iconMap: expenseIconMap,
              baseColor: AppTheme.expense,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            // Income pie
            _PieSection(
              title: 'Income',
              total: totalIncome,
              data: incomeMap,
              iconMap: incomeIconMap,
              baseColor: AppTheme.income,
              isDark: isDark,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PieSection extends StatelessWidget {
  final String title;
  final double total;
  final Map<String, double> data;
  final Map<String, String> iconMap;
  final Color baseColor;
  final bool isDark;

  const _PieSection({
    required this.title,
    required this.total,
    required this.data,
    required this.iconMap,
    required this.baseColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.card : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: baseColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  title == 'Spending'
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: baseColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                    fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(CurrencyFormatter.format(total), style: TextStyle(
                    color: baseColor, fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pie chart
          if (sorted.isEmpty)
            SizedBox(
              height: 160,
              child: Center(
                child: Text('No data', style: TextStyle(
                    color: isDark ? AppTheme.textHint : AppTheme.lightTextHint)),
              ),
            )
          else
            SizedBox(
              height: 180,
              width: 180,
              child: CustomPaint(
                painter: _PieChartPainter(
                  values: sorted.map((e) => e.value).toList(),
                  baseColor: baseColor,
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Legend
          ...sorted.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final pct = total > 0 ? (e.value / total * 100) : 0.0;
            final color = _sliceColor(baseColor, i, sorted.length);
            final iconName = iconMap[e.key] ?? 'other';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(AppIcons.resolve(iconName), size: 16,
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(e.key, style: TextStyle(
                      color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                      fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  Text('${pct.toStringAsFixed(1)}%', style: TextStyle(
                    color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                    fontSize: 12)),
                  const SizedBox(width: 8),
                  Text(CurrencyFormatter.compact(e.value), style: TextStyle(
                    color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                    fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

Color _sliceColor(Color base, int index, int total) {
  final hsl = HSLColor.fromColor(base);
  final shift = (index * 35.0) % 360;
  return hsl.withHue((hsl.hue + shift) % 360)
      .withLightness((hsl.lightness + index * 0.04).clamp(0.3, 0.75))
      .toColor();
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final Color baseColor;

  _PieChartPainter({required this.values, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final holeRect = Rect.fromCircle(center: center, radius: radius * 0.55);

    double startAngle = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * math.pi;
      final color = _sliceColor(baseColor, i, values.length);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }

    // Center hole (donut)
    final holePaint = Paint()..color = Colors.transparent;
    canvas.drawCircle(center, radius * 0.55, holePaint);
    // We draw the hole by painting over with background
    // Instead, use a path approach:
    final holePath = Path()
      ..addOval(holeRect);
    canvas.drawPath(holePath, Paint()..color = baseColor.withValues(alpha: 0.0)
        ..blendMode = BlendMode.clear);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
