/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_card.dart';
import '../models/solana_wallet_method_state.dart';
import '../themes/solana_wallet_state_theme.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../views/solana_wallet_state_view.dart';
import '../widgets/solana_wallet_icon_paint.dart';
import '../widgets/solana_wallet_icon_painter.dart';


/// Solana Wallet Low Power Mode Card
/// ------------------------------------------------------------------------------------------------

/// Low Power Mode card.
class SolanaWalletLowPowerModeCard extends StatefulWidget {

  /// Creates a card that displays a `low power mode` warning message.
  const SolanaWalletLowPowerModeCard({
    super.key,
    required this.onPressedConfirm,
  });

  /// Confirmation callback function.
  final VoidCallback onPressedConfirm;

  @override
  State<SolanaWalletLowPowerModeCard> createState() => _SolanaWalletLowPowerModeCardState();
}


/// Solana Wallet Low Power Mode Card State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletLowPowerModeCardState extends State<SolanaWalletLowPowerModeCard> {
  
  /// Builds a warning icon.
  Widget _iconBuilder(final BuildContext context, final SolanaWalletStateThemeData theme) {
    return const SolanaWalletIconPaint(painter: SolanaWalletBangIcon.new);
  }

  @override
  Widget build(final BuildContext context) {
    return SolanaWalletCard(
      body: SolanaWalletStateView(
        iconBuilder: _iconBuilder,
        state: SolanaWalletMethodState.error,
        title: const Text('Low Power Mode'), 
        message: const Text('Communication with a wallet application may fail in Low Power Mode.'),
        body: TextButton(
          onPressed: widget.onPressedConfirm, 
          style: SolanaWalletThemeExtension.of(context)?.primaryButtonStyle,
          child: const Text('Got it'),
        ),
      ),
    );
  }
}