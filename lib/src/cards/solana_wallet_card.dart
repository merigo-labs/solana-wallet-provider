/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_grid.dart';
import '../themes/solana_wallet_card_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../../src/widgets/solana_wallet_default_text_style.dart';


/// Solana Wallet Card
/// ------------------------------------------------------------------------------------------------

/// A [Card] widget.
class SolanaWalletCard extends StatefulWidget {
  
  /// Creates a [Card] widget.
  const SolanaWalletCard({
    super.key,
    this.color,
    this.margin,
    this.padding,
    this.headerColor,
    this.headerPadding,
    this.divider,
    this.bodyColor,
    this.bodyPadding,
    this.shape,
    this.header,
    required this.body,
  });

  /// The background color.
  final Color? color;

  /// The outer edge spacing.
  final EdgeInsets? margin;

  /// The inner edge padding.
  final EdgeInsets? padding;

  /// The header section's background color.
  final Color? headerColor;

  /// The header section's padding.
  final EdgeInsets? headerPadding;

  /// The widget placed between the [header] and [body].
  final Widget? divider;

  /// The body section's background color.
  final Color? bodyColor;

  /// The body section's padding.
  final EdgeInsets? bodyPadding;

  /// The shape.
  final ShapeBorder? shape;

  /// The heading.
  final Widget? header;

  /// The main content.
  final Widget body;

  @override
  State<SolanaWalletCard> createState() => _SolanaWalletCardState();
}


/// Solana Wallet Card State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletCardState extends State<SolanaWalletCard> {

  /// The default edge insets.
  EdgeInsets get _defaultInsets => const EdgeInsets.symmetric(
    horizontal: SolanaWalletGrid.x3,
    vertical: SolanaWalletGrid.x3,
  );

  @override
  Widget build(BuildContext context) {
    
    final ThemeData theme = Theme.of(context);
    final SolanaWalletCardTheme? cardTheme = SolanaWalletThemeExtension.of(context)?.cardTheme;
    
    final Widget? heading = widget.header;
    final Widget? header = heading != null ? _SolanaWalletCardSection(
      color: widget.headerColor ?? cardTheme?.headerColor,
      padding: widget.headerPadding ?? cardTheme?.headerPadding,
      textStyle: cardTheme?.headerTextStyle ?? theme.textTheme.titleLarge,
      child: heading,
    ) : null;

    final Widget body = _SolanaWalletCardSection(
      color: widget.bodyColor ?? cardTheme?.bodyColor,
      padding: widget.bodyPadding ?? cardTheme?.bodyPadding,
      textStyle: cardTheme?.bodyTextStyle ?? theme.textTheme.bodyMedium,
      child: widget.body,
    );

    return SafeArea(
      child: Card(
        color: widget.color ?? cardTheme?.color,
        margin: widget.margin ?? cardTheme?.margin ?? _defaultInsets,
        shape: widget.shape ?? cardTheme?.shape,
        child: Padding(
          padding: widget.padding ?? cardTheme?.padding ?? _defaultInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null)
                header,
              if (header != null && widget.divider != null)
                widget.divider ?? const SizedBox.shrink(),
              body,
            ],
          ),
        ),
      ),
    );
  }
}


/// Solana Wallet Card Section
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletCardSection extends StatelessWidget {

  /// Creates a padded, colored box.
  const _SolanaWalletCardSection({
    required this.color,
    required this.padding,
    required this.textStyle,
    required this.child,
  });

  /// The background color.
  final Color? color;

  /// The content padding.
  final EdgeInsets? padding;

  /// Default text style.
  final TextStyle? textStyle;

  /// The content.
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return ColoredBox(
      color: color ?? Colors.transparent,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: SolanaWalletDefaultTextStyle(
          style: textStyle, 
          child: child,
        ),
      ),
    );
  }
}