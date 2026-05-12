import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_tracker/core/constants/app_constants.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/core/utils/date_formatter.dart';
import 'package:financial_tracker/data/models/transaction.dart';
import 'package:financial_tracker/data/models/sub_category.dart';
import 'package:financial_tracker/providers/transaction_provider.dart';
import 'package:financial_tracker/providers/category_provider.dart';
import 'package:financial_tracker/providers/wallet_provider.dart';
import 'package:financial_tracker/screens/transactions/widgets/transaction_tile.dart';
import 'package:financial_tracker/screens/transactions/widgets/date_group_header.dart';
import 'package:financial_tracker/screens/transactions/report_screen.dart';
import 'package:financial_tracker/screens/add_transaction/add_transaction_screen.dart';

enum PeriodMode { day, week, month, year }

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});
  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  int _filterType = 0; // 0=All, 1=Income, 2=Expense
  PeriodMode _periodMode = PeriodMode.month;
  late PageController _pageController;
  late int _currentPage;
  int? _filterCategoryId;

  @override
  void initState() {
    super.initState();
    _currentPage = 500; // start in middle for infinite-like scrolling
    _pageController = PageController(initialPage: _currentPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Get the date range for a given page offset from "current" (page 500).
  DateTimeRange _rangeForPage(int page) {
    final offset = page - 500;
    final now = DateTime.now();
    switch (_periodMode) {
      case PeriodMode.day:
        final d = now.add(Duration(days: offset));
        return DateTimeRange(
          start: DateTime(d.year, d.month, d.day),
          end: DateTime(d.year, d.month, d.day, 23, 59, 59),
        );
      case PeriodMode.week:
        final thisMonday = now.subtract(Duration(days: now.weekday - 1));
        final monday = thisMonday.add(Duration(days: offset * 7));
        return DateTimeRange(
          start: DateTime(monday.year, monday.month, monday.day),
          end: DateTime(monday.year, monday.month, monday.day + 6, 23, 59, 59),
        );
      case PeriodMode.month:
        final m = DateTime(now.year, now.month + offset, 1);
        final end = DateTime(m.year, m.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: m, end: end);
      case PeriodMode.year:
        final y = DateTime(now.year + offset, 1, 1);
        return DateTimeRange(
          start: y,
          end: DateTime(y.year, 12, 31, 23, 59, 59),
        );
    }
  }

  String _labelForPage(int page) {
    final range = _rangeForPage(page);
    final s = range.start;
    switch (_periodMode) {
      case PeriodMode.day:
        return DateFormatter.relative(s);
      case PeriodMode.week:
        return '${DateFormatter.shortDate(s)} – ${DateFormatter.shortDate(range.end)}';
      case PeriodMode.month:
        return DateFormatter.monthYear(s);
      case PeriodMode.year:
        return '${s.year}';
    }
  }

  List<FinancialTransaction> _filterTransactions(
      List<FinancialTransaction> all, DateTimeRange range) {
    var filtered = all.where((t) =>
        !t.createdAt.isBefore(range.start) &&
        !t.createdAt.isAfter(range.end)).toList();
    if (_filterType == 1) filtered = filtered.where((t) => t.type == 1).toList();
    if (_filterType == 2) filtered = filtered.where((t) => t.type == 0).toList();
    if (_filterCategoryId != null) {
      filtered = filtered.where((t) => t.subCategoryId == _filterCategoryId).toList();
    }
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txtSec = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text('Transactions', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Period mode selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceVariant : AppTheme.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: PeriodMode.values.map((m) {
                  final sel = _periodMode == m;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _periodMode = m;
                        _currentPage = 500;
                        _pageController.jumpToPage(500);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          m.name[0].toUpperCase() + m.name.substring(1),
                          style: TextStyle(
                            color: sel ? Colors.white : txtSec,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Period navigator (swipeable)
          SizedBox(
            height: 40,
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: txtSec),
                  onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut),
                  splashRadius: 20,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    itemBuilder: (_, i) => Center(
                      child: Text(
                        _labelForPage(i),
                        style: TextStyle(
                          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: txtSec),
                  onPressed: () {
                    if (_currentPage < 500) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  },
                  splashRadius: 20,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Type filter chips + category + report
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _Chip(label: 'All', sel: _filterType == 0,
                    onTap: () => setState(() => _filterType = 0)),
                const SizedBox(width: 6),
                _Chip(label: 'Income', sel: _filterType == 1, color: AppTheme.income,
                    onTap: () => setState(() => _filterType = 1)),
                const SizedBox(width: 6),
                _Chip(label: 'Expense', sel: _filterType == 2, color: AppTheme.expense,
                    onTap: () => setState(() => _filterType = 2)),
                const Spacer(),
                // Category filter
                GestureDetector(
                  onTap: () => _showCategoryFilter(context, catProvider),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _filterCategoryId != null
                          ? AppTheme.primary.withValues(alpha: 0.15)
                          : (isDark ? AppTheme.surfaceVariant : AppTheme.lightSurfaceVariant),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.category_rounded,
                        color: _filterCategoryId != null ? AppTheme.primary : txtSec,
                        size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Report button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                final range = _rangeForPage(_currentPage);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ReportScreen(
                    dateRange: range,
                    periodLabel: _labelForPage(_currentPage),
                  ),
                ));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_rounded, color: AppTheme.primary, size: 16),
                    SizedBox(width: 6),
                    Text('View Report', style: TextStyle(
                        color: AppTheme.primary, fontSize: 1te3, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Transaction list
          Expanded(
            child: txProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildList(txProvider, catProvider, walletProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildList(TransactionProvider txProvider,
      CategoryProvider catProvider, WalletProvider walletProvider) {
    final range = _rangeForPage(_currentPage);
    final filtered = _filterTransactions(txProvider.transactions, range);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.textHint : AppTheme.lightTextHint),
            const SizedBox(height: 16),
            Text('No transactions', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    // Group by date
    final Map<DateTime, List<FinancialTransaction>> grouped = {};
    for (final tx in filtered) {
      final key = DateFormatter.dateOnly(tx.createdAt);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final items = <_ListItem>[];
    for (final key in sortedKeys) {
      items.add(_ListItem(isHeader: true, date: key));
      for (final tx in grouped[key]!) {
        items.add(_ListItem(transaction: tx));
      }
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) return const SizedBox(height: 100);
        final item = items[index];
        if (item.isHeader) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DateGroupHeader(label: DateFormatter.relative(item.date!)),
          );
        }
        return _buildTile(context, item.transaction!, catProvider, walletProvider);
      },
    );
  }

  Widget _buildTile(BuildContext context, FinancialTransaction tx,
      CategoryProvider catProvider, WalletProvider walletProvider) {
    String name = 'Transaction';
    String iconName = 'category';
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
    final wallet = walletProvider.getWalletById(tx.walletId);
    return TransactionTile(
      subCategoryName: name,
      icon: AppIcons.resolve(iconName),
      amount: tx.amount,
      isIncome: tx.type == 1,
      walletName: wallet?.name ?? 'Unknown',
      time: DateFormatter.time(tx.createdAt),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => AddTransactionScreen(transaction: tx),
        ));
        if (context.mounted) {
          context.read<TransactionProvider>().loadTransactions();
          context.read<WalletProvider>().loadWallets();
        }
      },
    );
  }

  void _showCategoryFilter(BuildContext context, CategoryProvider catProvider) {
    final allSubs = <SubCategory>[];
    for (final subs in catProvider.expenseCategoriesWithSubs.values) {
      allSubs.addAll(subs);
    }
    for (final subs in catProvider.incomeCategoriesWithSubs.values) {
      allSubs.addAll(subs);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.surface : AppTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
                color: AppTheme.textHint, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Filter by Category', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.select_all_rounded, color: AppTheme.primary),
              title: Text('All Categories', style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.textPrimary : AppTheme.lightTextPrimary)),
              trailing: _filterCategoryId == null
                  ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary) : null,
              onTap: () { setState(() => _filterCategoryId = null); Navigator.pop(ctx); },
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allSubs.length,
                itemBuilder: (_, i) {
                  final sub = allSubs[i];
                  return ListTile(
                    leading: Icon(AppIcons.resolve(sub.icon), color: AppTheme.primary),
                    title: Text(sub.name, style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textPrimary : AppTheme.lightTextPrimary)),
                    trailing: _filterCategoryId == sub.id
                        ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary) : null,
                    onTap: () { setState(() => _filterCategoryId = sub.id); Navigator.pop(ctx); },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListItem {
  final bool isHeader;
  final DateTime? date;
  final FinancialTransaction? transaction;
  _ListItem({this.isHeader = false, this.date, this.transaction});
}

class _Chip extends StatelessWidget {
  final String label;
  final bool sel;
  final Color? color;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.sel, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? c.withValues(alpha: 0.15) : (isDark ? AppTheme.card : AppTheme.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? c : (isDark ? AppTheme.divider : AppTheme.lightDivider)),
        ),
        child: Text(label, style: TextStyle(
          color: sel ? c : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
          fontWeight: sel ? FontWeight.w600 : FontWeight.w400, fontSize: 13,
        )),
      ),
    );
  }
}
