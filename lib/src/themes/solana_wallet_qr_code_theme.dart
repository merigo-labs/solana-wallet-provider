/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:ui';
import 'package:flutter/foundation.dart' show Diagnosticable;
import 'package:flutter/material.dart';


/// Solana Wallet Qr Code Theme
/// ------------------------------------------------------------------------------------------------

/// A theme that defines the style of a QR code.
@immutable
class SolanaWalletQrCodeTheme with Diagnosticable {
  
  /// The styles applied to a QR code.
  const SolanaWalletQrCodeTheme({
    this.size,
    this.border,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The width and height dimension.
  final double? size;

  /// The border style.
  final BoxBorder? border;

  /// The border radius.
  final BorderRadius? borderRadius;

  /// The content padding.
  final EdgeInsets? padding;

  /// The background colour.
  final Color? backgroundColor;

  /// The qr code colour.
  final Color? foregroundColor;

  /// Linearly interpolate between two [SolanaWalletQrCodeTheme]s.
  static SolanaWalletQrCodeTheme lerp(
    final SolanaWalletQrCodeTheme? a, 
    final SolanaWalletQrCodeTheme? b, 
    final double t,
  ) => SolanaWalletQrCodeTheme(
      size: lerpDouble(a?.size, b?.size, t),
      border: BoxBorder.lerp(a?.border, b?.border, t),
      borderRadius: BorderRadius.lerp(a?.borderRadius, b?.borderRadius, t),
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      foregroundColor: Color.lerp(a?.foregroundColor, b?.foregroundColor, t),
    );
}