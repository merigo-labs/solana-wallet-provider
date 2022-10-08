/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_provider/src/layouts/solana_wallet_layout_grid.dart';
import 'solana_wallet_spacer.dart';


/// Solana Wallet Column
/// ------------------------------------------------------------------------------------------------

class SolanaWalletColumn extends StatelessWidget {
  
  /// Creates a [Column] with [spacing] between each item.
  const SolanaWalletColumn({
    super.key,
    this.spacing,
    required this.children,
  });

  /// The space between items.
  final double? spacing;

  /// The content.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    final double space = spacing ?? SolanaWalletLayoutGrid.x1;
    for (int i = 0; i < children.length; ++i) {
      items.add(children[i]);
      if (i+1 < children.length) {
        items.add(SolanaWalletSpacer.square(space));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }
}