/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../solana_wallet_provider.dart';
import '../../src/utils/constants.dart';
import '../../src/widgets/solana_wallet_icon_paint.dart';
import '../../src/widgets/solana_wallet_icon_painter.dart';


/// Solana Wallet App Icon
/// ------------------------------------------------------------------------------------------------

/// A wallet icon.
class SolanaWalletAppIcon extends StatefulWidget {

  /// Creates an icon [Widget] for [app].
  /// 
  /// If [app] is omitted it defaults to the authorized application.
  const SolanaWalletAppIcon({
    super.key,
    this.app,
    this.size,
  });

  /// The wallet application.
  final AppInfo? app;
  
  /// The icon's width and height.
  final double? size;

  @override
  State<SolanaWalletAppIcon> createState() => _SolanaWalletAppIconState();
}


/// Solana Wallet App Icon State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletAppIconState extends State<SolanaWalletAppIcon> {
  
  /// The wallet icon.
  ImageProvider? _imageProvider;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadImageProvider);
  }

  /// Sets [_imageProvider] and marks the widget as changed to schedule a call to [build].
  void _setImageProvider(final ImageProvider imageProvider) {
    if (mounted && _imageProvider != imageProvider) {
      setState(() => _imageProvider = imageProvider);
    }
  }

  /// Loads [SolanaWalletAppIcon.app]'s icon.
  Future<void> _loadImageProvider() async {
    final AppInfo? app = widget.app;
    if (app != null) {
      _setImageProvider(app.icon);
    } else {
      final provider = SolanaWalletProvider.of(context);
      final Uri? walletUriBase = provider.authorizeResult?.walletUriBase;
      if (walletUriBase != null) {
        final String host = walletUriBase.host;
        final int index = AppInfo.values.indexWhere((appInfo) => appInfo.host == host);
        if (index >= 0) {
          _setImageProvider(AppInfo.values[index].icon);
        }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final ImageProvider? imageProvider = _imageProvider;
    return AnimatedSwitcher(
      duration: transitionDuration,
      child: imageProvider != null
        ? Image(image: imageProvider, width: widget.size, height: widget.size)
        : SolanaWalletIconPaint(painter: SolanaWalletIcon.new, size: widget.size),
    );
  }
}