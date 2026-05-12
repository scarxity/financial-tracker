import 'package:flutter/material.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';

/// Date section header for grouped transaction lists.
class DateGroupHeader extends StatelessWidget {
  final String label;

  const DateGroupHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: AppTheme.divider,
            ),
          ),
        ],
      ),
    );
  }
}
