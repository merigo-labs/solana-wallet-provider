/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async' show Completer;
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import '../../solana_wallet_provider.dart' show SolanaWalletThemeExtension;
import '../models/dismiss_state.dart';
import '../themes/solana_wallet_modal_banner_theme.dart';
import '../views/solana_wallet_modal_banner_view.dart';
import '../views/solana_wallet_accounts_view.dart';
import '../widgets/solana_wallet_app_icon.dart';
import '../widgets/solana_wallet_method_builder.dart';
import 'solana_wallet_modal_card.dart';


/// Solana Wallet Disconnect Card
/// ------------------------------------------------------------------------------------------------

/// A card that facilitates disconnecting the application from a wallet app.
class SolanaWalletDisconnectCard extends StatefulWidget {
  
  /// Creates a card that displays the connected [accounts] with a `disconnect` button.
  const SolanaWalletDisconnectCard({
    super.key,
    required this.adapter,
    required this.accounts,
    this.onTapAccount,
    this.onTapDisconnect,
    this.completer,
    this.dismissState,
  });

  /// The wallet adapter interface.
  final SolanaWalletAdapter adapter;

  /// The available wallet accounts.
  final List<Account> accounts;

  /// The on tap handler for [accounts] selection.
  final void Function(Account account)? onTapAccount;

  /// The on tap handler for the download button.
  final void Function()? onTapDisconnect;

  /// {@macro solana_wallet_provider.SolanaWalletMethodBuilder.completer}
  final Completer<DeauthorizeResult>? completer;

  /// {@macro solana_wallet_provider.SolanaWalletMethodBuilder.dismissState}
  final DismissState? dismissState;

  @override
  State<SolanaWalletDisconnectCard> createState() => _SolanaWalletDisconnectCardState();
}


/// Solana Wallet Account Card State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletDisconnectCardState extends State<SolanaWalletDisconnectCard> {

  /// The connected wallet account.
  Account? _selectedAccount;

  /// The deauthorize method call.
  Future<DeauthorizeResult>? _future;

  /// The wallet adapter interface.
  SolanaWalletAdapter get _adapter => widget.adapter;

  @override
  void initState() {
    super.initState();
    _selectedAccount = _adapter.connectedAccount;
  }

  /// Sets [_future] and invokes the wallet adapter's `deauthorize` method.
  void _initFuture() {
    if (mounted && _future == null) {
      _future = _adapter.deauthorize();
      setState(() {});
    }
  }

  /// Sets [_selectedAccount] and calls [SolanaWalletDisconnectCard.onTapAccount].
  void _onTapAccount(final Account account) {
    if (mounted && _selectedAccount != account) {
      setState(() => _selectedAccount = account);
      widget.onTapAccount?.call(account);
    }
  }

  /// Creates an icon image banner for the connected wallet application.
  Widget _banner(
    final BuildContext context, 
    final SolanaWalletModalBannerTheme? theme,
  ) => const SolanaWalletAppIcon();

  /// Builds a view for the current [AsyncSnapshot.connectionState].
  Widget _builder(
    final BuildContext context, 
    final AsyncSnapshot<DeauthorizeResult> snapshot,
  ) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        final List<Account> accounts = widget.accounts;
        return SolanaWalletModalBannerView(
          builder: _banner,
          title: const Text('Accounts'),
          body: accounts.isEmpty 
            ? const Text('No connected accounts.')
            : SolanaWalletAccountsView(
                accounts: widget.accounts, 
                selectedAccount: _selectedAccount, 
                onPressed: _onTapAccount,
              ),
          footer: accounts.isEmpty 
            ? null
            : TextButton(
                style: SolanaWalletThemeExtension.of(context)?.primaryButtonStyle,
                onPressed: _initFuture, // trigger _method()
                child: const Text('Disconnect'),
              ),
        );
      case ConnectionState.waiting:
      case ConnectionState.active:
        return SolanaWalletModalBannerView.opening();
      case ConnectionState.done:
        final Object? error = snapshot.error;
        return error != null
          ? SolanaWalletModalBannerView.error(
              error: error,
            )
          : SolanaWalletModalBannerView.success(
              message: const Text('Wallet disconnected.'),
            );
    }
  }

  @override
  Widget build(final BuildContext context) {
    return SolanaWalletModalCard(
      child: SolanaWalletMethodBuilder(
        future: _future, 
        completer: widget.completer, 
        dismissState: widget.dismissState,
        builder: _builder,
      ),
    );
  }
}