/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import '../layouts/solana_wallet_layout_grid.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../widgets/solana_wallet_button.dart';
import '../widgets/solana_wallet_card.dart';
import '../widgets/solana_wallet_column.dart';


/// Solana Wallet Authorize View
/// ------------------------------------------------------------------------------------------------

class SolanaWalletAuthorizeView extends StatefulWidget {
  
  /// Creates a view that displays a `connect` button to authorize the application for use with a 
  /// Solana wallet.
  const SolanaWalletAuthorizeView({
    super.key,
    required this.identity,
    this.onTapAuthorize,
  });

  /// App information.
  final AppIdentity? identity;

  /// Called when the `connect` button is pressed.
  final VoidCallback? onTapAuthorize;

  @override
  State<SolanaWalletAuthorizeView> createState() => _SolanaWalletAuthorizeViewState();
}


/// Solana Wallet Authorize View State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletAuthorizeViewState extends State<SolanaWalletAuthorizeView> {

  @override
  Widget build(BuildContext context) {
    final SolanaWalletThemeExtension? extension = SolanaWalletThemeExtension.of(context);
    final String? name = widget.identity?.name;
    return SolanaWalletCard(
      title: 'Connect',
      child: SolanaWalletColumn(
        spacing: SolanaWalletLayoutGrid.x2,
        children: [
          Text.rich(
            TextSpan(
              text: 'Allow ',
              children: [
                TextSpan(
                  text: name ?? 'this app', 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: name ?? ' to connect with your Solana wallet.',
                ),
              ],
            ),
          ),
          SolanaWalletButton(
            onTap: widget.onTapAuthorize, 
            style: extension?.buttonStyle ?? SolanaWalletButtonStyle.styleFrom(),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}