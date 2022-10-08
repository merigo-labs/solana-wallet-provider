/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_icon_view.dart';
import '../solana_wallet_icons.dart';
import '../themes/solana_wallet_theme_extension.dart';


/// Solana Wallet Timed Out View
/// ------------------------------------------------------------------------------------------------

class SolanaWalletTimedOutView extends StatelessWidget {
  
  /// Creates a view that displays a `timed out` error [message].
  const SolanaWalletTimedOutView({
    super.key,
    this.title,
    this.message,
  });

  /// The card title.
  final String? title;

  /// The displayed message.
  final String? message;

  @override
  Widget build(final BuildContext context) {
    final SolanaWalletThemeExtension? extension = SolanaWalletThemeExtension.of(context);
    return SolanaWalletIconView(
      title: title ?? 'Timed Out', 
      message: message ?? 'The request has timed out, please try again.', 
      icon: Icon(
        SolanaWalletIcons.tick, 
        color: extension?.stateColor?.error, 
        size: SolanaWalletIcons.size,
      ),
    );
  }
}