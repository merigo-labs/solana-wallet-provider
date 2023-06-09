/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show AppInfo;
import '../layouts/solana_wallet_grid.dart';


/// Solana Wallet App Tile
/// ------------------------------------------------------------------------------------------------

/// An app widget tile.
class SolanaWalletAppTile extends StatelessWidget {
  
  /// Creates an app widget tile.
  const SolanaWalletAppTile({
    super.key,
    required this.app,
    required this.onPressed,
  });

  /// The application's information.
  final AppInfo app;

  /// The on tap callback handler.
  final void Function(AppInfo app) onPressed;

  @override
  Widget build(final BuildContext context) {
    const double padding = SolanaWalletGrid.x1;
    const double iconSize = SolanaWalletGrid.x6;
    const double spacing = SolanaWalletGrid.x1 * 0.5;
    const double fontSize = 12.0;
    const double lineHeight = fontSize * 1.4;
    const double boxSize = iconSize + spacing + lineHeight + (padding * 2.0);
    return Center(
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: SizedBox.square(
        dimension: boxSize,
        child: InkWell(
          onTap: () => onPressed(app),
          borderRadius: BorderRadius.circular(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: app.icon,
                height: iconSize,
                width: iconSize,
              ),
              const SizedBox(
                height: spacing,
              ),
              Text(
                app.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: fontSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}