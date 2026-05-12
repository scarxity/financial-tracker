import 'package:flutter/foundation.dart' hide Category;

import '../data/models/category.dart';
import '../data/models/sub_category.dart';
import '../data/repositories/category_repository.dart';

/// [ChangeNotifier] that exposes category and sub-category state
/// to the widget tree via Provider.
class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider(this._repository);

  // ─── State ──────────────────────────────────────────────────

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<Category> _expenseCategories = [];
  List<Category> get expenseCategories => _expenseCategories;

  List<Category> _incomeCategories = [];
  List<Category> get incomeCategories => _incomeCategories;

  /// Map of category → sub-categories for expense type.
  Map<Category, List<SubCategory>> _expenseCategoriesWithSubs = {};
  Map<Category, List<SubCategory>> get expenseCategoriesWithSubs =>
      _expenseCategoriesWithSubs;

  /// Map of category → sub-categories for income type.
  Map<Category, List<SubCategory>> _incomeCategoriesWithSubs = {};
  Map<Category, List<SubCategory>> get incomeCategoriesWithSubs =>
      _incomeCategoriesWithSubs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ─── Load / Refresh ─────────────────────────────────────────

  /// Load all categories and their sub-categories from the database.
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
      _expenseCategories = await _repository.getAllCategories(type: 0);
      _incomeCategories = await _repository.getAllCategories(type: 1);

      _expenseCategoriesWithSubs =
          await _repository.getCategoriesWithSubs(type: 0);
      _incomeCategoriesWithSubs =
          await _repository.getCategoriesWithSubs(type: 1);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Category Mutations ─────────────────────────────────────

  /// Add or update a category. Refreshes the local state afterwards.
  Future<void> saveCategory(Category category) async {
    await _repository.saveCategory(category);
    await loadCategories();
  }

  /// Delete a non-default category by [id]. Cascades to sub-categories.
  Future<bool> deleteCategory(int id) async {
    final cat = await _repository.getCategoryById(id);
    if (cat == null || cat.isDefault) return false;

    final deleted = await _repository.deleteCategory(id);
    if (deleted) await loadCategories();
    return deleted;
  }

  // ─── SubCategory Mutations ──────────────────────────────────

  /// Add or update a sub-category. Refreshes state afterwards.
  Future<void> saveSubCategory(SubCategory subCategory) async {
    await _repository.saveSubCategory(subCategory);
    await loadCategories();
  }

  /// Delete a non-default sub-category by [id].
  Future<bool> deleteSubCategory(int id) async {
    final sub = await _repository.getSubCategoryById(id);
    if (sub == null || sub.isDefault) return false;

    final deleted = await _repository.deleteSubCategory(id);
    if (deleted) await loadCategories();
    return deleted;
  }

  // ─── Lookups ────────────────────────────────────────────────

  /// Find a sub-category by its id.
  Future<SubCategory?> getSubCategoryById(int id) {
    return _repository.getSubCategoryById(id);
  }

  /// Find a category by its id.
  Future<Category?> getCategoryById(int id) {
    return _repository.getCategoryById(id);
  }

  /// Get sub-categories for a specific category.
  Future<List<SubCategory>> getSubCategoriesFor(int categoryId) {
    return _repository.getSubCategoriesByCategoryId(categoryId);
  }
}
