import 'package:isar/isar.dart';

part 'wallet.g.dart';

/// Isar collection representing a user's wallet (e.g. Cash, Bank BCA).
///
/// The [balance] is stored directly and updated whenever a transaction
/// is added, edited, or deleted against this wallet.
@collection
class Wallet {
  Id id = Isar.autoIncrement;

  /// Display name of the wallet.
  late String name;

  /// Current balance in IDR. Updated on every transaction mutation.
  double balance = 0;

  /// Material color value (e.g. 0xFF6C63FF) for the wallet card UI.
  int color = 0xFF6C63FF;

  /// Icon key that maps to [AppIcons.walletIcons].
  String icon = 'wallet';

  /// Timestamp when the wallet was created.
  DateTime createdAt = DateTime.now();
}
