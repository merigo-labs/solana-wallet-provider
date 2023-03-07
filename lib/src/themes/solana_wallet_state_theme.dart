/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:ui';
import 'package:flutter/material.dart';
import '../layouts/solana_wallet_thickness.dart';
import '../../src/layouts/solana_wallet_grid.dart';
import '../../src/models/solana_wallet_method_state.dart';


/// Solana Wallet State View Theme
/// ------------------------------------------------------------------------------------------------

/// A theme that defines the style of a [SolanaWalletMethodState].
@immutable
class SolanaWalletStateTheme {

  /// The styles applied to a [SolanaWalletMethodState].
  const SolanaWalletStateTheme({
    this.none,
    this.progress,
    this.success,
    this.error,
  });

  /// The default styling of a [SolanaWalletMethodState.none] view.
  final SolanaWalletStateThemeData? none;

  /// The default styling of a [SolanaWalletMethodState.progress] view.
  final SolanaWalletStateThemeData? progress;

  /// The default styling of a [SolanaWalletMethodState.success] view.
  final SolanaWalletStateThemeData? success;

  /// The default styling of a [SolanaWalletMethodState.error] view.
  final SolanaWalletStateThemeData? error;

  /// Linearly interpolate between two [SolanaWalletStateTheme]s.
  static SolanaWalletStateTheme lerp(
    final SolanaWalletStateTheme? a, 
    final SolanaWalletStateTheme? b, 
    final double t,
  ) => SolanaWalletStateTheme(
    none: SolanaWalletStateThemeData.lerp(a?.none, b?.none, t),
    progress: SolanaWalletStateThemeData.lerp(a?.progress, b?.progress, t),
    success: SolanaWalletStateThemeData.lerp(a?.success, b?.success, t),
    error: SolanaWalletStateThemeData.lerp(a?.error, b?.error, t),
  );
}


/// Solana Wallet Method View Theme Data
/// ------------------------------------------------------------------------------------------------

class SolanaWalletStateThemeData {

  /// The theme used to style a [SolanaWalletMethodState].
  const SolanaWalletStateThemeData({
    this.iconBuilder,
    this.iconSize = SolanaWalletGrid.x1 * 8.0,
    this.iconColor,
    this.iconStrokeWidth = SolanaWalletThickness.x2,
  });

  /// Builds the icon and overrides all other styles.
  final Widget Function(BuildContext, SolanaWalletStateThemeData? theme)? iconBuilder;

  /// The icon size.
  final double iconSize;

  /// The icon color.
  final Color? iconColor;

  /// The icon stroke width.
  final double iconStrokeWidth;
  
  /// Linearly interpolate between two [SolanaWalletStateThemeData]s.
  static SolanaWalletStateThemeData lerp(
    final SolanaWalletStateThemeData? a, 
    final SolanaWalletStateThemeData? b, 
    final double t,
  ) => SolanaWalletStateThemeData(
    iconBuilder: b?.iconBuilder,
    iconSize: lerpDouble(a?.iconSize, b?.iconSize, t) 
      ?? SolanaWalletGrid.x1 * 8.0,
    iconColor: Color.lerp(a?.iconColor, b?.iconColor, t),
    iconStrokeWidth: lerpDouble(a?.iconStrokeWidth, b?.iconStrokeWidth, t) 
      ?? SolanaWalletThickness.x2,
  );
}