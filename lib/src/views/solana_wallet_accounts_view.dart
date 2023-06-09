/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show Account;
import '../layouts/solana_wallet_grid.dart';
import '../tiles/solana_wallet_account_tile.dart';
import '../views/solana_wallet_list_view.dart';


/// Solana Wallet Accounts View
/// ------------------------------------------------------------------------------------------------

/// A list of Solana wallet accounts.
class SolanaWalletAccountsView extends StatelessWidget {

  /// Creates a list of Solana wallet accounts.
  const SolanaWalletAccountsView({
    super.key, 
    required this.accounts,
    required this.selectedAccount,
    required this.onPressed,
  });

  /// The connected wallet's accounts.
  final List<Account> accounts;

  /// The selected account in [accounts].
  final Account? selectedAccount;

  /// The on tap callback handler.
  final void Function(Account app) onPressed;

  @override
  Widget build(final BuildContext context) {
    const double spacing = SolanaWalletGrid.x1;
    return SolanaWalletListView(
      spacing: spacing,
      children: accounts.map(
        (final Account account) => SolanaWalletAccountTile(
          account: account, 
          selected: account == selectedAccount,
          onPressed: onPressed,
        )
      ).toList(growable: false),
    );
  }
}