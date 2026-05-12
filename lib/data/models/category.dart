import 'package:isar/isar.dart';

part 'category.g.dart';

/// Isar collection for transaction categories.
///
/// Each category has a [type] that indicates whether it groups
/// expense sub-categories (0) or income sub-categories (1).
/// Default (pre-defined) categories are protected from deletion.
@collection
class Category {
  Id id = Isar.autoIncrement;

  /// Display name, e.g. "Required Expenses", "Entertainment".
  late String name;

  /// 0 = expense, 1 = income. Maps to [TransactionType.index].
  late int type;

  /// `true` for pre-defined categories that cannot be deleted.
  late bool isDefault;

  /// Icon name resolved via [AppIcons.resolve].
  late String icon;
}
