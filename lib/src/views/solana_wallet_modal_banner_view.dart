/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_common/exceptions.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show AppInfo;
import '../constants.dart';
import '../themes/solana_wallet_modal_banner_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../widgets/solana_wallet_app_icon.dart';
import '../widgets/solana_wallet_icon_paint.dart';
import '../widgets/solana_wallet_icon_painter.dart';
import 'solana_wallet_modal_view.dart';


/// Solana Wallet Modal Banner View
/// ------------------------------------------------------------------------------------------------
/// 
/// A [SolanaWalletModalView] with a pre-defined banners.
/// 
/// ```
/// ----------
/// | Banner |
/// ----------
///    ....   
/// ```
@immutable
class SolanaWalletModalBannerView extends StatelessWidget {

  /// Creates a modal view with a banner.
  const SolanaWalletModalBannerView({
    super.key,
    required this.builder,
    required this.title,
    this.message,
    this.body,
    this.footer,
  });

  /// The banner builder.
  final Widget Function(BuildContext context, SolanaWalletModalBannerTheme? theme) builder;

  /// The view's title.
  final Widget title;

  /// The view's description.
  final Widget? message;

  /// The view's main content.
  final Widget? body;

  /// The view's footer.
  final Widget? footer;

  /// Builds a modal `opening wallet` banner.
  static Widget _openingBuilder(
    final BuildContext context, 
    final SolanaWalletModalBannerTheme? theme, {
    required final AppInfo? app,
  }) => Stack(
    alignment: Alignment.center,
    children: [
      SizedBox.square(
        dimension: kBannerHeight,
        child: CircularProgressIndicator(
          color: theme?.progress?.color,
        ),
      ),
      Center(
        child: SolanaWalletAppIcon(
          app: app,
          size: kBannerHeight * (5/9), // 16 padding
        ),
      )
    ],
  );

  /// Creates a modal `opening wallet` view.
  factory SolanaWalletModalBannerView.opening({
    final Key? key = const ValueKey('opening'),
    final Widget? title,
    final Widget? message,
    final Widget? body,
    final Widget? footer,
    final AppInfo? app,
  }) => SolanaWalletModalBannerView(
      key: key,
      builder: (context, theme) => _openingBuilder(context, theme, app: app), 
      title: title ?? Text('Opening ${app?.name ?? "Wallet"}'),
      message: message ?? const Text('Continue in wallet application.'),
      body: body,
      footer: footer,
    );

  /// Builds a modal `success` banner.
  static Widget _successBuilder(
    final BuildContext context, 
    final SolanaWalletModalBannerTheme? theme,
  ) => SolanaWalletIconPaint(
    painter: SolanaWalletTickIcon(
      color: theme?.success?.color ?? const Color(0xFF3BD94D),
    ),
  );

  /// Creates a modal `success` view.
  factory SolanaWalletModalBannerView.success({
    final Key? key = const ValueKey('success'),
    final Widget title = const Text('Success'),
    final Widget? message,
    final Widget? body,
    final Widget? footer,
  }) => SolanaWalletModalBannerView(
      key: key,
      builder: _successBuilder, 
      title: title,
      message: message,
      body: body,
      footer: footer,
    );

  /// Builds a modal `error` banner.
  static Widget _errorBuilder(
    final BuildContext context, 
    final SolanaWalletModalBannerTheme? theme,
  ) => SolanaWalletIconPaint(
    painter: SolanaWalletBangIcon(
      color: theme?.error?.color ?? Theme.of(context).colorScheme.error,
    ),
  );

  /// Creates a modal `error` view.
  factory SolanaWalletModalBannerView.error({
    final Key? key = const ValueKey('error'),
    final Widget title = const Text('Error'),
    final Object? error,
    final Widget? message = const Text('Something went wrong.'),
    final Widget? body,
    final Widget? footer,
  }) => SolanaWalletModalBannerView(
      key: key,
      builder: _errorBuilder, 
      title: title,
      message: error is SolanaException ? Text(error.message) : message,
      body: body,
      footer: footer,
    );

  @override
  Widget build(final BuildContext context) {
    final SolanaWalletModalBannerTheme? theme = SolanaWalletThemeExtension.of(context)?.bannerTheme;
    return SolanaWalletModalView(
      banner: builder(context, theme),
      title: title,
      message: message,
      body: body,
      footer: footer,
    );
  }
}