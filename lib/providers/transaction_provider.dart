import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';

/// [ChangeNotifier] that exposes transaction state to the widget tree.
///
/// Manages the full transaction list, recent transactions for the
/// home dashboard, and income/expense summaries by period.
class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionProvider(this._repository);

  // ─── State ──────────────────────────────────────────────────

  List<FinancialTransaction> _transactions = [];
  List<FinancialTransaction> get transactions => _transactions;

  List<FinancialTransaction> _recentTransactions = [];
  List<FinancialTransaction> get recentTransactions => _recentTransactions;

  double _totalIncome = 0;
  double get totalIncome => _totalIncome;

  double _totalExpense = 0;
  double get totalExpense => _totalExpense;

  double get netBalance => _totalIncome - _totalExpense;

  SummaryPeriod _selectedPeriod = SummaryPeriod.month;
  SummaryPeriod get selectedPeriod => _selectedPeriod;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Active filters ──
  int? _filterWalletId;
  int? get filterWalletId => _filterWalletId;

  int? _filterType; // 0 = expense, 1 = income
  int? get filterType => _filterType;

  // ─── Load / Refresh ─────────────────────────────────────────

  /// Load all transactions and summary data.
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _fetchFiltered();
      _recentTransactions = await _repository.getRecent(limit: 10);
      await _loadSummary();
      await _loadComparisonSummary();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch transactions respecting the active filters.
  Future<List<FinancialTransaction>> _fetchFiltered() async {
    if (_filterWalletId != null) {
      final byWallet = await _repository.getByWalletId(_filterWalletId!);
      if (_filterType != null) {
        return byWallet.where((t) => t.type == _filterType).toList();
      }
      return byWallet;
    }
    if (_filterType != null) {
      return _repository.getByType(_filterType!);
    }
    return _repository.getAll();
  }

  /// Load the income / expense summary for the selected period.
  Future<void> _loadSummary() async {
    DateTime? start;
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedPeriod) {
      case SummaryPeriod.week:
        start = DateFormatter.startOfWeek();
        break;
      case SummaryPeriod.month:
        start = DateFormatter.startOfMonth();
        break;
      case SummaryPeriod.all:
        start = null;
        break;
    }

    final summary = await _repository.getSummary(start: start, end: end);
    _totalIncome = summary['income'] ?? 0;
    _totalExpense = summary['expense'] ?? 0;
  }

  // ─── Period Toggle ──────────────────────────────────────────

  /// Change the summary period and reload summary data.
  Future<void> setPeriod(SummaryPeriod period) async {
    _selectedPeriod = period;
    await _loadSummary();
    await _loadComparisonSummary();
    notifyListeners();
  }

  // ─── Filters ────────────────────────────────────────────────

  /// Set the wallet filter. Pass `null` to clear.
  Future<void> setWalletFilter(int? walletId) async {
    _filterWalletId = walletId;
    await loadTransactions();
  }

  /// Set the type filter (0 = expense, 1 = income). Pass `null` to clear.
  Future<void> setTypeFilter(int? type) async {
    _filterType = type;
    await loadTransactions();
  }

  /// Clear all active filters.
  Future<void> clearFilters() async {
    _filterWalletId = null;
    _filterType = null;
    await loadTransactions();
  }

  // ─── Mutations ──────────────────────────────────────────────

  /// Add a new transaction and refresh state.
  Future<int> addTransaction(FinancialTransaction txn) async {
    final id = await _repository.addTransaction(txn);
    await loadTransactions();
    return id;
  }

  /// Update an existing transaction and refresh state.
  Future<void> updateTransaction(FinancialTransaction txn) async {
    await _repository.updateTransaction(txn);
    await loadTransactions();
  }

  /// Delete a transaction by [id] and refresh state.
  Future<bool> deleteTransaction(int id) async {
    final deleted = await _repository.deleteTransaction(id);
    if (deleted) await loadTransactions();
    return deleted;
  }

  /// Delete all transactions for a wallet (used on wallet deletion).
  Future<void> deleteByWalletId(int walletId) async {
    await _repository.deleteByWalletId(walletId);
    await loadTransactions();
  }

  // ─── Grouping Helpers ───────────────────────────────────────

  /// Group current transactions by date for the transaction list screen.
  /// Returns a map with date keys sorted descending.
  Map<DateTime, List<FinancialTransaction>> get groupedByDate {
    final Map<DateTime, List<FinancialTransaction>> grouped = {};

    for (final txn in _transactions) {
      final dateKey = DateFormatter.dateOnly(txn.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(txn);
    }

    // Sort keys descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return {for (final key in sortedKeys) key: grouped[key]!};
  }
  // ─── Comparison Period Summaries ─────────────────────────────

  double _prevIncome = 0;
  double get prevIncome => _prevIncome;

  double _prevExpense = 0;
  double get prevExpense => _prevExpense;

  /// Get the summary for the previous period (for comparison charts).
  /// Called automatically when the period changes.
  Future<void> _loadComparisonSummary() async {
    final now = DateTime.now();
    DateTime prevStart;
    DateTime prevEnd;

    switch (_selectedPeriod) {
      case SummaryPeriod.week:
        // Last week: previous Monday to Sunday
        final thisMonday = now.subtract(Duration(days: now.weekday - 1));
        final lastMonday = thisMonday.subtract(const Duration(days: 7));
        prevStart = DateTime(lastMonday.year, lastMonday.month, lastMonday.day);
        prevEnd = DateTime(thisMonday.year, thisMonday.month, thisMonday.day)
            .subtract(const Duration(seconds: 1));
        break;
      case SummaryPeriod.month:
        // Last month
        final firstOfThisMonth = DateTime(now.year, now.month, 1);
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        prevStart = lastMonth;
        prevEnd = firstOfThisMonth.subtract(const Duration(seconds: 1));
        break;
      case SummaryPeriod.all:
        // No comparison for "all time"
        _prevIncome = 0;
        _prevExpense = 0;
        return;
    }

    final summary = await _repository.getSummary(start: prevStart, end: prevEnd);
    _prevIncome = summary['income'] ?? 0;
    _prevExpense = summary['expense'] ?? 0;
  }
}
