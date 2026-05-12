import 'package:isar/isar.dart';

part 'transaction.g.dart';

/// Isar collection for financial transactions.
///
/// Named [FinancialTransaction] to avoid collision with Isar's
/// built-in `Transaction` type.
///
/// [amount] is always stored as a positive value.
/// [type] determines if it's an expense (0) or income (1).
@collection
class FinancialTransaction {
  Id id = Isar.autoIncrement;

  /// Transaction amount (always ≥ 0).
  late double amount;

  /// 0 = expense, 1 = income. Maps to [TransactionType.index].
  late int type;

  /// Optional user note / description.
  String? note;

  /// Foreign key referencing the wallet this transaction belongs to.
  @Index()
  late int walletId;

  /// Foreign key referencing the [SubCategory] for this transaction.
  @Index()
  late int subCategoryId;

  /// Timestamp when the transaction was created / occurred.
  @Index()
  late DateTime createdAt;
}
