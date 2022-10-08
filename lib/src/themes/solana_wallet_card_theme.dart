/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/solana_wallet_card.dart';


/// Solana Wallet Card Theme
/// ------------------------------------------------------------------------------------------------

@immutable
class SolanaWalletCardTheme with Diagnosticable {
  
  /// The theme used to style a [SolanaWalletCard].
  const SolanaWalletCardTheme({
    this.margin,
    this.padding,
    this.color,
    this.shape,
    this.titleTextStyle,
    this.bodyTextStyle,
  });

  /// The outer spacing.
  final EdgeInsets? margin;

  /// The content padding.
  final EdgeInsets? padding;

  /// The background colour.
  final Color? color;

  /// The shape.
  final ShapeBorder? shape;

  /// The title text style.
  final TextStyle? titleTextStyle;

  /// The body text style.
  final TextStyle? bodyTextStyle;

  /// Linearly interpolate between two [SolanaWalletCardTheme].
  static SolanaWalletCardTheme lerp(
    final SolanaWalletCardTheme? a, 
    final SolanaWalletCardTheme? b, 
    final double t,
  ) => SolanaWalletCardTheme(
      margin: EdgeInsets.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
      color: Color.lerp(a?.color, b?.color, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
      titleTextStyle: TextStyle.lerp(a?.titleTextStyle, b?.bodyTextStyle, t),
    );
}