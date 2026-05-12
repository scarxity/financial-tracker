import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:financial_tracker/core/constants/app_constants.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/data/models/category.dart';
import 'package:financial_tracker/data/models/sub_category.dart';
import 'package:financial_tracker/providers/category_provider.dart';

/// Form for creating a new custom category or sub-category — wired to CategoryProvider.
class CategoryFormScreen extends StatefulWidget {
  /// If set, the form creates a sub-category under this parent.
  final int? parentCategoryId;
  const CategoryFormScreen({super.key, this.parentCategoryId});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _nameController = TextEditingController();
  int _type = 0;
  String _selectedIcon = 'category';
  bool _isSubCategory = false;
  int? _selectedParentId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.parentCategoryId != null) {
      _isSubCategory = true;
      _selectedParentId = widget.parentCategoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('New Category')),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          // Build parent category list for the dropdown
          final parentCats = _type == 0
              ? provider.expenseCategories
              : provider.incomeCategories;

          // Ensure selected parent is valid after type change
          if (_selectedParentId != null &&
              !parentCats.any((c) => c.id == _selectedParentId)) {
            _selectedParentId = parentCats.isNotEmpty ? parentCats.first.id : null;
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Type toggle ──────────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      _buildTypeTab('Expense', 0, AppTheme.expense, parentCats),
                      _buildTypeTab('Income', 1, AppTheme.income, parentCats),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Sub-category toggle ──────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.subdirectory_arrow_right_rounded,
                          color: AppTheme.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                          child: Text('Create as sub-category',
                              style: TextStyle(
                                  color: AppTheme.textPrimary, fontSize: 14))),
                      Switch(
                          value: _isSubCategory,
                          onChanged: (v) => setState(() {
                                _isSubCategory = v;
                                if (v && parentCats.isNotEmpty) {
                                  _selectedParentId = parentCats.first.id;
                                }
                              }),
                          activeColor: AppTheme.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Parent category dropdown ─────────────
                if (_isSubCategory && parentCats.isNotEmpty) ...[
                  const Text('Parent Category',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12)),
                    child: DropdownButton<int>(
                      value: _selectedParentId ?? parentCats.first.id,
                      isExpanded: true,
                      dropdownColor: AppTheme.surfaceVariant,
                      underline: const SizedBox(),
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      items: parentCats
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedParentId = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ─── Name field ───────────────────────────
                const Text('Name',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration:
                      const InputDecoration(hintText: 'Category name'),
                ),
                const SizedBox(height: 24),

                // ─── Icon picker ──────────────────────────
                const Text('Icon',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppIcons.categoryIcons.entries.map((entry) {
                    final selected = _selectedIcon == entry.key;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedIcon = entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primary.withOpacity(0.2)
                              : AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: selected
                              ? Border.all(color: AppTheme.primary, width: 2)
                              : null,
                        ),
                        child: Icon(entry.value,
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            size: 22),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // ─── Save button ──────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _save(context, provider),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Create Category'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeTab(String label, int type, Color color, List<Category> cats) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type = type;
          if (_isSubCategory && cats.isNotEmpty) {
            _selectedParentId = cats.first.id;
          }
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: color.withOpacity(0.3)) : null,
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: selected ? color : AppTheme.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 15)),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, CategoryProvider provider) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a name.'),
          backgroundColor: AppTheme.expense));
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isSubCategory) {
        final parentId = _selectedParentId;
        if (parentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Please select a parent category.'),
              backgroundColor: AppTheme.expense));
          return;
        }
        final sub = SubCategory()
          ..name = name
          ..categoryId = parentId
          ..isDefault = false
          ..icon = _selectedIcon;
        await provider.saveSubCategory(sub);
      } else {
        final cat = Category()
          ..name = name
          ..type = _type
          ..isDefault = false
          ..icon = _selectedIcon;
        await provider.saveCategory(cat);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.expense));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
