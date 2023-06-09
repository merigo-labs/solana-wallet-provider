/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../views/solana_wallet_modal_view.dart';


/// Solana Wallet Modal Banner Theme
/// ------------------------------------------------------------------------------------------------

/// A theme that defines the styles of [SolanaWalletModalView.banner] states.
@immutable
class SolanaWalletModalBannerTheme with Diagnosticable {
  
  /// The styles applied to [SolanaWalletModalView.banner] states.
  const SolanaWalletModalBannerTheme({
    this.progress,
    this.success,
    this.error,
  });

  /// The styling applied to a [SolanaWalletModalView.banner] generated for an `in progress` state.
  final SolanaWalletModalBannerThemeData? progress;

  /// The styling applied to a [SolanaWalletModalView.banner] generated for a `success` state.
  final SolanaWalletModalBannerThemeData? success;

  /// The styling applied to a [SolanaWalletModalView.banner] generated for an `error` state.
  final SolanaWalletModalBannerThemeData? error;

  /// Linearly interpolate between two [SolanaWalletModalBannerTheme]s.
  static SolanaWalletModalBannerTheme lerp(
    final SolanaWalletModalBannerTheme? a, 
    final SolanaWalletModalBannerTheme? b, 
    final double t,
  ) => SolanaWalletModalBannerTheme(
      progress: SolanaWalletModalBannerThemeData.lerp(a?.progress, b?.progress, t),
      success: SolanaWalletModalBannerThemeData.lerp(a?.success, b?.success, t),
      error: SolanaWalletModalBannerThemeData.lerp(a?.error, b?.error, t),
    );
}


/// Solana Wallet Method View Theme Data
/// ------------------------------------------------------------------------------------------------

/// A theme that defines the style of a [SolanaWalletModalView.banner].
class SolanaWalletModalBannerThemeData {

  /// Creates a theme that defines the style of a [SolanaWalletModalView.banner].
  const SolanaWalletModalBannerThemeData({
    this.builder,
    this.color,
  });

  /// Builds the banner widget.
  final Widget Function(BuildContext)? builder;

  /// The state's color.
  final Color? color;
  
  /// Linearly interpolate between two [SolanaWalletModalBannerThemeData]s.
  static SolanaWalletModalBannerThemeData lerp(
    final SolanaWalletModalBannerThemeData? a, 
    final SolanaWalletModalBannerThemeData? b, 
    final double t,
  ) => SolanaWalletModalBannerThemeData(
    builder: b?.builder,
    color: Color.lerp(a?.color, b?.color, t),
  );
}