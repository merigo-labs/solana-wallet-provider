/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show Account;
import '../layouts/solana_wallet_grid.dart';
import '../widgets/solana_wallet_copy_text.dart';
import '../widgets/solana_wallet_icon_painter.dart';
import '../widgets/solana_wallet_text_overflow.dart';


/// Solana Wallet Account Tile
/// ------------------------------------------------------------------------------------------------

/// An account list tile.
class SolanaWalletAccountTile extends StatelessWidget {

  /// Creates an account list tile.
  const SolanaWalletAccountTile({
    super.key,
    required this.account,
    required this.selected,
    required this.onPressed,
  });

  /// A wallet account.
  final Account account;

  /// True if [account] is the selected account in the list.
  final bool selected;

  /// The on tap callback handler.
  final void Function(Account account) onPressed;

  @override
  Widget build(final BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String address = account.toBase58();
    return SolanaWalletCopyText(
      text: address,
      onLongPress: true,
      child: ListTile(
        onTap: () => onPressed(account),
        title: Text(
          account.label ?? 'Wallet',
          style: textTheme.bodyLarge,
        ),
        subtitle: SolanaWalletTextOverflow(
          text: address,
          style: textTheme.labelMedium,
        ),
        trailing: selected 
          ? CustomPaint(
            size: const Size.square(SolanaWalletGrid.x2),
            painter: SolanaWalletTickIcon(
              color: Theme.of(context).colorScheme.secondary, 
              strokeWidth: 1.0
            ),
          )
          : null,
      ),
    );
  }
}