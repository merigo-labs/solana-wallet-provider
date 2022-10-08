/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../views/solana_wallet_connect_remotely_view.dart';


/// Solana Wallet Qr Code Theme
/// ------------------------------------------------------------------------------------------------

@immutable
class SolanaWalletQrCodeTheme with Diagnosticable {
  
  /// The theme used to style the QR code of a [SolanaWalletConnectRemotelyView].
  const SolanaWalletQrCodeTheme({
    this.size,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
    this.borderRadius,
  });

  /// The width and height dimension.
  final double? size;

  /// The content padding.
  final EdgeInsets? padding;

  /// The background colour.
  final Color? backgroundColor;

  /// The qr code colour.
  final Color? foregroundColor;
  
  /// The border style.
  final BoxBorder? border;
  
  /// The border radius.
  final BorderRadiusGeometry? borderRadius;

  /// Linearly interpolate between two [SolanaWalletQrCodeTheme].
  static SolanaWalletQrCodeTheme lerp(
    final SolanaWalletQrCodeTheme? a, 
    final SolanaWalletQrCodeTheme? b, 
    final double t,
  ) => SolanaWalletQrCodeTheme(
      size: lerpDouble(a?.size, b?.size, t),
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      foregroundColor: Color.lerp(a?.foregroundColor, b?.foregroundColor, t),
      border: BoxBorder.lerp(a?.border, b?.border, t),
      borderRadius: BorderRadiusGeometry.lerp(a?.borderRadius, b?.borderRadius, t),
    );
}