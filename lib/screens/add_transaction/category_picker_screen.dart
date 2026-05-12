import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_tracker/core/constants/app_constants.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/data/models/category.dart' as models;
import 'package:financial_tracker/data/models/sub_category.dart';
import 'package:financial_tracker/providers/category_provider.dart';

/// Full-screen category picker — wired to CategoryProvider.
///
/// Returns `{'subCategoryId': int, 'category': String, 'subCategory': String, 'icon': String}`
/// when the user selects a sub-category.
class CategoryPickerScreen extends StatefulWidget {
  final int type; // 0 = expense, 1 = income
  const CategoryPickerScreen({super.key, required this.type});

  @override
  State<CategoryPickerScreen> createState() => _CategoryPickerScreenState();
}

class _CategoryPickerScreenState extends State<CategoryPickerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _expandedExpense = {0};
  final Set<int> _expandedIncome = {0};

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.type);

    // Load categories if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Select Category'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [Tab(text: 'Expense'), Tab(text: 'Income')],
        ),
      ),
      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                  categoryProvider.expenseCategoriesWithSubs
                      .cast<models.Category, List<SubCategory>>(),
                  _expandedExpense,
                  AppTheme.expense,
                ),
                _buildList(
                  categoryProvider.incomeCategoriesWithSubs
                      .cast<models.Category, List<SubCategory>>(),
                  _expandedIncome,
                  AppTheme.income,
                ),
              ],
            ),
    );
  }

  Widget _buildList(
    Map<models.Category, List<SubCategory>> catsWithSubs,
    Set<int> expanded,
    Color accent,
  ) {
    final entries = catsWithSubs.entries.toList();

    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No categories available',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final cat = entries[index].key;
        final subs = entries[index].value;
        final isExpanded = expanded.contains(index);
        final catIcon = AppIcons.resolve(cat.icon);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              // Category header
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(
                    () => isExpanded ? expanded.remove(index) : expanded.add(index)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(catIcon, color: accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(cat.name,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15))),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.textHint),
                      ),
                    ],
                  ),
                ),
              ),
              // Sub-categories
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: subs.map((sub) {
                    final subIcon = AppIcons.resolve(sub.icon);
                    return InkWell(
                      onTap: () => Navigator.pop(context, {
                        'subCategoryId': sub.id,
                        'category': cat.name,
                        'subCategory': sub.name,
                        'icon': sub.icon,
                        'type': cat.type,
                      }),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(68, 10, 16, 10),
                        child: Row(
                          children: [
                            Icon(subIcon,
                                color: AppTheme.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Text(sub.name,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary, fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        );
      },
    );
  }
}
