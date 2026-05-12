# Financial Tracker App — Implementation Plan

A Flutter mobile app for tracking personal finances (income & expenses) using **Isar** as the local database. Users manage wallets, categorize transactions with pre-defined or custom categories/sub-categories, and view summaries.

---

## Finalized Decisions

- ✅ **State Management**: Provider
- ✅ **Currency**: IDR (Rp) — format with `Rp` prefix and thousand separators
- ✅ **Project Name**: `financial_tracker`
- ✅ **Home Summary**: Allow toggling between period filters (Week / Month / All)
- ✅ **Wallet Deletion**: Cascade delete all associated transactions
- ✅ **Transaction Edit/Delete**: Users can edit and delete; wallet balance recalculated accordingly
- ✅ **Initial Wallet Balance**: Set at creation time
- ✅ **Category Icons**: Yes, pick from a predefined Material icon set

---

## Architecture Overview

```
lib/
├── main.dart                        # App entry, Isar init, Provider setup
├── app.dart                         # MaterialApp, theme, routing
│
├── core/                            # Shared utilities
│   ├── theme/
│   │   └── app_theme.dart           # Colors, typography, ThemeData
│   ├── constants/
│   │   └── app_constants.dart       # Enums, default values
│   └── utils/
│       ├── currency_formatter.dart  # Number formatting
│       └── date_formatter.dart      # Date display helpers
│
├── data/                            # ── Backend Module ──
│   ├── models/                      # Isar collections
│   │   ├── wallet.dart
│   │   ├── category.dart
│   │   ├── sub_category.dart
│   │   └── transaction.dart
│   ├── repositories/                # CRUD logic per collection
│   │   ├── wallet_repository.dart
│   │   ├── category_repository.dart
│   │   └── transaction_repository.dart
│   └── seeds/
│       └── default_categories.dart  # Pre-defined category seeding
│
├── providers/                       # ── State Management ──
│   ├── wallet_provider.dart
│   ├── category_provider.dart
│   └── transaction_provider.dart
│
└── screens/                         # ── Frontend Module ──
    ├── main_shell.dart              # Bottom nav bar + FAB scaffold
    ├── home/
    │   ├── home_screen.dart         # Summary dashboard
    │   └── widgets/                 # Summary cards, charts
    ├── transactions/
    │   ├── transaction_list_screen.dart
    │   └── widgets/                 # Transaction tile, filters
    ├── wallet/
    │   ├── wallet_screen.dart
    │   ├── wallet_form_screen.dart
    │   └── widgets/                 # Wallet card
    ├── add_transaction/
    │   ├── add_transaction_screen.dart
    │   └── category_picker_screen.dart  # Full-screen category selector
    └── category/
        ├── manage_categories_screen.dart
        └── category_form_screen.dart
```

---

## Data Models (Isar Collections)

### Wallet
| Field | Type | Notes |
|-------|------|-------|
| `id` | `Id` | Auto-increment |
| `name` | `String` | e.g. "Cash", "Bank BCA" |
| `balance` | `double` | Computed from transactions or stored |
| `color` | `int` | Material color value for UI |
| `icon` | `String` | Icon name identifier |
| `createdAt` | `DateTime` | |

### Category
| Field | Type | Notes |
|-------|------|-------|
| `id` | `Id` | Auto-increment |
| `name` | `String` | e.g. "Required Expenses", "Transaction" |
| `type` | `int` | Enum index: 0 = expense, 1 = income |
| `isDefault` | `bool` | `true` for pre-defined, can't delete |
| `icon` | `String` | Icon name |

### SubCategory
| Field | Type | Notes |
|-------|------|-------|
| `id` | `Id` | Auto-increment |
| `name` | `String` | e.g. "Food & Beverage" |
| `categoryId` | `int` | FK to Category |
| `isDefault` | `bool` | |
| `icon` | `String` | |

### Transaction (FinancialTransaction)
| Field | Type | Notes |
|-------|------|-------|
| `id` | `Id` | Auto-increment |
| `amount` | `double` | Always positive (≥ 0) |
| `type` | `int` | 0 = expense, 1 = income |
| `note` | `String?` | Optional description |
| `walletId` | `int` | FK to Wallet |
| `subCategoryId` | `int` | FK to SubCategory |
| `createdAt` | `DateTime` | Timestamp |

> [!NOTE]
> Isar class name `Transaction` may conflict with Isar's own `Transaction` type. We'll name the class `FinancialTransaction` to avoid collision.

---

## Pre-Defined Categories & Sub-Categories

### Expense Categories (type = expense)

| Category | Sub-Categories |
|----------|---------------|
| **Required Expenses** | Food & Beverage, Electricity Bill, Internet Bill, Water Bill, Laundry, Rent, Transportation |
| **Entertainment** | Streaming Services, Gaming, Hobbies |
| **Personal** | Clothing, Health & Fitness, Education |
| **Transaction** | Outgoing Transfer |

