# Financial Tracker — Progress Log

## Phase 1 — Foundation (Module D)
- [x] Update `pubspec.yaml` with all dependencies (isar, provider, intl, flutter_slidable)
- [x] Run `flutter pub get` — dependencies resolved
- [x] Create `lib/core/theme/app_theme.dart` — dark theme, brand colors, design tokens
- [x] Create `lib/core/constants/app_constants.dart` — TransactionType, SummaryPeriod enums, AppIcons
- [x] Create `lib/core/utils/currency_formatter.dart` — IDR (Rp) formatting
- [x] Create `lib/core/utils/date_formatter.dart` — relative dates, period helpers
- [x] Create `lib/app.dart` — MaterialApp with dark theme → MainShell
- [x] Set up `lib/main.dart` — Isar init (4 schemas) + MultiProvider (3 providers) + DefaultCategories.seed()

## Phase 2 — Module A (Wallet)
- [x] Create `lib/data/models/wallet.dart` — Isar @collection
- [x] Generate `wallet.g.dart` via build_runner
- [x] Create `lib/data/repositories/wallet_repository.dart` — CRUD, adjustBalance, setBalance, reactive streams
- [x] Create `lib/providers/wallet_provider.dart` — ChangeNotifier, loading/error state, getWalletById

## Phase 2 — Module B (Category)
- [x] Create `lib/data/models/category.dart`
- [x] Create `lib/data/models/sub_category.dart`
- [x] Create `lib/data/repositories/category_repository.dart` — CRUD, cascade delete, getCategoriesWithSubs
- [x] Create `lib/data/seeds/default_categories.dart` — DefaultCategories.seed()
- [x] Create `lib/providers/category_provider.dart` — expenseCategoriesWithSubs, incomeCategoriesWithSubs

## Phase 2 — Module C (Transaction)
- [x] Create `lib/data/models/transaction.dart`
- [x] Create `lib/data/repositories/transaction_repository.dart` — CRUD, wallet balance recalc, getSummary, grouping
- [x] Create `lib/providers/transaction_provider.dart` — groupedByDate, recentTransactions, setPeriod, filters

## Phase 3 — Navigation Shell
- [x] Create `lib/screens/main_shell.dart` — BottomNavigationBar with 3 tabs + center FAB
- [x] Wire up `app.dart` to use `MainShell` as home
- [x] Update `main.dart` to bootstrap with Isar + Providers

## Phase 4 — Wallet Screens ✅ WIRED TO BACKEND
- [x] Create `lib/screens/wallet/wallet_screen.dart` — live wallet list + total balance from WalletProvider
- [x] Create `lib/screens/wallet/widgets/wallet_card.dart` — reusable card
- [x] Create `lib/screens/wallet/wallet_form_screen.dart` — create/edit/delete wired to WalletProvider + TransactionProvider cascade delete

## Phase 5 — Transaction & Category Screens ✅ WIRED TO BACKEND
- [x] Create `lib/screens/add_transaction/category_picker_screen.dart` — reads live CategoryProvider
- [x] Create `lib/screens/add_transaction/add_transaction_screen.dart` — full create/edit/delete wired to TransactionProvider + WalletProvider
- [x] Create `lib/screens/transactions/transaction_list_screen.dart` — live grouped transactions, tap-to-edit
- [x] Create `lib/screens/transactions/widgets/transaction_tile.dart` — supports onTap for edit
- [x] Create `lib/screens/transactions/widgets/date_group_header.dart`
- [x] Create `lib/screens/category/manage_categories_screen.dart`
- [x] Create `lib/screens/category/category_form_screen.dart`

## Phase 6 — Home Dashboard ✅ WIRED TO BACKEND
- [x] Create `lib/screens/home/home_screen.dart` — live totalBalance, income/expense from providers
- [x] Create `lib/screens/home/widgets/balance_card.dart` — dynamic balance
- [x] Create `lib/screens/home/widgets/summary_card.dart` — dynamic income/expense totals
- [x] Create `lib/screens/home/widgets/recent_transactions.dart` — live transactions, resolves names from providers

## Phase 7 — Polish & UX
- [ ] Fix remaining info-level deprecations in category screens (withOpacity, activeColor)
- [ ] Add category management wiring to CategoryProvider
- [ ] Add unit tests for repositories

### flutter analyze status (Phase 6 complete)
- **0 errors, 0 warnings**
- 8 info-level deprecation hints in `category_form_screen.dart` / `manage_categories_screen.dart` (Phase 7)
