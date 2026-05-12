import 'package:flutter/material.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/screens/main_shell.dart';

/// Root MaterialApp widget with theme and route configuration.
class FinancialTrackerApp extends StatelessWidget {
  const FinancialTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}