### Income Categories (type = income)

| Category | Sub-Categories |
|----------|---------------|
| **Transaction** | Incoming Transfer |
| **Income** | Salary, Freelance, Allowance, Gift |

> [!NOTE]
> The "Transaction" category exists in both types — "Incoming Transfer" (income) and "Outgoing Transfer" (expense). We will create **two separate Category entries** with the same name but different `type` values, OR we can make one "Transaction" category and let the sub-categories determine the type. **Recommendation**: Two separate categories for clarity.

---

## Backend Modules (for Parallel Development)

The backend is split into **3 independent modules** that can be developed in parallel:

### Module A — Wallet Module
- **Files**: `models/wallet.dart`, `repositories/wallet_repository.dart`, `providers/wallet_provider.dart`
- **Scope**: Wallet CRUD, balance calculation, wallet listing
- **No dependencies** on other modules

### Module B — Category Module  
- **Files**: `models/category.dart`, `models/sub_category.dart`, `repositories/category_repository.dart`, `providers/category_provider.dart`, `seeds/default_categories.dart`
- **Scope**: Category/SubCategory CRUD, seeding defaults, category picker data
- **No dependencies** on other modules

### Module C — Transaction Module
- **Files**: `models/transaction.dart`, `repositories/transaction_repository.dart`, `providers/transaction_provider.dart`
- **Scope**: Transaction CRUD, filtering, summary aggregation
- **Depends on**: Module A (wallet IDs), Module B (subCategory IDs) — but only at the ID/integer level, no direct import dependency for the repository

### Module D — Core & Infrastructure
- **Files**: `main.dart`, `app.dart`, `core/**`
- **Scope**: Isar initialization, theme, utilities, Provider setup
- **Should be done first** as other modules depend on Isar instance

---

## Screen Descriptions

### Bottom Navigation Structure
```
┌────────────────────────────────────────┐
│               App Content              │
├──────┬──────┬──────────┬──────┬────────┤
│ Home │ Trans│   (+)    │      │ Wallet │
│  🏠  │  📋 │   ⊕     │      │  💳   │
└──────┴──────┴──────────┴──────┴────────┘
```
- **3 actual tabs**: Home, Transactions, Wallet
- **Center FAB**: Floating `+` button opens Add Transaction screen (modal/push)
- The bottom nav has 4 items visually but the center one is a dummy placeholder; the FAB overlaps it

### 1. Home Screen
- **Total Balance** card (sum of all wallets)
- **Income vs Expense** summary for current period
- **Recent Transactions** list (last 5-10)
- Quick stats / mini chart (optional, can be phase 2)

### 2. Transactions Screen
- **Scrollable list** of all transactions, grouped by date
- Each item shows: sub-category icon, name, amount (green for income, red for expense), wallet name, time
- **Filter** by date range, category type (income/expense), wallet

### 3. Add Transaction Screen (via FAB)
- **Category selector** — tapping opens `CategoryPickerScreen` (full screen)
  - Shows all categories as expandable groups
  - Sub-categories listed under each group
  - User taps a sub-category to select → returns to form
- **Amount input** — numeric keyboard, positive only, validated ≥ 0
- **Wallet selector** — dropdown or bottom sheet
- **Note** — optional text field
- **Date** — defaults to now, can be changed
- **Save button**

### 4. Wallet Screen
- **List of wallets** as cards showing name, balance, color/icon
- **Add wallet** button
- **Tap wallet** → detail view or edit
- **Wallet form**: name, initial balance (?), color picker, icon picker

### 5. Category Picker Screen (pushed from Add Transaction)
- Full-screen with back button
- Lists categories grouped by type tabs (Expense / Income)
- Each category is expandable → shows sub-categories
- Tapping a sub-category selects it and pops back with the selection

### 6. Manage Categories Screen (accessible from settings or long-press)
- View all categories and sub-categories
- Add custom category / sub-category
- Edit / delete custom ones (defaults are protected)

---

## Proposed Changes

### Module D — Core & Infrastructure (do first)

#### [MODIFY] [pubspec.yaml](file:///d:/Vin/File%20Tugas/Tugas%20Kuliah/Semester%206/Mobile%20Programming/financial_tracker/pubspec.yaml)
- Rename to `financial_tracker`
- Add dependencies: `isar`, `isar_flutter_libs`, `path_provider`, `provider`, `intl`, `flutter_slidable`
- Add dev dependencies: `isar_generator`, `build_runner`

#### [MODIFY] [main.dart](file:///d:/Vin/File%20Tugas/Tugas%20Kuliah/Semester%206/Mobile%20Programming/financial_tracker/lib/main.dart)
- Initialize Isar with all collection schemas
- Wrap app in `MultiProvider`
- Seed default categories on first run

