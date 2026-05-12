import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/models/wallet.dart';
import 'data/models/category.dart';
import 'data/models/sub_category.dart';
import 'data/models/transaction.dart';
import 'data/repositories/wallet_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/seeds/default_categories.dart';
import 'providers/wallet_provider.dart';
import 'providers/category_provider.dart';
import 'providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch any unhandled async errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  try {
    // ── Open Isar database ──────────────────────────────────────
    final dir = await getApplicationDocumentsDirectory();
    debugPrint('Isar dir: ${dir.path}');

    final isar = await Isar.open(
      [
        WalletSchema,
        CategorySchema,
        SubCategorySchema,
        FinancialTransactionSchema,
      ],
      directory: dir.path,
    );
    debugPrint('Isar opened successfully');

    // ── Seed default categories on first launch ─────────────────
    await DefaultCategories.seed(isar);
    debugPrint('Seed complete');

    // ── Build repositories ──────────────────────────────────────
    final walletRepo = WalletRepository(isar);
    final categoryRepo = CategoryRepository(isar);
    final transactionRepo = TransactionRepository(isar);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => WalletProvider(walletRepo),
          ),
          ChangeNotifierProvider(
            create: (_) => CategoryProvider(categoryRepo)..loadCategories(),
          ),
          ChangeNotifierProvider(
            create: (_) => TransactionProvider(transactionRepo)
              ..loadTransactions(),
          ),
        ],
        child: const FinancialTrackerApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('FATAL startup error: $e');
    debugPrint('Stack trace: $stack');
    // Show a fallback error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to start:\n$e',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
