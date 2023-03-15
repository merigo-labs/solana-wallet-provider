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
class SolanaWalletProgressView extends StatelessWidget {

  /// Creates a [SolanaWalletStateView] for connecting the application to a wallet.
  const SolanaWalletProgressView({
    super.key,
    this.app,
    this.title,
    this.message,
  });

  /// The wallet application.
  final AppInfo? app;

  /// Operation title.
  final Widget? title;

  /// Operation description.
  final Widget? message;

  /// Creates a [SolanaWalletStateView] for opening a wallet.
  factory SolanaWalletProgressView.opening({
    final AppInfo? app,
    final Widget? title,
    final Widget? message,
  }) => SolanaWalletProgressView(
    app: app,
    title: title ?? Text('Opening ${app?.name ?? 'Wallet'}'),
    message: message ?? const Text('Continue in wallet application.'),
  );

  /// Creates a [SolanaWalletStateView] for processing a transaction.
  factory SolanaWalletProgressView.transaction({
    final AppInfo? app,
    final Widget? title,
    final Widget? message,
  }) => SolanaWalletProgressView(
    app: app,
    title: title ?? const Text('Transaction'),
    message: message ?? const Text('Processing transaction.'),
  );

  /// Creates a [SolanaWalletStateView] for processing a message.
  factory SolanaWalletProgressView.message({
    final AppInfo? app,
    final Widget? title,
    final Widget? message,
  }) => SolanaWalletProgressView(
    app: app,
    title: title ?? const Text('Message'),
    message: message ?? const Text('Processing message.'),
  );

  /// Creates a [SolanaWalletStateView] for processing a sign in request.
  factory SolanaWalletProgressView.signIn({
    final AppInfo? app,
    final Widget? title,
    final Widget? message,
  }) => SolanaWalletProgressView(
    app: app,
    title: title ?? const Text('Sign In'),
    message: message ?? Text('Signing in with ${app?.name ?? 'wallet'}.'),
  );

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
      title: title, 
      message: message,
    );
  }
}