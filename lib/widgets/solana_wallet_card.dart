/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_dismiss_bar.dart';
import '../solana_wallet_constants.dart';
import '../layouts/solana_wallet_layout_grid.dart';
import '../themes/solana_wallet_card_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';


/// Solana Wallet Card
/// ------------------------------------------------------------------------------------------------

class SolanaWalletCard extends StatelessWidget {
  
  /// Creates a card to display UI content.
  const SolanaWalletCard({
    super.key,
    required this.title,
    required this.child,
  });

  /// The title.
  final String title;

  /// The content.
  final Widget? child;

  /// Returns the widget's default theme.
  SolanaWalletCardTheme defaultCardTheme(final ThemeData theme)
    => SolanaWalletCardTheme(
      margin: const EdgeInsets.all(
        SolanaWalletLayoutGrid.x2,
      ),
      padding: const EdgeInsets.all(
        SolanaWalletLayoutGrid.x3,
      ),
      color: cardColourOf(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          SolanaWalletLayoutGrid.x2,
        ),
      ),
    );

  /// Returns the title's default style.
  TextStyle defaultTitltTextStyle()
    => const TextStyle(
      fontSize: fontSize + 2, 
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
    );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SolanaWalletThemeExtension? extension = SolanaWalletThemeExtension.of(context);
    final SolanaWalletCardTheme defaultCardTheme = this.defaultCardTheme(theme);
    final SolanaWalletCardTheme? cardTheme = extension?.cardTheme;
    final EdgeInsets padding = cardTheme?.padding ?? defaultCardTheme.padding!;
    return Container(
      margin: cardTheme?.margin ?? defaultCardTheme.margin,
      child: Material(
        type: MaterialType.card,
        color: cardTheme?.color ?? defaultCardTheme.color,
        shape: cardTheme?.shape ?? defaultCardTheme.shape,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: SolanaWalletLayoutGrid.x2,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: padding.left,
                right: padding.right,
              ),
              child: SolanaWalletDismissBar(
                theme: extension?.barTheme,
              ),
            ),
            const SizedBox(
              height: SolanaWalletLayoutGrid.x3,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: padding.left,
                right: padding.right,
              ),
              child: Text(
                title,
                style: extension?.titleTextStyle ?? defaultTitltTextStyle(),
              ),
            ),
            Flexible(
              child: DefaultTextStyle(
                textAlign: TextAlign.center,
                style: extension?.bodyTextStyle ?? TextStyle(
                  fontSize: fontSize, 
                  color: subtextColourOf(theme),
                ),
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}