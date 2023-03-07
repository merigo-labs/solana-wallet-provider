/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';


/// Solana Wallet Default Text Style
/// ------------------------------------------------------------------------------------------------

class SolanaWalletDefaultTextStyle extends StatelessWidget {
  
  /// Wraps [child] in a [DefaultTextStyle].
  const SolanaWalletDefaultTextStyle({
    super.key,
    required this.style,
    required this.child,
  });

  /// The default text style applied to [child].
  final TextStyle? style;

  /// The content.
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final TextStyle? textStyle = style;
    return textStyle != null
      ? DefaultTextStyle(
          textAlign: TextAlign.center,
          style: textStyle, 
          child: child,
        )
      : child;
  }
}