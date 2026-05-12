import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:financial_tracker/core/constants/app_constants.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/data/models/wallet.dart';
import 'package:financial_tracker/providers/transaction_provider.dart';
import 'package:financial_tracker/providers/wallet_provider.dart';

/// Wallet creation / edit form — Phase 4/5 (wired to WalletProvider).
class WalletFormScreen extends StatefulWidget {
  /// Pass an existing wallet to enter edit mode.
  final Wallet? wallet;
  const WalletFormScreen({super.key, this.wallet});

  bool get isEditing => wallet != null;

  @override
  State<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends State<WalletFormScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  int _selectedColorIndex = 0;
  String _selectedIcon = 'wallet';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final w = widget.wallet!;
      _nameController.text = w.name;
      _balanceController.text = w.balance.toStringAsFixed(0);
      _selectedIcon = w.icon;
      // Find matching color index
      final idx = AppTheme.walletColors
          .indexWhere((c) => c.toARGB32() == w.color);
      _selectedColorIndex = idx >= 0 ? idx : 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Wallet' : 'New Wallet'),
        actions: widget.isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.expense),
                  onPressed: () => _showDeleteDialog(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Name ──────────────────────────────────────
            const Text('Wallet Name',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration:
                  const InputDecoration(hintText: 'e.g. Cash, Bank BCA'),
            ),
            const SizedBox(height: 24),

            // ─── Initial Balance (create only) ─────────────
            if (!widget.isEditing) ...[
              const Text('Initial Balance',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _balanceController,
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                    hintText: '0',
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
            ],

            // ─── Color picker ───────────────────────────────
            const Text('Color',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(AppTheme.walletColors.length, (i) {
                final c = AppTheme.walletColors[i];
                final selected = _selectedColorIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: selected
                          ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // ─── Icon picker ────────────────────────────────
            const Text('Icon',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppIcons.walletIcons.entries.map((entry) {
                final selected = _selectedIcon == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary.withValues(alpha: 0.2)
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

            // ─── Save button ────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () => _save(context),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(widget.isEditing ? 'Save Changes' : 'Create Wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a wallet name.'),
          backgroundColor: AppTheme.expense));
      return;
    }

    setState(() => _isSaving = true);
    final walletProvider = context.read<WalletProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (widget.isEditing) {
        await walletProvider.updateWallet(
          id: widget.wallet!.id,
          name: name,
          color: AppTheme.walletColors[_selectedColorIndex].toARGB32(),
          icon: _selectedIcon,
        );
      } else {
        final balance = double.tryParse(
                _balanceController.text.replaceAll(',', '.')) ??
            0;
        await walletProvider.createWallet(
          name: name,
          initialBalance: balance,
          color: AppTheme.walletColors[_selectedColorIndex].toARGB32(),
          icon: _selectedIcon,
        );
      }
      if (mounted) navigator.pop();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
            SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppTheme.expense));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Wallet?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
            'All transactions in this wallet will also be deleted.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (ctx.mounted) Navigator.of(ctx).pop();
              // Cascade-delete transactions first, then wallet
              if (!ctx.mounted) return;
              await ctx
                  .read<TransactionProvider>()
                  .deleteByWalletId(widget.wallet!.id);
              if (!ctx.mounted) return;
              await ctx
                  .read<WalletProvider>()
                  .deleteWallet(widget.wallet!.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }
}
