/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_list_view.dart';
import '../../solana_wallet_provider.dart';
import '../../src/layouts/solana_wallet_grid.dart';
import '../../src/views/solana_wallet_content_view.dart';


/// Solana Wallet App List View
/// ------------------------------------------------------------------------------------------------

/// A list of Solana wallet applications.
class SolanaWalletAppListView extends StatelessWidget {
  
  /// Creates a list of Solana wallet applications.
  const SolanaWalletAppListView({
    super.key,
    required this.title,
    required this.message,
    required this.apps,
    required this.onPressed,
  });

  /// The title.
  final Widget title;

  /// The description.
  final Widget message;

  /// App information.
  final List<AppInfo> apps;

  /// The selection callback function.
  final void Function(AppInfo info) onPressed;

  /// Creates a [Widget] for [info].
  Widget _builder(final BuildContext context, final AppInfo info) {
    return ListTile(
      leading: Image(
        image: info.icon,
        width: SolanaWalletGrid.x5,
      ),
      title: Text(info.name),
      onTap: () => onPressed(info), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return SolanaWalletContentView(
      title: title,
      message: message,
      body: SolanaWalletListView<AppInfo>(
        spacing: SolanaWalletGrid.x1,
        builder: _builder,
        children: apps,
      ),
    );
  }
}