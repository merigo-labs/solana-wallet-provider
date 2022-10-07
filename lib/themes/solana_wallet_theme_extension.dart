/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_provider/themes/solana_wallet_state_color.dart';
import '../widgets/solana_wallet_button.dart';
import 'solana_wallet_card_theme.dart';
import 'solana_wallet_dismiss_bar_theme.dart';
import 'solana_wallet_qr_code_theme.dart';


/// Solana Wallet Theme Extension
/// ------------------------------------------------------------------------------------------------

@immutable
class SolanaWalletThemeExtension extends ThemeExtension<SolanaWalletThemeExtension> {
  
  /// Styles the wallet adapter's UI.
  const SolanaWalletThemeExtension({
    this.cardTheme,
    this.barTheme,
    this.titleTextStyle,
    this.bodyTextStyle,
    this.qrCodeTheme,
    this.stateColor,
    this.linkColor,
    this.buttonStyle,
  });
  
  /// The card style.
  final SolanaWalletCardTheme? cardTheme;

  /// The bar style.
  final SolanaWalletDismissBarTheme? barTheme;

  /// The title text style.
  final TextStyle? titleTextStyle;

  /// The body text style.
  final TextStyle? bodyTextStyle;

  /// The QR code style.
  final SolanaWalletQrCodeTheme? qrCodeTheme;

  /// The icon colours for each state.
  final SolanaWalletStateColor? stateColor;

  /// The colour applied to hyperlink text.
  final Color? linkColor;

  /// The style applied to buttons.
  final SolanaWalletButtonStyle? buttonStyle;

  /// Returns the [SolanaWalletThemeExtension] for the provided [context].
  static SolanaWalletThemeExtension? of(final BuildContext context)
    => Theme.of(context).extension<SolanaWalletThemeExtension>();

  @override
  ThemeExtension<SolanaWalletThemeExtension> copyWith({
    final SolanaWalletCardTheme? cardTheme,
    final SolanaWalletDismissBarTheme? barTheme,
    final TextStyle? titleTextStyle, 
    final TextStyle? bodyTextStyle,
    final SolanaWalletQrCodeTheme? qrCodeTheme,
    final SolanaWalletStateColor? stateColor,
    final Color? linkColor,
    final SolanaWalletButtonStyle? buttonStyle,
  }) => SolanaWalletThemeExtension(
      cardTheme: cardTheme ?? this.cardTheme,
      barTheme: barTheme ?? this.barTheme,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      bodyTextStyle: bodyTextStyle ?? this.bodyTextStyle,
      qrCodeTheme: qrCodeTheme ?? this.qrCodeTheme,
      stateColor: stateColor ?? this.stateColor,
      linkColor: linkColor ?? this.linkColor,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );

  @override
  ThemeExtension<SolanaWalletThemeExtension> lerp(
    final ThemeExtension<SolanaWalletThemeExtension>? other, 
    final double t,
  ) {
    if (other is! SolanaWalletThemeExtension) { return this; }
    return SolanaWalletThemeExtension(
      cardTheme: SolanaWalletCardTheme.lerp(cardTheme, other.cardTheme, t),
      barTheme: SolanaWalletDismissBarTheme.lerp(barTheme, other.barTheme, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t),
      bodyTextStyle: TextStyle.lerp(bodyTextStyle, other.bodyTextStyle, t),
      qrCodeTheme: SolanaWalletQrCodeTheme.lerp(qrCodeTheme, other.qrCodeTheme, t),
      stateColor: SolanaWalletStateColor.lerp(stateColor, other.stateColor, t),
      linkColor: Color.lerp(linkColor, other.linkColor, t),
      buttonStyle: SolanaWalletButtonStyle.lerp(buttonStyle, other.buttonStyle, t),
    );
  }
}