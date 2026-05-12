import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/providers/settings_provider.dart';

/// Settings screen — user name, dark/light mode toggle.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final surfColor = isDark ? AppTheme.card : AppTheme.lightCard;
    final txtPrimary = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final txtSec = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),

            // Profile section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primary],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        settings.userName.isNotEmpty
                            ? settings.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(settings.userName, style: TextStyle(
                            color: txtPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Tap to edit your name', style: TextStyle(
                            color: txtSec, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_rounded, color: txtSec, size: 20),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showNameDialog(context, settings),
              // Wrap the container above in gesture detector by making the whole card tappable
              child: Container(
                // invisible overlay to catch taps
                height: 0,
              ),
            ),

            const SizedBox(height: 16),

            // Edit name tile
            _SettingsTile(
              icon: Icons.person_rounded,
              title: 'Edit Name',
              subtitle: settings.userName,
              surfColor: surfColor,
              txtPrimary: txtPrimary,
              txtSec: txtSec,
              onTap: () => _showNameDialog(context, settings),
            ),

            const SizedBox(height: 12),

            // Dark mode toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: surfColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                title: Text('Dark Mode', style: TextStyle(
                    color: txtPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15)),
                subtitle: Text(
                  isDark ? 'Currently using dark theme' : 'Currently using light theme',
                  style: TextStyle(color: txtSec, fontSize: 12),
                ),
                trailing: Switch.adaptive(
                  value: isDark,
                  onChanged: (_) => settings.toggleDarkMode(),
                  activeTrackColor: AppTheme.primary,
                  thumbColor: WidgetStatePropertyAll(Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App info
            Center(
              child: Column(
                children: [
                  Text('Financial Tracker',
                      style: TextStyle(
                          color: txtSec,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0',
                      style: TextStyle(
                          color: isDark ? AppTheme.textHint : AppTheme.lightTextHint,
                          fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showNameDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.userName);
    final isDark = settings.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Name', style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary)),
          ),
          TextButton(
            onPressed: () {
              settings.setUserName(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color surfColor;
  final Color txtPrimary;
  final Color txtSec;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.surfColor,
    required this.txtPrimary,
    required this.txtSec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surfColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                      color: txtPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15)),
                  Text(subtitle, style: TextStyle(color: txtSec, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: txtSec, size: 22),
          ],
        ),
      ),
    );
  }
}
