import 'package:flutter/foundation.dart';
import 'package:financial_tracker/data/models/wallet.dart';
import 'package:financial_tracker/data/repositories/wallet_repository.dart';

/// Provider that manages wallet state and exposes it to the UI.
///
/// Listens to Isar reactive queries so the UI automatically rebuilds
/// when wallet data changes.
class WalletProvider extends ChangeNotifier {
  final WalletRepository _repository;

  List<Wallet> _wallets = [];
  double _totalBalance = 0;
  bool _isLoading = false;
  String? _error;

  WalletProvider(this._repository) {
    loadWallets();
  }

  // ─── Getters ─────────────────────────────────────────────────

  List<Wallet> get wallets => _wallets;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWallets => _wallets.isNotEmpty;

  // ─── Load ────────────────────────────────────────────────────

  /// Load all wallets from the database.
  Future<void> loadWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallets = await _repository.getAllWallets();
      _totalBalance = await _repository.getTotalBalance();
      _error = null;
    } catch (e) {
      _error = 'Failed to load wallets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Create ──────────────────────────────────────────────────

  /// Create a new wallet and refresh the list.
  Future<int> createWallet({
    required String name,
    required double initialBalance,
    required int color,
    required String icon,
  }) async {
    try {
      final id = await _repository.createWallet(
        name: name,
        initialBalance: initialBalance,
        color: color,
        icon: icon,
      );
      await loadWallets();
      return id;
    } catch (e) {
      _error = 'Failed to create wallet: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ─── Update ──────────────────────────────────────────────────

  /// Update wallet name, color, and icon.
  Future<void> updateWallet({
    required int id,
    required String name,
    required int color,
    required String icon,
  }) async {
    try {
      await _repository.updateWallet(
        id: id,
        name: name,
        color: color,
        icon: icon,
      );
      await loadWallets();
    } catch (e) {
      _error = 'Failed to update wallet: $e';
      notifyListeners();
    }
  }

  /// Adjust wallet balance (called when transactions change).
  Future<void> adjustBalance(int walletId, double delta) async {
    try {
      await _repository.adjustBalance(walletId, delta);
      await loadWallets();
    } catch (e) {
      _error = 'Failed to update balance: $e';
      notifyListeners();
    }
  }

  // ─── Delete ──────────────────────────────────────────────────

  /// Delete a wallet. Caller should cascade-delete transactions first.
  Future<void> deleteWallet(int id) async {
    try {
      await _repository.deleteWallet(id);
      await loadWallets();
    } catch (e) {
      _error = 'Failed to delete wallet: $e';
      notifyListeners();
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────

  /// Get a wallet by ID from the cached list.
  Wallet? getWalletById(int id) {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}
