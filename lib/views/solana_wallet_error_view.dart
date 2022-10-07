/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_provider/views/solana_wallet_icon_view.dart';
import '../solana_wallet_icons.dart';
import '../themes/solana_wallet_theme_extension.dart';


/// Solana Wallet Error View
/// ------------------------------------------------------------------------------------------------

class SolanaWalletErrorView extends StatelessWidget {
  
  /// Creates a view that displays an error [message].
  const SolanaWalletErrorView({
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
      title: title ?? 'Oops', 
      message: message ?? 'Something went wrong.', 
      icon: Icon(
        SolanaWalletIcons.exclamationMark, 
        color: extension?.stateColor?.error, 
        size: SolanaWalletIcons.size,
      ),
    );
  }
}