#### [NEW] `lib/app.dart`
- `MaterialApp` with dark theme, routes

#### [NEW] `lib/core/theme/app_theme.dart`
- Premium dark theme with custom color palette

#### [NEW] `lib/core/constants/app_constants.dart`
- `TransactionType` enum, color constants

#### [NEW] `lib/core/utils/currency_formatter.dart`
#### [NEW] `lib/core/utils/date_formatter.dart`

---

### Module A — Wallet

#### [NEW] `lib/data/models/wallet.dart`
- Isar `@collection` class

#### [NEW] `lib/data/repositories/wallet_repository.dart`
- `createWallet()`, `getAllWallets()`, `updateWallet()`, `deleteWallet()`, `updateBalance()`

#### [NEW] `lib/providers/wallet_provider.dart`
- `ChangeNotifier` wrapping wallet repository

---

### Module B — Category

#### [NEW] `lib/data/models/category.dart`
#### [NEW] `lib/data/models/sub_category.dart`

#### [NEW] `lib/data/repositories/category_repository.dart`
- CRUD for categories and sub-categories
- `getByType()`, `getSubCategoriesByCategoryId()`

#### [NEW] `lib/data/seeds/default_categories.dart`
- Function to seed all pre-defined categories and sub-categories on first launch

#### [NEW] `lib/providers/category_provider.dart`

---

### Module C — Transaction

#### [NEW] `lib/data/models/transaction.dart`
- `FinancialTransaction` Isar collection

#### [NEW] `lib/data/repositories/transaction_repository.dart`
- `addTransaction()`, `getAll()`, `getByDateRange()`, `getByWallet()`, `getSummary()`
- On add: also update wallet balance

#### [NEW] `lib/providers/transaction_provider.dart`

---

### Frontend Screens

#### [NEW] `lib/screens/main_shell.dart`
- `Scaffold` with `BottomNavigationBar` (3 tabs + center FAB)
- `IndexedStack` or `PageView` for tab content

#### [NEW] `lib/screens/home/home_screen.dart`
#### [NEW] `lib/screens/home/widgets/balance_card.dart`
#### [NEW] `lib/screens/home/widgets/summary_card.dart`
#### [NEW] `lib/screens/home/widgets/recent_transactions.dart`

#### [NEW] `lib/screens/transactions/transaction_list_screen.dart`
#### [NEW] `lib/screens/transactions/widgets/transaction_tile.dart`
#### [NEW] `lib/screens/transactions/widgets/date_group_header.dart`

#### [NEW] `lib/screens/wallet/wallet_screen.dart`
#### [NEW] `lib/screens/wallet/wallet_form_screen.dart`
#### [NEW] `lib/screens/wallet/widgets/wallet_card.dart`

#### [NEW] `lib/screens/add_transaction/add_transaction_screen.dart`
#### [NEW] `lib/screens/add_transaction/category_picker_screen.dart`

#### [NEW] `lib/screens/category/manage_categories_screen.dart`
#### [NEW] `lib/screens/category/category_form_screen.dart`

---

## Execution Phases

### Phase 1 — Foundation (Module D)
1. Update `pubspec.yaml` with all dependencies
2. Run `flutter pub get`
3. Create core files (theme, constants, utils)
4. Set up `main.dart` with Isar initialization
5. Create `app.dart` with theme and basic routing

### Phase 2 — Data Layer (Modules A, B, C — parallel)
1. Create all Isar model files
2. Run `flutter pub run build_runner build`
3. Create all repositories
4. Create seed data
5. Create all providers

### Phase 3 — Navigation Shell
1. Build `main_shell.dart` with bottom nav + FAB
2. Create placeholder screens for all tabs

### Phase 4 — Wallet Feature
1. Wallet list screen with cards
2. Wallet creation form
3. Wire up to WalletProvider

### Phase 5 — Category & Transaction Feature  
1. Category picker screen (full-screen selector)
2. Add transaction screen with form
3. Transaction list screen
4. Wire up providers

### Phase 6 — Home Dashboard
1. Balance card
2. Income/Expense summary
3. Recent transactions
4. Polish

### Phase 7 — Polish & UX
1. Animations and transitions
2. Empty states
3. Error handling
4. Category management screen
5. Final UI polish per `frontend-skills.md`

---

## Verification Plan

### Automated Tests
```bash
flutter analyze        # No warnings/errors
flutter test           # Unit tests for repositories
flutter run            # Manual verification on emulator/device
```

### Manual Verification
- Create a wallet → verify it appears in wallet list
- Add income transaction → verify wallet balance increases
- Add expense transaction → verify wallet balance decreases
- Check home screen summary matches transaction totals
- Create custom category → verify it appears in category picker
- Verify pre-defined categories cannot be deleted
- Verify negative amounts are rejected
- Test bottom navigation between all screens
