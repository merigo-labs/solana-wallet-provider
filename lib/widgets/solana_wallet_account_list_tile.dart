/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/models/account.dart';
import 'solana_wallet_copy_text.dart';
import 'solana_wallet_list_tile.dart';
import '../solana_wallet_icons.dart';
import '../themes/solana_wallet_theme_extension.dart';


/// Solana Wallet Account List Tile
/// ------------------------------------------------------------------------------------------------

class SolanaWalletAccountListTile extends StatelessWidget {
  
  /// Creates a list tile for a wallet [account].
  const SolanaWalletAccountListTile({
    super.key,
    required this.account,
    this.selected = false,
    this.onTap,
  });

  /// A wallet account.
  final Account account;

  /// If true, display a trailing tick icon.
  final bool selected;

  /// Called when the tile is pressed.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String address = account.address;
    final SolanaWalletThemeExtension? extension = SolanaWalletThemeExtension.of(context);
    MaterialStateColor.resolveWith;
    return SolanaWalletCopyText(
      text: address,
      longPress: true,
      child: SolanaWalletListTile(
        onTap: onTap,
        title: Text(account.label ?? 'Wallet'),
        subtitle: Text(address),
        trailing: selected 
          ? Icon(
              SolanaWalletIcons.tick,
              size: SolanaWalletIcons.size,
              color: extension?.stateColor?.selected,
            ) 
          : null,
      ),
    );
  }
}