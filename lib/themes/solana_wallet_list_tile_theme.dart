/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/solana_wallet_list_tile.dart';


/// Solana Wallet List Tile Theme
/// ------------------------------------------------------------------------------------------------

@immutable
class SolanaWalletListTileTheme with Diagnosticable {
  
  /// The theme used to style a [SolanaWalletListTile].
  const SolanaWalletListTileTheme({
    this.padding,
    this.spacing,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.color,
    this.shape,
  });

  /// The content padding.
  final EdgeInsets? padding;

  /// The horizontal space between items.
  final double? spacing;

  /// The title's text style.
  final TextStyle? titleTextStyle;

  /// The subtitle's text style.
  final TextStyle? subtitleTextStyle;

  /// The background colour.
  final Color? color;

  /// The shape.
  final ShapeBorder? shape;

  /// Linearly interpolate between two [SolanaWalletListTileTheme].
  static SolanaWalletListTileTheme lerp(
    final SolanaWalletListTileTheme? a, 
    final SolanaWalletListTileTheme? b, 
    final double t,
  ) => SolanaWalletListTileTheme(
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
      spacing: lerpDouble(a?.spacing, b?.spacing, t),
      titleTextStyle: TextStyle.lerp(a?.titleTextStyle, b?.titleTextStyle, t),
      subtitleTextStyle: TextStyle.lerp(a?.subtitleTextStyle, b?.subtitleTextStyle, t),
      color: Color.lerp(a?.color, b?.color, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
    );
}