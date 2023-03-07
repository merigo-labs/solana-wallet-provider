/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import '../../src/models/solana_wallet_method_state.dart';
import '../../src/themes/solana_wallet_state_theme.dart';
import '../../src/views/solana_wallet_state_view.dart';
import '../../src/widgets/solana_wallet_app_icon.dart';


/// Solana Wallet Opening Wallet View
/// ------------------------------------------------------------------------------------------------

/// A view to display while connecting the application to a wallet.
class SolanaWalletOpeningWalletView extends StatelessWidget {

  /// Creates a [SolanaWalletStateView] for connecting the application to a wallet.
  const SolanaWalletOpeningWalletView({
    super.key,
    this.app,
  });

  /// The wallet application.
  final AppInfo? app;

  /// Builds the view's icon header.
  Widget _iconBuilder(
    final BuildContext context, 
    final SolanaWalletStateThemeData theme,
  ) => Stack(
    alignment: Alignment.center,
    children: [
      SolanaWalletStateView.progressBuilder(context, theme),
      SolanaWalletAppIcon(app: app, size: theme.iconSize * 0.5),
    ],
  );

  @override
  Widget build(final BuildContext context) {
    return SolanaWalletStateView(
      iconBuilder: _iconBuilder,
      state: SolanaWalletMethodState.progress,
      title: Text('Opening ${app?.name ?? 'Wallet'}'), 
      message: const Text('Continue in wallet application.'),
    );
  }
}