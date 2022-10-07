/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_list_tile.dart';
import '../layouts/solana_wallet_layout_grid.dart';
import '../models/solana_wallet_app_store.dart';


/// Solana Wallet App Store List Tile
/// ------------------------------------------------------------------------------------------------

class SolanaWalletAppStoreListTile extends StatelessWidget {
  
  /// Creates a list tile for an app store wallet [app].
  const SolanaWalletAppStoreListTile({
    super.key,
    required this.app,
    this.onTap,
  });

  /// The app store application details.
  final SolanaWalletAppStore app;

  /// Called when the tile is pressed.
  final void Function(SolanaWalletAppStore app)? onTap;

  @override
  Widget build(BuildContext context) {
    const double faviconSize = SolanaWalletLayoutGrid.x3;
    return SolanaWalletListTile(
      leading: Image(
        image: app.favicon,
        width: faviconSize,
        height: faviconSize,
      ),
      title: Text(app.name),
      onTap: onTap != null ? () => onTap?.call(app) : null,
    );
  }
}