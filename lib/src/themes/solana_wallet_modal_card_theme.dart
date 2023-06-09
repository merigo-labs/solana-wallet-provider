/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../cards/solana_wallet_modal_card.dart';


/// Solana Wallet Modal Card Theme
/// ------------------------------------------------------------------------------------------------

/// A theme that defines the style of a [SolanaWalletModalCard].
@immutable
class SolanaWalletModalCardTheme with Diagnosticable {
  
  /// The styles applied to a [SolanaWalletModalCard].
  const SolanaWalletModalCardTheme({
    this.color,
    this.margin,
    this.padding,
    this.shape,
  });

  /// The background color.
  final Color? color;

  /// The outer edge spacing.
  final EdgeInsets? margin;

  /// The inner edge padding.
  final EdgeInsets? padding;

  /// The shape.
  final ShapeBorder? shape;

  /// Linearly interpolate between two [SolanaWalletModalCardTheme]s.
  static SolanaWalletModalCardTheme lerp(
    final SolanaWalletModalCardTheme? a, 
    final SolanaWalletModalCardTheme? b, 
    final double t,
  ) => SolanaWalletModalCardTheme(
      color: Color.lerp(a?.color, b?.color, t),
      margin: EdgeInsets.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
    );
}