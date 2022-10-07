/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../solana_wallet_icons.dart';
import '../themes/solana_wallet_theme_extension.dart';
import 'solana_wallet_icon_view.dart';


/// Solana Wallet Success View
/// ------------------------------------------------------------------------------------------------

class SolanaWalletSuccessView extends StatelessWidget {
  
  /// Creates a view that displays a success [message].
  const SolanaWalletSuccessView({
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
      title: title ?? 'Success', 
      message: message ?? 'All done.', 
      icon: Icon(
        SolanaWalletIcons.tick, 
        color: extension?.stateColor?.success, 
        size: SolanaWalletIcons.size,
      ),
    );
  }
}