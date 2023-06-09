/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show AppInfo;
import '../../solana_wallet_provider.dart' show SolanaWalletProvider;
import '../constants.dart';
import '../layouts/solana_wallet_grid.dart';
import '../views/solana_wallet_apps_view.dart';
import '../views/solana_wallet_modal_view.dart';


/// Solana Wallet Download View
/// ------------------------------------------------------------------------------------------------

/// A download app view.
class SolanaWalletDownloadView extends StatelessWidget {
  
  /// Creates a view that displays a grid of download [options] or a single button if [options] 
  /// contains only one item.
  const SolanaWalletDownloadView({
    super.key,
    required this.options,
    required this.onPressed,
  }): assert(options.length > 0);

  /// The wallet applications.
  final List<AppInfo> options;

  /// The on tap callback handler.
  final void Function(AppInfo info) onPressed;

  /// Download app description message.
  static String get description => 'A wallet makes it safe & easy to trade tokens and collect NFTs '
    'on the Solana blockchain.';

  /// Creates an icon image banner for [app].
  Widget _banner(
    final AppInfo app,
  ) => Image(
      image: app.icon,
      width: kBannerHeight,
      height: kBannerHeight,
    );

  @override
  Widget build(final BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final SolanaWalletProvider provider = SolanaWalletProvider.of(context);
    final AppInfo? singleApp = options.length == 1 ? options.first : null;
    return SolanaWalletModalView(
      banner: singleApp != null ? _banner(singleApp) : null,
      title: Text('Download ${singleApp?.name ?? "Wallet"}'),
      message: Text(description),
      footer: SizedBox(
        height: SolanaWalletGrid.x1 * 8,
        child: singleApp != null 
          ? MaterialButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent, 
              onPressed: () => onPressed(singleApp),
              child: Image(image: provider.adapter.store.badge(brightness)),
            )
          : SolanaWalletAppsView(
              apps: options, 
              onPressed: onPressed,
            ),
      ),
    );
  }
}