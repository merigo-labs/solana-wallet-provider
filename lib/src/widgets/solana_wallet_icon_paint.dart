/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../solana_wallet_provider.dart';


/// Solana Wallet Icon Painter
/// ------------------------------------------------------------------------------------------------

/// An icon widget.
class SolanaWalletIconPaint extends StatelessWidget {

  /// Creates an icon widget from [painter].
  const SolanaWalletIconPaint({
    super.key,
    required this.painter,
    this.size,
    this.child,
  });

  /// The icon painter's constructor.
  final CustomPainter Function({ required Color color, required double strokeWidth }) painter;

  /// The icon's width and height.
  final double? size;

  /// The inner content.
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SolanaWalletThemeExtension? themeExt = SolanaWalletThemeExtension.of(context);
    final SolanaWalletStateThemeData stateTheme = themeExt?.stateTheme?.progress
      ?? const SolanaWalletStateThemeData();
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size.square(size ?? stateTheme.iconSize),
          painter: painter(
            color: theme.dividerColor,
            strokeWidth: stateTheme.iconStrokeWidth,
          ),
        ),
        if (child != null)
          child ?? const SizedBox.shrink(),
      ],
    );
  }
}