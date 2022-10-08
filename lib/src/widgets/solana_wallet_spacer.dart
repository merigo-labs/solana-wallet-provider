/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../layouts/solana_wallet_layout_grid.dart';


/// Solana Wallet Spacer
/// ------------------------------------------------------------------------------------------------

class SolanaWalletSpacer extends SizedBox {
  
  /// Creates a [SizedBox] with a default width and height of [SolanaWalletLayoutGrid.x2].
  const SolanaWalletSpacer({
    super.key,
    super.width = SolanaWalletLayoutGrid.x2, 
    super.height = SolanaWalletLayoutGrid.x2, 
  });

  /// Creates a square box of [size], which default to [SolanaWalletLayoutGrid.x2].
  factory SolanaWalletSpacer.square(final double? size) 
    => size != null ? SolanaWalletSpacer(width: size, height: size) : const SolanaWalletSpacer();
}