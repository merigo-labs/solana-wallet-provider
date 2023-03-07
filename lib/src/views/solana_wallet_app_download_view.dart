/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../solana_wallet_provider.dart';
import '../../src/layouts/solana_wallet_grid.dart';


/// Solana Wallet App Download View
/// ------------------------------------------------------------------------------------------------

/// A download app view.
class SolanaWalletAppDownloadView extends StatelessWidget {
  
  /// Creates a view that displays a download button for [app].
  const SolanaWalletAppDownloadView({
    super.key,
    required this.app,
    required this.onPressed,
  });

  /// App information.
  final AppInfo app;

  /// Called when the app is pressed.
  final void Function(AppInfo info) onPressed;

  /// Download app description.
  static String get description => 'A wallet makes it safe & easy for you to trade tokens and '
    'collect NFTs on the Solana blockchain.';

  @override
  Widget build(final BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    return SolanaWalletStateView.image(
      image: app.icon,
      title: Text(
        'Download ${app.name}',
      ),
      message: Text(
        description,
      ),
      body: SizedBox(
        height: SolanaWalletGrid.x1 * 8,
        child: MaterialButton(
          onPressed: () => onPressed(app),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent, 
          child: Image(image: SolanaWalletAdapterPlatform.instance.storeBadge(brightness)),
        ),
      ),
    );
  }
}