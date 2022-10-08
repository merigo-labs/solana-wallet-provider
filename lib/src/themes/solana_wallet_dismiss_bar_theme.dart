/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/solana_wallet_dismiss_bar.dart';


/// Solana Wallet Dismiss Bar Theme
/// ------------------------------------------------------------------------------------------------

@immutable
class SolanaWalletDismissBarTheme {
  
  /// The theme used to style a [SolanaWalletDismissBar].
  const SolanaWalletDismissBarTheme({
    this.width,
    this.height,
    this.color,
    this.borderRadius,
  });

  /// The width.
  final double? width;

  /// The thickness.
  final double? height;

  /// The line colour.
  final Color? color;

  /// The border radius.
  final BorderRadiusGeometry? borderRadius;

  /// Linearly interpolate between two [SolanaWalletDismissBarTheme].
  static SolanaWalletDismissBarTheme lerp(
    final SolanaWalletDismissBarTheme? a, 
    final SolanaWalletDismissBarTheme? b, 
    final double t,
  ) => SolanaWalletDismissBarTheme(
      width: lerpDouble(a?.width, b?.width, t),
      height: lerpDouble(a?.height, b?.height, t),
      color: Color.lerp(a?.color, b?.color, t),
      borderRadius: BorderRadiusGeometry.lerp(a?.borderRadius, b?.borderRadius, t),
    );
}