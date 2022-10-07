/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../layouts/solana_wallet_layout_grid.dart';
import '../models/solana_wallet_app_store.dart';
import '../solana_wallet_constants.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../widgets/solana_wallet_app_store_list_tile.dart';
import '../widgets/solana_wallet_card.dart';
import '../widgets/solana_wallet_column.dart';


/// Solana Wallet Download View
/// ------------------------------------------------------------------------------------------------

class SolanaWalletDownloadView extends StatefulWidget {
  
  /// Creates a view that displays a list of app store wallet links.
  const SolanaWalletDownloadView({
    super.key,
    required this.apps,
    this.onTapApp,
    this.onTapConnectRemotely,
  });

  /// The app store wallets.
  final List<SolanaWalletAppStore> apps;

  /// Called when an app in the [apps] list is selected.
  final void Function(SolanaWalletAppStore app)? onTapApp;

  /// Called when the `connect remotely` link is pressed.
  final VoidCallback? onTapConnectRemotely;

  @override
  State<SolanaWalletDownloadView> createState() => _SolanaWalletDownloadViewState();
}


/// Solana Wallet Download View State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletDownloadViewState extends State<SolanaWalletDownloadView> {
  
  /// The hyperlink tap gesture recognizer.
  late final TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = widget.onTapConnectRemotely;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SolanaWalletDownloadView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTapConnectRemotely != widget.onTapConnectRemotely) {
      _tapGestureRecognizer.onTap = widget.onTapConnectRemotely;
    }
  }

  /// Creates a list tile widget from the provided [app].
  Widget _mapApp(final SolanaWalletAppStore app) 
    => SolanaWalletAppStoreListTile(app: app, onTap: widget.onTapApp);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SolanaWalletThemeExtension? extension = SolanaWalletThemeExtension.of(context);
    return SolanaWalletCard(
      title: 'Download Wallet',
      child: SolanaWalletColumn(
        spacing: SolanaWalletLayoutGrid.x2,
        children: [
          const Text(
            'Download a Solana mobile wallet app to connect with your application.',
          ),
          SolanaWalletColumn(
            children: widget.apps.map(_mapApp).toList(growable: false),
          ),
          if (widget.onTapConnectRemotely != null)
            Text.rich(
              TextSpan(
                text: 'Already have a wallet on another device? ',
                // style: textStyle,
                children: [
                  TextSpan(
                    text: 'Connect remotely',
                    recognizer: _tapGestureRecognizer,
                    style: TextStyle(
                      color: extension?.linkColor ?? primaryColourOf(theme)
                    ),
                  ),
                  const TextSpan(
                    text: '.',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}