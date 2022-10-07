/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_layout_grid.dart';
import '../solana_wallet_icons.dart';
import '../widgets/solana_wallet_card.dart';
import '../widgets/solana_wallet_column.dart';


/// Solana Wallet Icon View
/// ------------------------------------------------------------------------------------------------

class SolanaWalletIconView extends StatelessWidget {
  
  /// Creates a view that displays a `timed out` error message.
  const SolanaWalletIconView({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  /// The title.
  final String title;

  /// The message.
  final String message;

  /// The icon.
  final Icon icon;

  @override
  Widget build(final BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final Color? colour = icon.color ?? iconTheme.color;
    return SolanaWalletCard(
      title: title, 
      child: SolanaWalletColumn(
        spacing: SolanaWalletLayoutGrid.x2,
        children: [
          Text(message),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: colour != null 
                ? Border.all(
                    color: colour,
                    width: SolanaWalletIcons.strokeWidth,
                  )
                : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(SolanaWalletLayoutGrid.x2),
              child: icon,
            ),
          ),
        ],
      ),
    );
  }
}