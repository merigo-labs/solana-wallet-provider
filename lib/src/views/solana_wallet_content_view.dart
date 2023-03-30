/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../solana_wallet_provider.dart';
import '../../src/layouts/solana_wallet_grid.dart';
import '../../src/widgets/solana_wallet_default_text_style.dart';


/// Solana Wallet Content View
/// ------------------------------------------------------------------------------------------------

/// The default view layout.
class SolanaWalletContentView extends StatelessWidget {

  /// Creates a structure view.
  const SolanaWalletContentView({
    super.key,
    this.header,
    this.title,
    this.message,
    this.body,
  });

  /// The header.
  final Widget? header;

  /// The view title.
  final Widget? title;
  
  /// The view description.
  final Widget? message;

  /// The main content.
  final Widget? body;

  @override
  Widget build(final BuildContext context) {
    final SolanaWalletCardTheme? cardTheme = SolanaWalletThemeExtension.of(context)?.cardTheme;
    return SolanaWalletColumnView(
      spacing: SolanaWalletGrid.x3,
      children: [
        if (header != null)
          header,
        if (title != null || message != null)
          SolanaWalletColumnView(
            spacing: SolanaWalletGrid.x1,
            children: [
              if (title != null)
                SolanaWalletDefaultTextStyle(
                  style: cardTheme?.titleTextStyle 
                    ?? Theme.of(context).textTheme.titleSmall, 
                  child: title!,
                ), 
              if (message != null)
                message,
            ],
          ),
        if (body != null)
          body,
      ],
    );
  }
}