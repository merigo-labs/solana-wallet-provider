/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'solana_wallet_provider.dart';
import 'src/models/solana_wallet_action.dart';
import 'src/solana_wallet_icons.dart';
import 'src/widgets/solana_wallet_button.dart';


/// Solana Wallet Provider Button
/// ------------------------------------------------------------------------------------------------

class SolanaWalletProviderButton extends StatefulWidget {
  
  /// Connects the dApp to a wallet endpoint.
  const SolanaWalletProviderButton({
    super.key,
    this.child,
    this.style,
    this.onPressed,
    this.onChanged,
  });

  /// The content.
  final Widget? child;

  /// The button's style.
  final SolanaWalletButtonStyle? style;

  /// Called when the button is tapped or otherwise activated.
  final VoidCallback? onPressed;

  /// Called when a new account is selected.
  final void Function(Account account)? onChanged;

  @override
  State<SolanaWalletProviderButton> createState() => _SolanaWalletProviderButtonState();
}


/// Solana Wallet Provider Button State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletProviderButtonState extends State<SolanaWalletProviderButton> {

  /// The wallet provider.
  late SolanaWalletProviderState provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = SolanaWalletProvider.of(context);
  }

  /// Displays the user's authorized accounts and handles the view's action.
  Future<void> _showAccountView() async {
    final SolanaWalletAction? action = await provider.showAccountView();
    if (action is ChangeAccountAction) {
      await provider.adapter.setFeePayerAccount(action.data);
      widget.onChanged?.call(action.data);
    } else if (action is DeauthorizeAction) {
      await provider.deauthorize();
      await provider.showSuccessView(message: 'Wallet disconnected.');
    }
  }

  /// Initialises dApp authorisation and handles the view's action.
  Future<void> _showAuthorizeView() async {
    final SolanaWalletAction? action = await provider.showAuthorizeView();
    if (action is AuthorizeAction) {
      await provider.authorize();
      if (provider.feePayerAccount != null) {
        await provider.showSuccessView(message: 'Wallet connected.');
      } else {
        _showAccountView();
      }
    }
  }

  /// Connect a wallet account with the dApp.
  void _onPressed() async {
    try {
      widget.onPressed?.call();
      final List<Account>? accounts = provider.authorizeResult?.accounts;
      await (accounts != null ? _showAccountView() : _showAuthorizeView());
    } catch (error) {
      final String? message = error is SolanaWalletAdapterException ? error.message : null;
      provider.showErrorView(message: message).ignore();
    }
  }

  /// The default widget content.
  Widget _child() {
    return const Icon(
      SolanaWalletIcons.wallet,
      semanticLabel: 'Accounts',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SolanaWalletButton(
      onTap: _onPressed,
      style: widget.style,
      child: widget.child ?? _child(),
    );
  }
}