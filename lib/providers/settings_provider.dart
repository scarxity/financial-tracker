import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for app-wide settings: user name, theme mode, balance visibility.
class SettingsProvider extends ChangeNotifier {
  static const _keyName = 'user_name';
  static const _keyDarkMode = 'dark_mode';
  static const _keyBalanceVisible = 'balance_visible';

  String _userName = 'User';
  String get userName => _userName;

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  bool _isBalanceVisible = true;
  bool get isBalanceVisible => _isBalanceVisible;

  /// Initialize from SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_keyName) ?? 'User';
    _isDarkMode = prefs.getBool(_keyDarkMode) ?? true;
    _isBalanceVisible = prefs.getBool(_keyBalanceVisible) ?? true;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim().isEmpty ? 'User' : name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, _userName);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }
}
