import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_tracker/core/constants/app_constants.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/providers/wallet_provider.dart';
import 'package:financial_tracker/providers/transaction_provider.dart';
import 'package:financial_tracker/screens/home/widgets/balance_card.dart';
import 'package:financial_tracker/screens/home/widgets/summary_card.dart';
import 'package:financial_tracker/screens/home/widgets/recent_transactions.dart';
import 'package:financial_tracker/screens/home/widgets/comparison_chart.dart';

/// Home dashboard screen — wired to WalletProvider and TransactionProvider.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadWallets();
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final selectedPeriod = txProvider.selectedPeriod;

    // Determine labels for the comparison chart
    String prevLabel = '';
    String currLabel = '';
    bool showChart = true;

    switch (selectedPeriod) {
      case SummaryPeriod.week:
        prevLabel = 'Last Week';
        currLabel = 'This Week';
        break;
      case SummaryPeriod.month:
        prevLabel = 'Last Month';
        currLabel = 'This Month';
        break;
      case SummaryPeriod.all:
        showChart = false;
        break;
    }

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primary],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('User',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: AppTheme.textSecondary),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Balance Card ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: BalanceCard(totalBalance: walletProvider.totalBalance),
            ),
          ),

          // ─── Period Filter ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: SummaryPeriod.values.map((period) {
                    final isSelected = selectedPeriod == period;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => txProvider.setPeriod(period),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            period.label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ─── Income / Expense Summary ───────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Income',
                      amount: txProvider.totalIncome,
                      icon: Icons.arrow_downward_rounded,
                      color: AppTheme.income,
                      isIncome: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Expense',
                      amount: txProvider.totalExpense,
                      icon: Icons.arrow_upward_rounded,
                      color: AppTheme.expense,
                      isIncome: false,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Comparison Chart ───────────────────────────
          if (showChart)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ComparisonChart(
                  leftLabel: prevLabel,
                  rightLabel: currLabel,
                  leftIncome: txProvider.prevIncome,
                  leftExpense: txProvider.prevExpense,
                  rightIncome: txProvider.totalIncome,
                  rightExpense: txProvider.totalExpense,
                ),
              ),
            ),

          // ─── Recent Transactions Header ─────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions',
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Recent Transactions List ───────────────────
          const SliverToBoxAdapter(
            child: RecentTransactions(),
          ),

          // Bottom padding for FAB clearance
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
