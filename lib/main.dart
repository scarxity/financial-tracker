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
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };

  try {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        WalletSchema,
        CategorySchema,
        SubCategorySchema,
        FinancialTransactionSchema,
      ],
      directory: dir.path,
    );

    await DefaultCategories.seed(isar);

    final walletRepo = WalletRepository(isar);
    final categoryRepo = CategoryRepository(isar);
    final transactionRepo = TransactionRepository(isar);

    // Load settings early
    final settingsProvider = SettingsProvider();
    await settingsProvider.load();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsProvider),
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
