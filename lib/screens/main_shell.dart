import 'package:flutter/material.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/screens/home/home_screen.dart';
import 'package:financial_tracker/screens/transactions/transaction_list_screen.dart';
import 'package:financial_tracker/screens/wallet/wallet_screen.dart';
import 'package:financial_tracker/screens/add_transaction/add_transaction_screen.dart';

/// Main shell with bottom navigation bar, 3 tabs, and a center FAB.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TransactionListScreen(),
    WalletScreen(),
  ];

  void _onTabTapped(int index) {
    // Index 2 is the dummy center placeholder — skip it
    if (index == 2) return;
    setState(() {
      // Map visual indices: 0→0, 1→1, 3→2 (skip center)
      if (index < 2) {
        _currentIndex = index;
      } else {
        _currentIndex = index - 1;
      }
    });
  }

  int get _navIndex {
    // Reverse mapping: screen 0→0, 1→1, 2→3
    if (_currentIndex < 2) return _currentIndex;
    return _currentIndex + 1;
  }

  void _openAddTransaction() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddTransactionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _navIndex,
              onTap: _onTabTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: AppTheme.textSecondary,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Transactions',
                ),
                // Dummy center item — FAB sits on top
                BottomNavigationBarItem(
                  icon: SizedBox.shrink(),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_rounded),
                  activeIcon: Icon(Icons.account_balance_wallet_rounded),
                  label: 'Wallets',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryLight, AppTheme.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openAddTransaction,
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
