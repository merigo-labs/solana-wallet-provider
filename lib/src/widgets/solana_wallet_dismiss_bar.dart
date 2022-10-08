/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_layout_grid.dart';
import '../solana_wallet_constants.dart';
import '../solana_wallet_icons.dart';
import '../themes/solana_wallet_dismiss_bar_theme.dart';


/// Solana Wallet Dismiss Bar
/// ------------------------------------------------------------------------------------------------

class SolanaWalletDismissBar extends StatelessWidget {
  
  /// Draws a horizontal bar.
  const SolanaWalletDismissBar({
    super.key,
    this.theme,
  });

  /// The style properties.
  final SolanaWalletDismissBarTheme? theme;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final double thickness = theme?.height ?? SolanaWalletIcons.strokeWidth;
    return SizedBox(
      width: theme?.width ?? SolanaWalletLayoutGrid.multiply(6.0),
      height: thickness,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme?.color ?? dividerColourOf(themeData),
          borderRadius: theme?.borderRadius ?? BorderRadius.circular(thickness * 0.5),
        ),
      ),
    );
  }
}