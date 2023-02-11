/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_grid.dart';
import '../themes/solana_wallet_card_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';


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
    this.titlePadding,
    this.bodyPadding,
    this.spacing,
    this.shape,
    this.title,
    required this.body,
  });

  /// The background color.
  final Color? color;

  /// The outer edge spacing.
  final EdgeInsets? margin;

  /// The inner edge padding.
  final EdgeInsets? padding;

  /// The title section padding.
  final EdgeInsets? titlePadding;

  /// The body section padding.
  final EdgeInsets? bodyPadding;

  /// The vertical space between the [title] and [body].
  final double? spacing;

  /// The shape.
  final ShapeBorder? shape;

  /// The heading.
  final Widget? title;

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
    horizontal: SolanaWalletGrid.x2,
    vertical: SolanaWalletGrid.x3,
  );

  @override
  Widget build(BuildContext context) {
    
    final ThemeData theme = Theme.of(context);
    final SolanaWalletCardTheme? cardTheme = SolanaWalletThemeExtension.of(context)?.cardTheme;
    final TextStyle? titleStyle = cardTheme?.titleTextStyle ?? theme.textTheme.titleLarge;
    final TextStyle? bodyStyle = cardTheme?.bodyTextStyle ?? theme.textTheme.bodyLarge;
    final Widget? title = widget.title;
    
    final Widget header = Padding(
      padding: widget.titlePadding ?? cardTheme?.titlePadding ?? const EdgeInsets.all(0),
      child: widget.title,
    );

    final Widget body = Padding(
      padding: widget.bodyPadding ?? cardTheme?.bodyPadding ?? const EdgeInsets.all(0),
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
              if (title != null)
                titleStyle != null
                  ? DefaultTextStyle(
                      style: titleStyle, 
                      textAlign: TextAlign.center,
                      child: header,
                    )
                  : header,
              if (title != null)
                SizedBox(
                  height: widget.spacing ?? cardTheme?.spacing ?? SolanaWalletGrid.x3,
                ),
              bodyStyle != null
                ? DefaultTextStyle(
                    style: bodyStyle, 
                    textAlign: TextAlign.center,
                    child: body,
                  )
                : body,
            ],
          ),
        ),
      ),
    );
  }
}