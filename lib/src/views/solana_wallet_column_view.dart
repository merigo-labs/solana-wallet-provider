/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_grid.dart';


/// Solana Wallet Column View
/// ------------------------------------------------------------------------------------------------

/// A vertical stack of widgets separated by [spacing].
class SolanaWalletColumnView<T> extends StatelessWidget {
  
  /// Creates a [Column] separated by [spacing].
  const SolanaWalletColumnView({
    super.key,
    this.spacing = SolanaWalletGrid.x1 * 2.0,
    required this.children,
    this.builder,
  });

  /// The space between each item.
  final double spacing;

  /// The child widgets or [builder] data.
  final List<T> children;

  /// Converts [children] items to widgets.
  final Widget Function(T item)? builder;

  /// The default item builder.
  Widget _itemBuilder(final T item) => item as Widget;

  @override
  Widget build(BuildContext context) {
    final itemBuilder = builder ?? _itemBuilder;
    final int length = (children.length * 2) - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < length; ++i)
          i.isEven ? itemBuilder(children[i ~/ 2]) : SizedBox(height: spacing)
      ],
    );
  }
}