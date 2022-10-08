/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import '../layouts/solana_wallet_layout_grid.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../widgets/solana_wallet_account_list_tile.dart';
import '../widgets/solana_wallet_button.dart';
import '../widgets/solana_wallet_card.dart';
import '../widgets/solana_wallet_column.dart';


/// Solana Wallet Account View
/// ------------------------------------------------------------------------------------------------

class SolanaWalletAccountView extends StatefulWidget {
  
  /// Creates a view that displays a list of [accounts] and highlights the [selectedAccount].
  const SolanaWalletAccountView({
    super.key,
    this.selectedAccount,
    required this.accounts,
    this.onTapAccount,
    this.onTapDisconnect,
  });

  /// The user selected account.
  final Account? selectedAccount;

  /// A list of wallet accounts.
  final List<Account> accounts;

  /// Called when a new account in the [accounts] list is selected.
  final void Function(Account)? onTapAccount;

  /// Called when the disconnect button is pressed.
  final VoidCallback? onTapDisconnect;

  @override
  State<SolanaWalletAccountView> createState() => _SolanaWalletAccountViewState();
}


/// Solana Wallet Account View State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletAccountViewState extends State<SolanaWalletAccountView> {

  /// The current selection.
  Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.selectedAccount;
  }

  /// Creates a handler to update the [_selectedAccount].
  VoidCallback _onTapAccountHandler(final Account account) {
    return () { 
      if (_selectedAccount != account) {
        setState(() => _selectedAccount = account);
        widget.onTapAccount?.call(account);
      }
    };
  }

  /// Creates a widget from the provided [account].
  Widget _mapAccount(final Account account) 
    => SolanaWalletAccountListTile(
      account: account, 
      selected: _selectedAccount == account,
      onTap: _onTapAccountHandler(account),
    );

  @override
  Widget build(BuildContext context) {
    final SolanaWalletThemeExtension? extension = SolanaWalletThemeExtension.of(context);
    final List<Widget> accounts = widget.accounts.map(_mapAccount).toList(growable: false);
    return SolanaWalletCard(
      title: 'Accounts',
      child: SolanaWalletColumn(
        spacing: SolanaWalletLayoutGrid.x2,
        children: [
          SolanaWalletColumn(
            children: [
              if (_selectedAccount == null)
                Text(accounts.isEmpty ? 'No wallets found.' : 'Select a wallet:'),
              ...accounts,
            ],
          ),
          SolanaWalletButton(
            onTap: widget.onTapDisconnect,
            style: extension?.buttonStyle ?? SolanaWalletButtonStyle.styleFrom(),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}