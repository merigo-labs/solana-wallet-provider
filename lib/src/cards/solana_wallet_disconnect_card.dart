/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import '../views/solana_wallet_account_list_view.dart';
import '../../solana_wallet_provider.dart';
import '../../src/views/solana_wallet_opening_wallet_view.dart';


/// Solana Wallet Disconnect Card
/// ------------------------------------------------------------------------------------------------

/// A card that facilitates disconnecting the application from a wallet app.
class SolanaWalletDisconnectCard extends StatefulWidget {
  
  /// Creates a card that displays the connected [accounts], highlighting [selectedAccount] with an 
  /// option to disconnect the application.
  const SolanaWalletDisconnectCard({
    super.key,
    this.selectedAccount,
    required this.accounts,
    this.onTapAccount,
    this.onTapDisconnect,
    this.dismissState,
    this.onComplete,
    this.onCompleteError,
  });

  /// The user selected account.
  final Account? selectedAccount;

  /// The connected wallet accounts.
  final List<Account> accounts;

  /// Called when a new account in the [accounts] list is selected.
  final void Function(Account)? onTapAccount;

  /// Called when the disconnect button is pressed.
  final VoidCallback? onTapDisconnect;

  /// The [SolanaWalletMethodState] in which the [SolanaWalletProvider] modal should be 
  /// automatically closed.
  final DismissState? dismissState;

  /// The callback function invoked when disconnecting completes successfully.
  final void Function(DeauthorizeResult? value)? onComplete;

  /// The callback function invoked when disconnecting fails.
  final void Function(Object error, [StackTrace? stackTrace])? onCompleteError;

  @override
  State<SolanaWalletDisconnectCard> createState() => _SolanaWalletDisconnectCardState();
}


/// Solana Wallet Account Card State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletDisconnectCardState extends State<SolanaWalletDisconnectCard> {

  /// The current selection.
  Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.selectedAccount;
  }

  /// Makes a request to disconnect the application from the connected wallet.
  Future<DeauthorizeResult> _method([final dynamic value]) {
    final SolanaWalletProvider provider = SolanaWalletProvider.of(context);
    return provider.adapter.deauthorize();
  }

  /// Sets [_selectedAccount] and calls [SolanaWalletDisconnectCard.onTapAccount].
  void _onTapAccount(final Account account) {
    if (_selectedAccount != account) {
      if (mounted) setState(() => _selectedAccount = account);
      widget.onTapAccount?.call(account);
    }
  }

  /// Builds a widget for [SolanaWalletMethodController.state].
  Widget _builder(
    final BuildContext context, 
    final AsyncSnapshot<DeauthorizeResult> snapshot,
    final SolanaWalletMethodController controller,
  ) {
    switch (controller.state) {
      case SolanaWalletMethodState.none:
        return SolanaWalletCard(
          body: SolanaWalletAccountListView(
            title: const Text('Accounts'),
            accounts: widget.accounts,
            onPressed: _onTapAccount,
            selectedAccount: _selectedAccount,
            body: TextButton(
              style: SolanaWalletThemeExtension.of(context)?.primaryButtonStyle,
              onPressed: () => controller.call(), // trigger _method()
              child: const Text('Disconnect'),
            ),
          ),
        );
      case SolanaWalletMethodState.progress:
        return const SolanaWalletCard(
          body: SolanaWalletOpeningWalletView(),
        );
      case SolanaWalletMethodState.success:
        return SolanaWalletCard(
          body: SolanaWalletStateView.success(
            title: 'Wallet Disconnected',
          ),
        );
      case SolanaWalletMethodState.error:
        return SolanaWalletCard(
          body: SolanaWalletStateView.error(
            error: snapshot.error,
            message: 'Failed to disconnect.',
          ),
        );
    }
  }

  @override
  Widget build(final BuildContext context) {
    return SolanaWalletMethodBuilder(
      value: null, 
      method: _method, 
      builder: _builder,
      dismissState: widget.dismissState,
      onComplete: widget.onComplete,
      onCompleteError: widget.onCompleteError,
      auto: false,
    );
  }
}