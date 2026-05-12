import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_tracker/core/constants/app_constants.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/core/utils/date_formatter.dart';
import 'package:financial_tracker/data/models/transaction.dart';
import 'package:financial_tracker/providers/transaction_provider.dart';
import 'package:financial_tracker/providers/category_provider.dart';
import 'package:financial_tracker/providers/wallet_provider.dart';
import 'package:financial_tracker/screens/transactions/widgets/transaction_tile.dart';
import 'package:financial_tracker/screens/transactions/widgets/date_group_header.dart';
import 'package:financial_tracker/screens/add_transaction/add_transaction_screen.dart';

/// Full transaction list screen — wired to TransactionProvider.
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  int _filterType = 0; // 0=All, 1=Income, 2=Expense

  // Filter state
  DateTimeRange? _dateRange;
  int? _filterWalletId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final walletProvider = context.watch<WalletProvider>();

    // Apply local filters
    final grouped = txProvider.groupedByDate;
    Map<DateTime, List<FinancialTransaction>> filteredGrouped = {};

    for (final entry in grouped.entries) {
      List<FinancialTransaction> filtered = entry.value;

      // Filter by type
      if (_filterType != 0) {
        final targetType = _filterType == 1 ? 1 : 0;
        filtered = filtered.where((t) => t.type == targetType).toList();
      }

      // Filter by wallet
      if (_filterWalletId != null) {
        filtered = filtered
            .where((t) => t.walletId == _filterWalletId)
            .toList();
      }

      // Filter by date range
      if (_dateRange != null) {
        final start = DateFormatter.dateOnly(_dateRange!.start);
        final end = DateFormatter.dateOnly(_dateRange!.end)
            .add(const Duration(days: 1));
        filtered = filtered.where((t) {
          return t.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
              t.createdAt.isBefore(end);
        }).toList();
      }

      if (filtered.isNotEmpty) {
        filteredGrouped[entry.key] = filtered;
      }
    }

    final hasActiveFilters = _dateRange != null || _filterWalletId != null;

    return SafeArea(
      child: Column(
        children: [
          // ─── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                if (hasActiveFilters)
                  GestureDetector(
                    onTap: () => setState(() {
                      _dateRange = null;
                      _filterWalletId = null;
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.expense.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close_rounded,
                              color: AppTheme.expense, size: 14),
                          SizedBox(width: 4),
                          Text('Clear',
                              style: TextStyle(
                                  color: AppTheme.expense,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: hasActiveFilters
                        ? AppTheme.primary.withValues(alpha: 0.15)
                        : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: hasActiveFilters
                        ? Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list_rounded,
                        color: hasActiveFilters
                            ? AppTheme.primary
                            : AppTheme.textSecondary),
                    onPressed: () =>
                        _showFilterSheet(context, walletProvider),
                  ),
                ),
              ],
            ),
          ),

          // ─── Active filter badges ───────────────────────
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_dateRange != null)
                      _ActiveFilterBadge(
                        label:
                            '${DateFormatter.shortDate(_dateRange!.start)} – ${DateFormatter.shortDate(_dateRange!.end)}',
                        onRemove: () =>
                            setState(() => _dateRange = null),
                      ),
                    if (_filterWalletId != null) ...[
                      if (_dateRange != null) const SizedBox(width: 8),
                      _ActiveFilterBadge(
                        label: walletProvider
                                .getWalletById(_filterWalletId!)
                                ?.name ??
                            'Wallet',
                        onRemove: () =>
                            setState(() => _filterWalletId = null),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // ─── Type Filter Chips ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                    label: 'All',
                    isSelected: _filterType == 0,
                    onTap: () => setState(() => _filterType = 0)),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'Income',
                    isSelected: _filterType == 1,
                    onTap: () => setState(() => _filterType = 1),
                    color: AppTheme.income),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'Expense',
                    isSelected: _filterType == 2,
                    onTap: () => setState(() => _filterType = 2),
                    color: AppTheme.expense),
              ],
            ),
          ),

          // ─── Transaction List ───────────────────────────
          Expanded(
            child: txProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredGrouped.isEmpty
                    ? _EmptyState(filterType: _filterType)
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _countItems(filteredGrouped) + 1,
                        itemBuilder: (context, index) {
                          return _buildItem(
                            context,
                            index,
                            filteredGrouped,
                            categoryProvider,
                            walletProvider,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// Total items = date headers + transactions
  int _countItems(Map<DateTime, List<FinancialTransaction>> grouped) {
    int count = 0;
    for (final entry in grouped.entries) {
      count += 1 + entry.value.length; // 1 header + N tiles
    }
    return count;
  }

  Widget _buildItem(
    BuildContext context,
    int globalIndex,
    Map<DateTime, List<FinancialTransaction>> grouped,
    CategoryProvider categoryProvider,
    WalletProvider walletProvider,
  ) {
    if (globalIndex == _countItems(grouped)) {
      return const SizedBox(height: 100);
    }

    int cursor = 0;
    for (final entry in grouped.entries) {
      if (globalIndex == cursor) {
        // This is a date header
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: DateGroupHeader(
              label: DateFormatter.relative(entry.key)),
        );
      }
      cursor++;
      for (final tx in entry.value) {
        if (globalIndex == cursor) {
          return _buildTransactionTile(
              context, tx, categoryProvider, walletProvider);
        }
        cursor++;
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildTransactionTile(
    BuildContext context,
    FinancialTransaction tx,
    CategoryProvider categoryProvider,
    WalletProvider walletProvider,
  ) {
    // Resolve sub-category name + icon
    String subCategoryName = 'Transaction';
    String subCategoryIcon = 'category';

    for (final entry in [
      ...categoryProvider.expenseCategoriesWithSubs.values,
      ...categoryProvider.incomeCategoriesWithSubs.values,
    ]) {
      for (final sub in entry) {
        if (sub.id == tx.subCategoryId) {
          subCategoryName = sub.name;
          subCategoryIcon = sub.icon;
          break;
        }
      }
    }

    final wallet = walletProvider.getWalletById(tx.walletId);
    final walletName = wallet?.name ?? 'Unknown';

    return TransactionTile(
      subCategoryName: subCategoryName,
      icon: AppIcons.resolve(subCategoryIcon),
      amount: tx.amount,
      isIncome: tx.type == 1,
      walletName: walletName,
      time: DateFormatter.time(tx.createdAt),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(transaction: tx),
          ),
        );
        if (context.mounted) {
          context.read<TransactionProvider>().loadTransactions();
          context.read<WalletProvider>().loadWallets();
        }
      },
    );
  }

  void _showFilterSheet(BuildContext context, WalletProvider walletProvider) {
    // Local copies for the sheet
    DateTimeRange? tempDateRange = _dateRange;
    int? tempWalletId = _filterWalletId;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final walletName = tempWalletId != null
                ? walletProvider.getWalletById(tempWalletId!)?.name ??
                    'Unknown'
                : 'All wallets';

            String dateLabel = 'All time';
            if (tempDateRange != null) {
              dateLabel =
                  '${DateFormatter.shortDate(tempDateRange!.start)} – ${DateFormatter.shortDate(tempDateRange!.end)}';
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textHint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Filter Transactions',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),

                  // Date Range
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.date_range_rounded,
                          color: AppTheme.primary, size: 20),
                    ),
                    title: const Text('Date Range',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500)),
                    subtitle: Text(dateLabel,
                        style:
                            const TextStyle(color: AppTheme.textHint)),
                    trailing: tempDateRange != null
                        ? GestureDetector(
                            onTap: () => setSheetState(
                                () => tempDateRange = null),
                            child: const Icon(Icons.close_rounded,
                                color: AppTheme.textHint, size: 18),
                          )
                        : const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textHint),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: tempDateRange,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppTheme.primary,
                              surface: AppTheme.surface,
                              onPrimary: Colors.white,
                              onSurface: AppTheme.textPrimary,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setSheetState(() => tempDateRange = picked);
                      }
                    },
                  ),
                  const Divider(color: AppTheme.divider),

                  // Wallet
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppTheme.primary,
                          size: 20),
                    ),
                    title: const Text('Wallet',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500)),
                    subtitle: Text(walletName,
                        style:
                            const TextStyle(color: AppTheme.textHint)),
                    trailing: tempWalletId != null
                        ? GestureDetector(
                            onTap: () =>
                                setSheetState(() => tempWalletId = null),
                            child: const Icon(Icons.close_rounded,
                                color: AppTheme.textHint, size: 18),
                          )
                        : const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textHint),
                    onTap: () {
                      _showWalletFilterPicker(
                        ctx,
                        walletProvider,
                        tempWalletId,
                        (id) => setSheetState(() => tempWalletId = id),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _dateRange = tempDateRange;
                          _filterWalletId = tempWalletId;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply Filters',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showWalletFilterPicker(
    BuildContext context,
    WalletProvider walletProvider,
    int? currentWalletId,
    void Function(int?) onSelect,
  ) {
    final wallets = walletProvider.wallets;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.textHint,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Select Wallet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // "All wallets" option
            ListTile(
              leading: const Icon(Icons.select_all_rounded,
                  color: AppTheme.primary),
              title: const Text('All Wallets',
                  style: TextStyle(color: AppTheme.textPrimary)),
              trailing: currentWalletId == null
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppTheme.primary)
                  : null,
              onTap: () {
                onSelect(null);
                Navigator.pop(ctx);
              },
            ),
            ...wallets.map((w) => ListTile(
                  leading: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppTheme.primary),
                  title: Text(w.name,
                      style:
                          const TextStyle(color: AppTheme.textPrimary)),
                  trailing: currentWalletId == w.id
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primary)
                      : null,
                  onTap: () {
                    onSelect(w.id);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int filterType;
  const _EmptyState({required this.filterType});

  @override
  Widget build(BuildContext context) {
    final label = filterType == 0
        ? 'No transactions yet'
        : filterType == 1
            ? 'No income transactions'
            : 'No expense transactions';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Tap + to add a transaction',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip(
      {required this.label,
      required this.isSelected,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.15)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppTheme.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? chipColor : AppTheme.textSecondary,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterBadge extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterBadge(
      {required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                color: AppTheme.primary, size: 14),
          ),
        ],
      ),
    );
  }
}
