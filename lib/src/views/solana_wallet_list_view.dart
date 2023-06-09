/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_grid.dart';


/// Solana Wallet List View
/// ------------------------------------------------------------------------------------------------

/// A [ListView] with item [spacing].
class SolanaWalletListView<T> extends StatelessWidget {

  /// Creates Aa[ListView] with item [spacing].
  const SolanaWalletListView({
    super.key,
    this.spacing = SolanaWalletGrid.x1 * 2.0,
    required this.children,
    this.builder,
  });

  /// The vertical space between each item.
  final double spacing;

  /// The child [Widget]s or [builder] item data.
  final List<T> children;

  /// Converts [item]s of [children] to widgets.
  final Widget Function(BuildContext context, T item)? builder;

  /// The default item builder.
  Widget _itemBuilder(final BuildContext context, final int index) 
    => builder?.call(context, children[index]) ?? children[index] as Widget;
    
  /// The separation builder.
  Widget _separatorBuilder(final BuildContext context, final int index) 
    => SizedBox(height: spacing);

  @override
  Widget build(final BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: children.length,
      itemBuilder: _itemBuilder, 
      separatorBuilder: _separatorBuilder, 
    );
  }
}