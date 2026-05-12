import 'package:flutter/material.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/core/utils/currency_formatter.dart';

class WalletCard extends StatelessWidget {
  final String name;
  final double balance;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const WalletCard({
    super.key,
    required this.name,
    required this.balance,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(CurrencyFormatter.format(balance), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 24),
          ],
        ),
      ),
    );
  }
}
