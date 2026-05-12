import 'package:isar/isar.dart';

import '../models/category.dart';
import '../models/sub_category.dart';

/// Seeds the database with pre-defined categories and sub-categories
/// on first launch. All seeded entries have [isDefault] = true so
/// the UI can prevent deletion.
class DefaultCategories {
  DefaultCategories._();

  /// Run the seed. Does nothing if categories already exist.
  static Future<void> seed(Isar isar) async {
    final count = await isar.categorys.count();
    if (count > 0) return; // already seeded

    await isar.writeTxn(() async {
      // ── Expense Categories ─────────────────────────────────────

      // Required Expenses
      final requiredExpenses = Category()
        ..name = 'Required Expenses'
        ..type = 0
        ..isDefault = true
        ..icon = 'rent';
      final requiredExpensesId = await isar.categorys.put(requiredExpenses);

      for (final entry in [
        {'name': 'Food & Beverage', 'icon': 'food'},
        {'name': 'Electricity Bill', 'icon': 'electricity'},
        {'name': 'Internet Bill', 'icon': 'internet'},
        {'name': 'Water Bill', 'icon': 'water'},
        {'name': 'Laundry', 'icon': 'laundry'},
        {'name': 'Rent', 'icon': 'rent'},
        {'name': 'Transportation', 'icon': 'transport'},
      ]) {
        await isar.subCategorys.put(SubCategory()
          ..name = entry['name']!
          ..categoryId = requiredExpensesId
          ..isDefault = true
          ..icon = entry['icon']!);
      }

      // Entertainment
      final entertainment = Category()
        ..name = 'Entertainment'
        ..type = 0
        ..isDefault = true
        ..icon = 'entertainment';
      final entertainmentId = await isar.categorys.put(entertainment);

      for (final entry in [
        {'name': 'Streaming Services', 'icon': 'streaming'},
        {'name': 'Gaming', 'icon': 'gaming'},
        {'name': 'Hobbies', 'icon': 'hobbies'},
      ]) {
        await isar.subCategorys.put(SubCategory()
          ..name = entry['name']!
          ..categoryId = entertainmentId
          ..isDefault = true
          ..icon = entry['icon']!);
      }

      // Personal
      final personal = Category()
        ..name = 'Personal'
        ..type = 0
        ..isDefault = true
        ..icon = 'personal';
      final personalId = await isar.categorys.put(personal);

      for (final entry in [
        {'name': 'Clothing', 'icon': 'clothing'},
        {'name': 'Health & Fitness', 'icon': 'health'},
        {'name': 'Education', 'icon': 'education'},
      ]) {
        await isar.subCategorys.put(SubCategory()
          ..name = entry['name']!
          ..categoryId = personalId
          ..isDefault = true
          ..icon = entry['icon']!);
      }

      // Transaction (Expense)
      final transactionExpense = Category()
        ..name = 'Transaction'
        ..type = 0
        ..isDefault = true
        ..icon = 'transfer_out';
      final transactionExpenseId =
          await isar.categorys.put(transactionExpense);

      await isar.subCategorys.put(SubCategory()
        ..name = 'Outgoing Transfer'
        ..categoryId = transactionExpenseId
        ..isDefault = true
        ..icon = 'transfer_out');

      // ── Income Categories ──────────────────────────────────────

      // Transaction (Income)
      final transactionIncome = Category()
        ..name = 'Transaction'
        ..type = 1
        ..isDefault = true
        ..icon = 'transfer_in';
      final transactionIncomeId =
          await isar.categorys.put(transactionIncome);

      await isar.subCategorys.put(SubCategory()
        ..name = 'Incoming Transfer'
        ..categoryId = transactionIncomeId
        ..isDefault = true
        ..icon = 'transfer_in');

      // Income
      final income = Category()
        ..name = 'Income'
        ..type = 1
        ..isDefault = true
        ..icon = 'salary';
      final incomeId = await isar.categorys.put(income);

      for (final entry in [
        {'name': 'Salary', 'icon': 'salary'},
        {'name': 'Freelance', 'icon': 'freelance'},
        {'name': 'Allowance', 'icon': 'allowance'},
        {'name': 'Gift', 'icon': 'gift'},
      ]) {
        await isar.subCategorys.put(SubCategory()
          ..name = entry['name']!
          ..categoryId = incomeId
          ..isDefault = true
          ..icon = entry['icon']!);
      }
    });
  }
}
