import 'package:isar/isar.dart';

import '../models/category.dart';
import '../models/sub_category.dart';

/// Repository handling all CRUD operations for [Category] and [SubCategory].
class CategoryRepository {
  final Isar _isar;

  CategoryRepository(this._isar);

  // ─── Category CRUD ────────────────────────────────────────────

  /// Retrieve all categories, optionally filtered by [type].
  /// [type]: 0 = expense, 1 = income. Pass `null` for all.
  Future<List<Category>> getAllCategories({int? type}) async {
    if (type != null) {
      return _isar.categorys
          .filter()
          .typeEqualTo(type)
          .findAll();
    }
    return _isar.categorys.where().findAll();
  }

  /// Get a single category by its [id]. Returns `null` if not found.
  Future<Category?> getCategoryById(int id) async {
    return _isar.categorys.get(id);
  }

  /// Create or update a [category]. Returns the assigned id.
  Future<int> saveCategory(Category category) async {
    return _isar.writeTxn(() async {
      return _isar.categorys.put(category);
    });
  }

  /// Delete a category by [id].
  /// Returns `true` if the category was deleted.
  /// **Note:** Also deletes all sub-categories belonging to this category.
  Future<bool> deleteCategory(int id) async {
    return _isar.writeTxn(() async {
      // Delete child sub-categories first
      final subCats = await _isar.subCategorys
          .filter()
          .categoryIdEqualTo(id)
          .findAll();
      await _isar.subCategorys
          .deleteAll(subCats.map((s) => s.id).toList());

      return _isar.categorys.delete(id);
    });
  }

  // ─── SubCategory CRUD ─────────────────────────────────────────

  /// Retrieve all sub-categories for a given [categoryId].
  Future<List<SubCategory>> getSubCategoriesByCategoryId(int categoryId) async {
    return _isar.subCategorys
        .filter()
        .categoryIdEqualTo(categoryId)
        .findAll();
  }

  /// Retrieve all sub-categories across all categories.
  Future<List<SubCategory>> getAllSubCategories() async {
    return _isar.subCategorys.where().findAll();
  }

  /// Get a single sub-category by its [id].
  Future<SubCategory?> getSubCategoryById(int id) async {
    return _isar.subCategorys.get(id);
  }

  /// Create or update a [subCategory]. Returns the assigned id.
  Future<int> saveSubCategory(SubCategory subCategory) async {
    return _isar.writeTxn(() async {
      return _isar.subCategorys.put(subCategory);
    });
  }

  /// Delete a sub-category by [id].
  Future<bool> deleteSubCategory(int id) async {
    return _isar.writeTxn(() async {
      return _isar.subCategorys.delete(id);
    });
  }

  // ─── Convenience Helpers ──────────────────────────────────────

  /// Get categories with their sub-categories as a map.
  /// Useful for the category picker UI.
  Future<Map<Category, List<SubCategory>>> getCategoriesWithSubs({
    int? type,
  }) async {
    final categories = await getAllCategories(type: type);
    final Map<Category, List<SubCategory>> result = {};

    for (final cat in categories) {
      final subs = await getSubCategoriesByCategoryId(cat.id);
      result[cat] = subs;
    }

    return result;
  }

  /// Check whether the database already has seeded categories.
  Future<bool> hasCategories() async {
    final count = await _isar.categorys.count();
    return count > 0;
  }
}
