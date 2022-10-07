/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';


/// Solana Wallet State Color
/// ------------------------------------------------------------------------------------------------

class SolanaWalletStateColor {
  
  /// The colours applied when represented different states.
  const SolanaWalletStateColor({
    this.success,
    this.error,
    this.selected,
  });

  /// The success colour.
  final Color? success;

  /// The error colour.
  final Color? error;

  /// The selected colour.
  final Color? selected;

  /// Sets [color] for all states.
  factory SolanaWalletStateColor.all(final Color? color) => SolanaWalletStateColor(
    success: color,
    error: color,
    selected: color,
  );

  /// Linearly interpolate between two [SolanaWalletStateColor].
  static SolanaWalletStateColor lerp(
    final SolanaWalletStateColor? a, 
    final SolanaWalletStateColor? b, 
    final double t,
  ) => SolanaWalletStateColor(
      success: Color.lerp(a?.success, b?.success, t),
      error: Color.lerp(a?.error, b?.error, t),
      selected: Color.lerp(a?.selected, b?.selected, t),
    ); 
}