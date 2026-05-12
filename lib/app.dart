import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/providers/settings_provider.dart';
import 'package:financial_tracker/screens/main_shell.dart';

/// Root MaterialApp widget with theme and route configuration.
class FinancialTrackerApp extends StatelessWidget {
  const FinancialTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Financial Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainShell(),
    );
  }
}
