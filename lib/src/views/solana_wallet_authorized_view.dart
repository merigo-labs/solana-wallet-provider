/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../solana_wallet_provider.dart';
import '../../src/widgets/solana_wallet_text_overflow.dart';


/// Solana Wallet Authorized View
/// ------------------------------------------------------------------------------------------------

/// App authorized view.
class SolanaWalletAuthorizedView extends StatefulWidget {

  /// Creates a view that displays the [result] or an authorization request.
  const SolanaWalletAuthorizedView({
    super.key,
    required this.result,
    this.app,
  });

  /// The authorizatio result.
  final AuthorizeResult? result;

  /// The authorized app.
  final AppInfo? app;

  @override
  State<SolanaWalletAuthorizedView> createState() => _SolanaWalletAuthorizedViewState();
}


/// Solana Wallet Authorized View State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletAuthorizedViewState extends State<SolanaWalletAuthorizedView> {
  
  /// Build the view's icon.
  Widget _iconBuilder(final BuildContext context, final SolanaWalletStateThemeData theme) {
    final AssetImage? icon = widget.app?.icon;
    return icon != null 
      ? SolanaWalletStateView.imageBuilder(icon, theme.iconSize)
      : SolanaWalletStateView.successBuilder(context, theme);
  }

  /// Displays the account view.
  void _onTapChange() {
    SolanaWalletProvider.close(context);
    final provider = SolanaWalletProvider.of(context);
    provider.disconnect(context).ignore();
  }

  @override
  Widget build(final BuildContext context) {
    final List<Account>? accounts = widget.result?.accounts;
    final Account? account = accounts != null && accounts.isNotEmpty ? accounts.first : null;
    return SolanaWalletStateView(
      iconBuilder: _iconBuilder,
      state: SolanaWalletMethodState.success,
      title: const Text('Wallet Connected'), 
      message: account != null
        ? SolanaWalletTextOverflow(text: account.addressBase58)
        : null,
      body: TextButton(
        onPressed: _onTapChange, 
        style: SolanaWalletThemeExtension.of(context)?.secondaryButtonStyle,
        child: const Text('Change'),
      ),
    );
  }
}