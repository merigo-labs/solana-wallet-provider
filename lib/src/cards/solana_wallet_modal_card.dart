/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_grid.dart';
import '../themes/solana_wallet_modal_card_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';


/// Solana Wallet Modal Card
/// ------------------------------------------------------------------------------------------------

/// A modal [Card] widget.
class SolanaWalletModalCard extends StatelessWidget {
  
  /// Creates a modal [Card] widget.
  const SolanaWalletModalCard({
    super.key,
    this.color,
    this.margin,
    this.padding,
    this.shape,
    required this.child,
  });

  /// The card's background color.
  final Color? color;

  /// The outer edge spacing.
  final EdgeInsets? margin;

  /// The inner edge padding.
  final EdgeInsets? padding;

  /// The card's shape.
  final ShapeBorder? shape;

  /// The main content.
  final Widget child;

  /// The default edge insets.
  EdgeInsets get _defaultInsets => const EdgeInsets.all(SolanaWalletGrid.x3);

  @override
  Widget build(final BuildContext context) {
    final SolanaWalletModalCardTheme? theme = SolanaWalletThemeExtension.of(context)?.cardTheme;
    return SafeArea(
      child: Card(
        color: color ?? theme?.color,
        margin: margin ?? theme?.margin ?? _defaultInsets,
        shape: shape ?? theme?.shape,
        child: Padding(
          padding: padding ?? theme?.padding ?? _defaultInsets,
          child: child,
        ),
      ),
    );
  }
}