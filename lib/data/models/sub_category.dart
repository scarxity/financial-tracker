import 'package:isar/isar.dart';

part 'sub_category.g.dart';

/// Isar collection for sub-categories.
///
/// Each sub-category belongs to a parent [Category] via [categoryId].
/// Default sub-categories are protected from deletion.
@collection
class SubCategory {
  Id id = Isar.autoIncrement;

  /// Display name, e.g. "Food & Beverage", "Salary".
  late String name;

  /// Foreign key referencing the parent [Category.id].
  @Index()
  late int categoryId;

  /// `true` for pre-defined sub-categories.
  late bool isDefault;

  /// Icon name resolved via [AppIcons.resolve].
  late String icon;
}
