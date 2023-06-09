/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../solana_wallet_provider.dart' show SolanaWalletProvider;
import 'solana_wallet_modal_banner_theme.dart';
import 'solana_wallet_modal_view_theme.dart';
import 'solana_wallet_modal_card_theme.dart';
import 'solana_wallet_qr_code_theme.dart';


/// Solana Wallet Theme Extension
/// ------------------------------------------------------------------------------------------------

/// A theme extension that defines styles for [SolanaWalletProvider]'s UI.
@immutable
class SolanaWalletThemeExtension extends ThemeExtension<SolanaWalletThemeExtension> {
  
  /// Styles for [SolanaWalletProvider]'s UI.
  const SolanaWalletThemeExtension({
    this.cardTheme,
    this.viewTheme,
    this.bannerTheme,
    this.qrCodeTheme,
    this.primaryButtonStyle,
    this.secondaryButtonStyle,
  });

  /// The modal card style.
  final SolanaWalletModalCardTheme? cardTheme;
  
  /// The modal view style.
  final SolanaWalletModalViewTheme? viewTheme;

  /// The modal view's banner style.
  final SolanaWalletModalBannerTheme? bannerTheme;

  /// The QR code style.
  final SolanaWalletQrCodeTheme? qrCodeTheme;

  /// Primary button style.
  final ButtonStyle? primaryButtonStyle;

  /// Secondary button style.
  final ButtonStyle? secondaryButtonStyle;
  
  /// Returns the [SolanaWalletThemeExtension] for the provided [context].
  static SolanaWalletThemeExtension? of(final BuildContext context)
    => Theme.of(context).extension<SolanaWalletThemeExtension>();

  @override
  ThemeExtension<SolanaWalletThemeExtension> copyWith({
    final SolanaWalletModalCardTheme? cardTheme,
    final SolanaWalletModalViewTheme? viewTheme,
    final SolanaWalletModalBannerTheme? bannerTheme,
    final SolanaWalletQrCodeTheme? qrCodeTheme,
    final ButtonStyle? primaryButtonStyle,
    final ButtonStyle? secondaryButtonStyle,
  }) => SolanaWalletThemeExtension(
      cardTheme: cardTheme ?? this.cardTheme,
      viewTheme: viewTheme ?? this.viewTheme,
      bannerTheme: bannerTheme ?? this.bannerTheme,
      qrCodeTheme: qrCodeTheme ?? this.qrCodeTheme,
      primaryButtonStyle: primaryButtonStyle ?? this.primaryButtonStyle,
      secondaryButtonStyle: secondaryButtonStyle ?? this.secondaryButtonStyle,
    );

  @override
  ThemeExtension<SolanaWalletThemeExtension> lerp(
    final ThemeExtension<SolanaWalletThemeExtension>? other, 
    final double t,
  ) {
    if (other is! SolanaWalletThemeExtension) { return this; }
    return SolanaWalletThemeExtension(
      cardTheme: SolanaWalletModalCardTheme.lerp(cardTheme, other.cardTheme, t),
      viewTheme: SolanaWalletModalViewTheme.lerp(viewTheme, other.viewTheme, t),
      bannerTheme: SolanaWalletModalBannerTheme.lerp(bannerTheme, other.bannerTheme, t),
      qrCodeTheme: SolanaWalletQrCodeTheme.lerp(qrCodeTheme, other.qrCodeTheme, t),
      primaryButtonStyle: ButtonStyle.lerp(primaryButtonStyle, other.primaryButtonStyle, t),
      secondaryButtonStyle: ButtonStyle.lerp(secondaryButtonStyle, other.secondaryButtonStyle, t),
    );
  }
}