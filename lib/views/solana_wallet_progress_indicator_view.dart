/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../solana_wallet_icons.dart';
import '../widgets/solana_wallet_card.dart';


/// Solana Wallet Loading Indicator View
/// ------------------------------------------------------------------------------------------------

class SolanaWalletProgressIndicatorView extends StatelessWidget {
  
  /// Creates a view that displays a loading indicator.
  const SolanaWalletProgressIndicatorView({
    super.key,
    required this.title,
  });

  /// The card title.
  final String title;

  @override
  Widget build(final BuildContext context) {
    return SolanaWalletCard(
      title: title,
      child: const CircularProgressIndicator(
        strokeWidth: SolanaWalletIcons.strokeWidth,
      ),
    );
  }
}