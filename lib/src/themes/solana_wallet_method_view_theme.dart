/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_thickness.dart';
import '../../src/layouts/solana_wallet_grid.dart';
import '../../src/models/solana_wallet_method_state.dart';
import '../../src/views/solana_wallet_method_view.dart';


/// Solana Wallet Method View Theme
/// ------------------------------------------------------------------------------------------------

/// A theme that defines the style of a [SolanaWalletMethodView].
@immutable
class SolanaWalletMethodViewTheme {

  /// The styles applied to a [SolanaWalletMethodView].
  const SolanaWalletMethodViewTheme({
    this.none,
    this.progress,
    this.success,
    this.error,
  });

  /// The default styling of a [SolanaWalletMethodState.none] view.
  final SolanaWalletMethodViewThemeData? none;

  /// The default styling of a [SolanaWalletMethodState.progress] view.
  final SolanaWalletMethodViewThemeData? progress;

  /// The default styling of a [SolanaWalletMethodState.success] view.
  final SolanaWalletMethodViewThemeData? success;

  /// The default styling of a [SolanaWalletMethodState.error] view.
  final SolanaWalletMethodViewThemeData? error;
}


/// Solana Wallet Method View Theme Data
/// ------------------------------------------------------------------------------------------------

class SolanaWalletMethodViewThemeData {

  /// The theme used to style a [SolanaWalletMethodView].
  const SolanaWalletMethodViewThemeData({
    this.iconBuilder,
    this.iconSize = SolanaWalletGrid.x1 * 8.0,
    this.iconColor,
    this.iconStrokeWidth = SolanaWalletThickness.x2,
  });

  /// Builds the icon and overrides all other styles.
  final Widget Function(BuildContext, SolanaWalletMethodViewThemeData? theme)? iconBuilder;

  /// The icon size.
  final double iconSize;

  /// The icon color.
  final Color? iconColor;

  /// The icon stroke width.
  final double iconStrokeWidth;
}