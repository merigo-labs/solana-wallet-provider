/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../solana_wallet_provider.dart';
import '../constants.dart';
import '../../src/widgets/solana_wallet_icon_paint.dart';
import '../../src/widgets/solana_wallet_icon_painter.dart';


/// Solana Wallet App Icon
/// ------------------------------------------------------------------------------------------------

/// A wallet application icon.
class SolanaWalletAppIcon extends StatelessWidget {

  /// Creates an icon [Widget] for [app].
  /// 
  /// If [app] is omitted it defaults to the authorized application.
  const SolanaWalletAppIcon({
    super.key,
    this.app,
    this.size = kBannerHeight,
  });

  /// The wallet application to render an icon for.
  final AppInfo? app;
  
  /// The icon's width and height.
  final double size;

  /// Loads the connected account's app icon.
  ImageProvider? _loadImageProvider(final BuildContext context) {
    try {
      final provider = SolanaWalletProvider.of(context);
      final Uri? walletUriBase = provider.authorizeResult?.walletUriBase;
      if (walletUriBase != null) {
        final String host = walletUriBase.host;
        final AppInfo? info = provider.adapter.store.info(host);
        if (info != null) {
          return info.icon;
        }
      }
    } catch (e) {

    }
    return null;
  }

  @override
  Widget build(final BuildContext context) {
    final ImageProvider? imageProvider = app?.icon ?? _loadImageProvider(context);
    return imageProvider != null
      ? Image(
          image: imageProvider, 
          width: size, 
          height: size,
        )
      : SolanaWalletIconPaint(
          size: size,
          painter: SolanaWalletIcon(
            color: Theme.of(context).colorScheme.surfaceTint,
          ),
        );
  }
}