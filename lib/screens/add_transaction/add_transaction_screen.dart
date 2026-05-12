import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:financial_tracker/core/theme/app_theme.dart';
import 'package:financial_tracker/data/models/transaction.dart';
import 'package:financial_tracker/data/models/wallet.dart';
import 'package:financial_tracker/providers/transaction_provider.dart';
import 'package:financial_tracker/providers/wallet_provider.dart';
import 'package:financial_tracker/screens/add_transaction/category_picker_screen.dart';

/// Add / Edit Transaction form.
///
/// The expense/income type is determined entirely by the selected category.
/// There is no manual type toggle on this screen.
class AddTransactionScreen extends StatefulWidget {
  final FinancialTransaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  bool get isEditing => transaction != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Type is derived from the selected category (0=expense, 1=income)
  int? _type;
  int? _selectedSubCategoryId;
  String? _selectedCategoryName;
  String? _selectedSubCategoryName;

  int? _selectedWalletId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final tx = widget.transaction!;
      _type = tx.type;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _noteController.text = tx.note ?? '';
      _selectedSubCategoryId = tx.subCategoryId;
      _selectedWalletId = tx.walletId;
      _selectedDate = tx.createdAt;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Derive button color based on selected type
  Color get _accentColor {
    if (_type == null) return AppTheme.primary;
    return _type == 0 ? AppTheme.expense : AppTheme.income;
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final wallets = walletProvider.wallets;

    // Auto-select first wallet if none selected
    if (_selectedWalletId == null && wallets.isNotEmpty) {
      _selectedWalletId = wallets.first.id;
    }

    final selectedWallet = wallets.isEmpty
        ? null
        : wallets.firstWhere(
            (w) => w.id == _selectedWalletId,
            orElse: () => wallets.first,
          );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: widget.isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.expense),
                  onPressed: () => _showDeleteDialog(context),
                )
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Amount ──────────────────────────────
              const Text('Amount',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                      color: AppTheme.textHint.withValues(alpha: 0.5),
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(
                      color: _accentColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                  final n = int.tryParse(v.trim());
                  if (n == null) return 'Enter a valid number';
                  if (n <= 0) return 'Amount must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ─── Category picker ─────────────────────
              const Text('Category',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _SelectorTile(
                icon: Icons.category_rounded,
                label: _selectedSubCategoryName ?? 'Select Category',
                subtitle: _selectedCategoryName,
                hasValue: _selectedSubCategoryId != null,
                accentColor: _accentColor,
                onTap: () async {
                  final result =
                      await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryPickerScreen(
                        type: _type ?? 0,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _selectedSubCategoryId = result['subCategoryId'] as int;
                      _selectedCategoryName = result['category'] as String;
                      _selectedSubCategoryName =
                          result['subCategory'] as String;
                      // Type is determined by the category
                      _type = result['type'] as int;
                    });
                  }
                },
              ),
              // Show the determined type as a subtle badge
              if (_type != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _type == 1
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: _accentColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _type == 1 ? 'Income' : 'Expense',
                          style: TextStyle(
                            color: _accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // ─── Wallet selector ─────────────────────
              const Text('Wallet',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              wallets.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text(
                        'No wallets found — create one first',
                        style: TextStyle(
                            color: AppTheme.expense, fontSize: 14),
                      ),
                    )
                  : _SelectorTile(
                      icon: Icons.account_balance_wallet_rounded,
                      label: selectedWallet?.name ?? 'Select Wallet',
                      hasValue: _selectedWalletId != null,
                      onTap: () => _showWalletPicker(context, wallets),
                    ),
              const SizedBox(height: 16),

              // ─── Date ────────────────────────────────
              const Text('Date',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _SelectorTile(
                icon: Icons.calendar_today_rounded,
                label:
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                hasValue: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                            primary: AppTheme.primary,
                            surface: AppTheme.surface),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 16),

              // ─── Note ────────────────────────────────
              const Text('Note (optional)',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 3,
                decoration:
                    const InputDecoration(hintText: 'Add a note...'),
              ),
              const SizedBox(height: 32),

              // ─── Save button ─────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSaving || wallets.isEmpty)
                      ? null
                      : () => _save(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          widget.isEditing
                              ? 'Save Changes'
                              : 'Save Transaction',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubCategoryId == null || _type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: AppTheme.error),
      );
      return;
    }
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a wallet'),
            backgroundColor: AppTheme.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text.trim());
      final txProvider = context.read<TransactionProvider>();

      if (widget.isEditing) {
        final updatedTx = widget.transaction!
          ..amount = amount
          ..type = _type!
          ..note = _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim()
          ..walletId = _selectedWalletId!
          ..subCategoryId = _selectedSubCategoryId!
          ..createdAt = _selectedDate;
        await txProvider.updateTransaction(updatedTx);
      } else {
        final newTx = FinancialTransaction()
          ..amount = amount
          ..type = _type!
          ..note = _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim()
          ..walletId = _selectedWalletId!
          ..subCategoryId = _selectedSubCategoryId!
          ..createdAt = _selectedDate;
        await txProvider.addTransaction(newTx);
      }

      // Refresh wallet balances in the provider
      if (context.mounted) {
        context.read<WalletProvider>().loadWallets();
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showWalletPicker(BuildContext context, List<Wallet> wallets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.textHint,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Select Wallet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...wallets.map((w) => ListTile(
                  leading: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppTheme.primary),
                  title: Text(w.name,
                      style:
                          const TextStyle(color: AppTheme.textPrimary)),
                  trailing: _selectedWalletId == w.id
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedWalletId = w.id);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Transaction?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will permanently remove this transaction and update wallet balance.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context
                  .read<TransactionProvider>()
                  .deleteTransaction(widget.transaction!.id);
              if (context.mounted) {
                context.read<WalletProvider>().loadWallets();
                Navigator.pop(context);
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }
}

class _SelectorTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool hasValue;
  final Color? accentColor;
  final VoidCallback onTap;

  const _SelectorTile(
      {required this.icon,
      required this.label,
      this.subtitle,
      required this.hasValue,
      this.accentColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: !hasValue
                ? Border.all(color: AppTheme.textHint.withValues(alpha: 0.3))
                : null),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: hasValue
                              ? AppTheme.textPrimary
                              : AppTheme.textHint,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: AppTheme.textHint, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}
