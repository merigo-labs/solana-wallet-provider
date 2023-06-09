/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../views/solana_wallet_modal_view.dart';


/// Solana Wallet Modal View Theme
/// ------------------------------------------------------------------------------------------------

/// A theme that defines the style of a [SolanaWalletModalView].
@immutable
class SolanaWalletModalViewTheme with Diagnosticable {
  
  /// The styles applied to a [SolanaWalletModalView].
  const SolanaWalletModalViewTheme({
    this.titleTextStyle,
    this.bodyTextStyle,
    this.spacing,
  });

  /// The title text style.
  final TextStyle? titleTextStyle;

  /// The body text style.
  final TextStyle? bodyTextStyle;

  /// The vertical item spacing.
  final double? spacing;

  /// Linearly interpolate between two [SolanaWalletModalViewTheme]s.
  static SolanaWalletModalViewTheme lerp(
    final SolanaWalletModalViewTheme? a, 
    final SolanaWalletModalViewTheme? b, 
    final double t,
  ) => SolanaWalletModalViewTheme(
      titleTextStyle: TextStyle.lerp(a?.titleTextStyle, b?.titleTextStyle, t),
      bodyTextStyle: TextStyle.lerp(a?.bodyTextStyle, b?.bodyTextStyle, t),
      spacing: lerpDouble(a?.spacing, b?.spacing, t),
    );
}