import 'package:isar/isar.dart';
import 'package:financial_tracker/data/models/wallet.dart';

/// Repository handling all Wallet CRUD operations against Isar.
class WalletRepository {
  final Isar _isar;

  WalletRepository(this._isar);

  // ─── CREATE ──────────────────────────────────────────────────

  /// Create a new wallet with the given properties.
  /// The [initialBalance] is set directly on the wallet.
  Future<int> createWallet({
    required String name,
    required double initialBalance,
    required int color,
    required String icon,
  }) async {
    final wallet = Wallet()
      ..name = name
      ..balance = initialBalance
      ..color = color
      ..icon = icon
      ..createdAt = DateTime.now();

    return _isar.writeTxn(() async {
      return _isar.wallets.put(wallet);
    });
  }

  // ─── READ ────────────────────────────────────────────────────

  /// Get all wallets ordered by creation date (newest first).
  Future<List<Wallet>> getAllWallets() async {
    return _isar.wallets.where().sortByCreatedAtDesc().findAll();
  }

  /// Get a single wallet by ID. Returns null if not found.
  Future<Wallet?> getWalletById(int id) async {
    return _isar.wallets.get(id);
  }

  /// Watch all wallets for reactive UI updates.
  Stream<List<Wallet>> watchAllWallets() {
    return _isar.wallets
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Get total balance across all wallets.
  Future<double> getTotalBalance() async {
    final wallets = await getAllWallets();
    return wallets.fold<double>(0, (sum, w) => sum + w.balance);
  }

  // ─── UPDATE ──────────────────────────────────────────────────

  /// Update wallet properties (name, color, icon).
  Future<void> updateWallet({
    required int id,
    required String name,
    required int color,
    required String icon,
  }) async {
    await _isar.writeTxn(() async {
      final wallet = await _isar.wallets.get(id);
      if (wallet == null) return;

      wallet.name = name;
      wallet.color = color;
      wallet.icon = icon;
      await _isar.wallets.put(wallet);
    });
  }

  /// Adjust wallet balance by a delta amount.
  /// Positive delta for income, negative for expense.
  Future<void> adjustBalance(int walletId, double delta) async {
    await _isar.writeTxn(() async {
      final wallet = await _isar.wallets.get(walletId);
      if (wallet == null) return;

      wallet.balance += delta;
      await _isar.wallets.put(wallet);
    });
  }

  /// Set wallet balance to an exact value (used during recalculation).
  Future<void> setBalance(int walletId, double newBalance) async {
    await _isar.writeTxn(() async {
      final wallet = await _isar.wallets.get(walletId);
      if (wallet == null) return;

      wallet.balance = newBalance;
      await _isar.wallets.put(wallet);
    });
  }

  // ─── DELETE ──────────────────────────────────────────────────

  /// Delete a wallet and cascade-delete all its transactions.
  /// The transaction deletion is handled by TransactionRepository
  /// which should be called before this method.
  Future<bool> deleteWallet(int id) async {
    return _isar.writeTxn(() async {
      return _isar.wallets.delete(id);
    });
  }

  /// Get the count of wallets.
  Future<int> getWalletCount() async {
    return _isar.wallets.count();
  }
}
