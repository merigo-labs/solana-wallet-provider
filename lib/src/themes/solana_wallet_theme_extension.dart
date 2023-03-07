/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_card_theme.dart';
import 'solana_wallet_qr_code_theme.dart';
import 'solana_wallet_state_theme.dart';


/// Solana Wallet Theme Extension
/// ------------------------------------------------------------------------------------------------

/// A theme extension that defines styles for [SolanaWalletProvider]'s UI.
@immutable
class SolanaWalletThemeExtension extends ThemeExtension<SolanaWalletThemeExtension> {
  
  /// Styles for [SolanaWalletProvider]'s UI.
  const SolanaWalletThemeExtension({
    this.cardTheme,
    this.qrCodeTheme,
    this.primaryButtonStyle,
    this.secondaryButtonStyle,
    this.stateTheme,
  });
  
  /// The card style.
  final SolanaWalletCardTheme? cardTheme;

  /// The QR code style.
  final SolanaWalletQrCodeTheme? qrCodeTheme;

  /// Primary button style.
  final ButtonStyle? primaryButtonStyle;

  /// Secondary button style.
  final ButtonStyle? secondaryButtonStyle;
  
  /// The state view styles.
  final SolanaWalletStateTheme? stateTheme;

  /// Returns the [SolanaWalletThemeExtension] for the provided [context].
  static SolanaWalletThemeExtension? of(final BuildContext context)
    => Theme.of(context).extension<SolanaWalletThemeExtension>();

  @override
  ThemeExtension<SolanaWalletThemeExtension> copyWith({
    final SolanaWalletCardTheme? cardTheme,
    final SolanaWalletQrCodeTheme? qrCodeTheme,
    final ButtonStyle? primaryButtonStyle,
    final ButtonStyle? secondaryButtonStyle,
    final SolanaWalletStateTheme? stateTheme,
  }) => SolanaWalletThemeExtension(
      cardTheme: cardTheme ?? this.cardTheme,
      qrCodeTheme: qrCodeTheme ?? this.qrCodeTheme,
      primaryButtonStyle: primaryButtonStyle ?? this.primaryButtonStyle,
      secondaryButtonStyle: secondaryButtonStyle ?? this.secondaryButtonStyle,
      stateTheme: stateTheme ?? this.stateTheme,
    );

  @override
  ThemeExtension<SolanaWalletThemeExtension> lerp(
    final ThemeExtension<SolanaWalletThemeExtension>? other, 
    final double t,
  ) {
    if (other is! SolanaWalletThemeExtension) { return this; }
    return SolanaWalletThemeExtension(
      cardTheme: SolanaWalletCardTheme.lerp(cardTheme, other.cardTheme, t),
      qrCodeTheme: SolanaWalletQrCodeTheme.lerp(qrCodeTheme, other.qrCodeTheme, t),
      primaryButtonStyle: ButtonStyle.lerp(primaryButtonStyle, other.primaryButtonStyle, t),
      secondaryButtonStyle: ButtonStyle.lerp(secondaryButtonStyle, other.secondaryButtonStyle, t),
      stateTheme: SolanaWalletStateTheme.lerp(stateTheme, other.stateTheme, t),
    );
  }
}