import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:financial_tracker/core/constants/app_constants.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/core/utils/currency_formatter.dart';
import 'package:financial_tracker/providers/wallet_provider.dart';
import 'package:financial_tracker/screens/wallet/wallet_form_screen.dart';
import 'package:financial_tracker/screens/wallet/widgets/wallet_card.dart';

/// Wallet list screen — Phase 4/5 (wired to WalletProvider).
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ─── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text('My Wallets',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const Spacer(),
                    _AddWalletButton(
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (_) => const WalletFormScreen()))
                          .then((_) => provider.loadWallets()),
                    ),
                  ],
                ),
              ),

              // ─── Total Balance ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text('Total Balance',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14)),
                      const SizedBox(height: 8),
                      provider.isLoading
                          ? const CircularProgressIndicator(
                              color: AppTheme.primary, strokeWidth: 2)
                          : Text(
                              CurrencyFormatter.format(provider.totalBalance),
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.wallets.length} ${provider.wallets.length == 1 ? 'wallet' : 'wallets'}',
                        style: const TextStyle(
                            color: AppTheme.textHint, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Wallet Cards / Empty State ───────────────
              Expanded(
                child: provider.wallets.isEmpty && !provider.isLoading
                    ? _buildEmptyState(context, provider)
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: provider.wallets.length + 1,
                        itemBuilder: (context, index) {
                          if (index == provider.wallets.length) {
                            return const SizedBox(height: 100);
                          }
                          final wallet = provider.wallets[index];
                          return WalletCard(
                            name: wallet.name,
                            balance: wallet.balance,
                            color: Color(wallet.color),
                            icon: AppIcons.resolve(wallet.icon, isWallet: true),
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (_) =>
                                        WalletFormScreen(wallet: wallet)))
                                .then((_) => provider.loadWallets()),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WalletProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: AppTheme.primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No wallets yet',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Add a wallet to get started',
              style: TextStyle(color: AppTheme.textHint, fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (_) => const WalletFormScreen()))
                .then((_) => provider.loadWallets()),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Wallet'),
          ),
        ],
      ),
    );
  }
}

class _AddWalletButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddWalletButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: AppTheme.primary, size: 18),
            SizedBox(width: 4),
            Text('Add',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
