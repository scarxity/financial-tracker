import 'package:flutter/material.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/screens/category/category_form_screen.dart';

/// Manage categories screen — Phase 5.
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [Tab(text: 'Expense'), Tab(text: 'Income')],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryFormScreen())),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(isExpense: true),
          _buildCategoryList(isExpense: false),
        ],
      ),
    );
  }

  Widget _buildCategoryList({required bool isExpense}) {
    final categories = isExpense
        ? [
            _Cat('Required Expenses', Icons.home_rounded, true, ['Food & Beverage', 'Electricity Bill', 'Internet Bill', 'Water Bill', 'Laundry', 'Rent', 'Transportation']),
            _Cat('Entertainment', Icons.movie_rounded, true, ['Streaming Services', 'Gaming', 'Hobbies']),
            _Cat('Personal', Icons.person_rounded, true, ['Clothing', 'Health & Fitness', 'Education']),
            _Cat('Transaction', Icons.swap_horiz_rounded, true, ['Outgoing Transfer']),
          ]
        : [
            _Cat('Transaction', Icons.swap_horiz_rounded, true, ['Incoming Transfer']),
            _Cat('Income', Icons.attach_money_rounded, true, ['Salary', 'Freelance', 'Allowance', 'Gift']),
          ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(cat.icon, color: AppTheme.primary, size: 20),
            ),
            title: Row(
              children: [
                Text(cat.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                if (cat.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Default', style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
            iconColor: AppTheme.textHint,
            collapsedIconColor: AppTheme.textHint,
            shape: const Border(),
            collapsedShape: const Border(),
            children: cat.subs.map((sub) => ListTile(
              contentPadding: const EdgeInsets.only(left: 72, right: 16),
              title: Text(sub, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
              trailing: cat.isDefault
                  ? null
                  : IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textHint, size: 20), onPressed: () {}),
            )).toList(),
          ),
        );
      },
    );
  }
}

class _Cat {
  final String name;
  final IconData icon;
  final bool isDefault;
  final List<String> subs;
  const _Cat(this.name, this.icon, this.isDefault, this.subs);
}
