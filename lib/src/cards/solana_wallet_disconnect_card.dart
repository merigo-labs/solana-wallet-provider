/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import '../../solana_wallet_provider.dart';
import '../widgets/solana_wallet_text_overflow.dart';
import '../widgets/solana_wallet_copy_text.dart';
import '../../src/layouts/solana_wallet_grid.dart';
import '../../src/layouts/solana_wallet_thickness.dart';
import '../../src/widgets/solana_wallet_icon_painter.dart';


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

  /// Sets [_selectedAccount] and calls [widget.onTapAccount].
  void _onTapAccount(final Account account) {
    if (_selectedAccount != account) {
      if (mounted) setState(() => _selectedAccount = account);
      widget.onTapAccount?.call(account);
    }
  }

  /// Creates a list tile for the provided [account].
  Widget _itemBuilder(final Account account) {
    final String address = account.addressBase58;
    return SolanaWalletCopyText(
      text: address,
      onLongPress: true,
      child: ListTile(
        onTap: () => _onTapAccount(account),
        title: Text(
          account.label ?? 'Wallet',
        ),
        subtitle: SolanaWalletTextOverflow(
          text: address,
        ),
        trailing: _selectedAccount == account 
          ? CustomPaint(
            size: const Size.square(SolanaWalletGrid.x1),
            painter: SolanaWalletTickIcon(
              color: Theme.of(context).indicatorColor, 
              strokeWidth: SolanaWalletThickness.x1,
              withBorder: false,
            ),
          )
          : null,
      ),
    );
  }

  /// Builds a widget for [controller.state].
  Widget _builder(
    final BuildContext context, 
    final AsyncSnapshot<DeauthorizeResult> snapshot,
    final SolanaWalletMethodController<dynamic> controller,
  ) {
    switch (controller.state) {
      case SolanaWalletMethodState.none:
        return SolanaWalletCard(
          title: const Text('Accounts'),
          body: SolanaWalletListView(
            children: [
              SolanaWalletListView(
                children: widget.accounts,
                builder: _itemBuilder,
              ),
              TextButton(
                style: SolanaWalletThemeExtension.of(context)?.primaryButtonStyle,
                onPressed: () => controller.call(), // trigger _method()
                child: const Text('Disconnect'),
              ),
            ],
          ),
        );
      case SolanaWalletMethodState.progress:
        return SolanaWalletCard(
          body: SolanaWalletMethodView.progress(
            'Disconnecting wallet.',
          ),
        );
      case SolanaWalletMethodState.success:
        return SolanaWalletCard(
          body: SolanaWalletMethodView.success(
            'Wallet disconnected.',
          ),
        );
      case SolanaWalletMethodState.error:
        return SolanaWalletCard(
          body: SolanaWalletMethodView.error(
            snapshot.error,
            'Failed to disconnect.',
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
      onComplete: widget.onComplete,
      onCompleteError: widget.onCompleteError,
      auto: false,
    );
  }
}