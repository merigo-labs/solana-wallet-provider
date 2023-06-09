/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show AppInfo;
import '../layouts/solana_wallet_grid.dart';
import '../tiles/solana_wallet_app_tile.dart';


/// Solana Wallet Apps View
/// ------------------------------------------------------------------------------------------------

/// A grid of Solana wallet applications.
class SolanaWalletAppsView extends StatelessWidget {

  /// Creates a grid of Solana wallet applications.
  const SolanaWalletAppsView({
    super.key, 
    required this.apps,
    required this.onPressed,
  });

  /// The applications.
  final List<AppInfo> apps;

  /// The on tap callback handler.
  final void Function(AppInfo app) onPressed;

  @override
  Widget build(final BuildContext context) {
    const double spacing = SolanaWalletGrid.x1;
    return Wrap(
      spacing: spacing,
      alignment: WrapAlignment.center,
      children: apps.map(
        (final AppInfo app) => SolanaWalletAppTile(
          app: app, 
          onPressed: onPressed,
        )
      ).toList(growable: false),
    );
  }
}