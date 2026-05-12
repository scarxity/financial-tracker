import 'package:isar/isar.dart';

import '../models/transaction.dart';
import '../models/wallet.dart';

/// Repository handling CRUD and query operations for [FinancialTransaction].
///
/// When a transaction is added, edited, or deleted the associated
/// wallet balance is automatically recalculated.
class TransactionRepository {
  final Isar _isar;

  TransactionRepository(this._isar);

  // ─── Create / Update ──────────────────────────────────────────

  /// Add a new transaction and update the wallet balance.
  Future<int> addTransaction(FinancialTransaction txn) async {
    return _isar.writeTxn(() async {
      final id = await _isar.financialTransactions.put(txn);

      // Update wallet balance
      await _updateWalletBalance(txn.walletId);

      return id;
    });
  }

  /// Update an existing transaction. Handles wallet balance changes
  /// if the wallet or amount changed.
  Future<void> updateTransaction(FinancialTransaction txn) async {
    // Read the old transaction to know if walletId changed
    final oldTxn = await _isar.financialTransactions.get(txn.id);

    await _isar.writeTxn(() async {
      await _isar.financialTransactions.put(txn);

      // Recalculate the new wallet's balance
      await _updateWalletBalance(txn.walletId);

      // If the wallet changed, also recalculate the old wallet
      if (oldTxn != null && oldTxn.walletId != txn.walletId) {
        await _updateWalletBalance(oldTxn.walletId);
      }
    });
  }

  // ─── Delete ───────────────────────────────────────────────────

  /// Delete a transaction by [id] and recalculate wallet balance.
  Future<bool> deleteTransaction(int id) async {
    final txn = await _isar.financialTransactions.get(id);
    if (txn == null) return false;

    final walletId = txn.walletId;

    return _isar.writeTxn(() async {
      final deleted = await _isar.financialTransactions.delete(id);
      if (deleted) {
        await _updateWalletBalance(walletId);
      }
      return deleted;
    });
  }

  /// Delete all transactions belonging to a wallet (cascade).
  Future<void> deleteByWalletId(int walletId) async {
    await _isar.writeTxn(() async {
      final txns = await _isar.financialTransactions
          .filter()
          .walletIdEqualTo(walletId)
          .findAll();
      await _isar.financialTransactions
          .deleteAll(txns.map((t) => t.id).toList());
    });
  }

  // ─── Queries ──────────────────────────────────────────────────

  /// Get all transactions ordered by date descending.
  Future<List<FinancialTransaction>> getAll() async {
    return _isar.financialTransactions
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get transactions within a date range [start, end].
  Future<List<FinancialTransaction>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return _isar.financialTransactions
        .filter()
        .createdAtBetween(start, end)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get transactions for a specific wallet.
  Future<List<FinancialTransaction>> getByWalletId(int walletId) async {
    return _isar.financialTransactions
        .filter()
        .walletIdEqualTo(walletId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get transactions filtered by type (0 = expense, 1 = income).
  Future<List<FinancialTransaction>> getByType(int type) async {
    return _isar.financialTransactions
        .filter()
        .typeEqualTo(type)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get a single transaction by [id].
  Future<FinancialTransaction?> getById(int id) async {
    return _isar.financialTransactions.get(id);
  }

  /// Get the most recent [limit] transactions.
  Future<List<FinancialTransaction>> getRecent({int limit = 10}) async {
    return _isar.financialTransactions
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  // ─── Aggregation / Summary ────────────────────────────────────

  /// Calculate total income and total expense for a date range.
  /// Returns `{income: double, expense: double}`.
  Future<Map<String, double>> getSummary({
    DateTime? start,
    DateTime? end,
  }) async {
    List<FinancialTransaction> txns;

    if (start != null && end != null) {
      txns = await getByDateRange(start, end);
    } else {
      txns = await getAll();
    }

    double totalIncome = 0;
    double totalExpense = 0;

    for (final txn in txns) {
      if (txn.type == 1) {
        totalIncome += txn.amount;
      } else {
        totalExpense += txn.amount;
      }
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
    };
  }

  /// Count total transactions.
  Future<int> count() async {
    return _isar.financialTransactions.count();
  }

  // ─── Internal Helpers ─────────────────────────────────────────

  /// Recalculate and persist the balance for a wallet based on all
  /// its transactions. This must be called inside a write transaction.
  Future<void> _updateWalletBalance(int walletId) async {
    final wallet = await _isar.wallets.get(walletId);
    if (wallet == null) return;

    final txns = await _isar.financialTransactions
        .filter()
        .walletIdEqualTo(walletId)
        .findAll();

    double balance = 0;
    for (final txn in txns) {
      if (txn.type == 1) {
        balance += txn.amount; // income
      } else {
        balance -= txn.amount; // expense
      }
    }

    wallet.balance = balance;
    await _isar.wallets.put(wallet);
  }
}
