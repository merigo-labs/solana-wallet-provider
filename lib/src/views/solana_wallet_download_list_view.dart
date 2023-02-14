/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../solana_wallet_provider.dart';
import '../../src/layouts/solana_wallet_grid.dart';


/// Solana Wallet Download List View
/// ------------------------------------------------------------------------------------------------

/// A list of Solana wallet applications with links to the app/play store.
class SolanaWalletDownloadListView extends StatefulWidget {
  
  /// Creates a list of Solana wallet applications that can be downloaded from the app/play store.
  const SolanaWalletDownloadListView({
    super.key,
    required this.apps,
  });

  /// App information.
  final List<SolanaWalletAppInfo> apps;

  @override
  State<SolanaWalletDownloadListView> createState() => _SolanaWalletDownloadListViewState();
}


/// Solana Wallet Download List View State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletDownloadListViewState extends State<SolanaWalletDownloadListView> {

  /// Opens [app] in the store and closes [SolanaWalletProvider]'s modal bottom sheet.
  VoidCallback _onTapButton(final SolanaWalletAppInfo app) {
    return () {
      SolanaWalletAdapterPlatform.instance.openStore(app.id).ignore();
      SolanaWalletProvider.close(context);
    };
  }

  @override
  Widget build(BuildContext context) {
    return SolanaWalletListView(
      spacing: SolanaWalletGrid.x1,
      children: [
        const Text('A crypto wallet is your gateway to blockchain apps.'),
        for (final SolanaWalletAppInfo app in widget.apps)
          ListTile(
            leading: Image(
              image: app.favicon,
              width: SolanaWalletGrid.x5,
            ),
            title: Text(app.name),
            onTap: _onTapButton(app), 
          ),
      ],
    );
  }
}