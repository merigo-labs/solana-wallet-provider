/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'solana_wallet_list_view.dart';
import '../layouts/solana_wallet_thickness.dart';
import '../widgets/solana_wallet_copy_text.dart';
import '../widgets/solana_wallet_icon_painter.dart';
import '../widgets/solana_wallet_text_overflow.dart';
import '../../solana_wallet_provider.dart';
import '../../src/layouts/solana_wallet_grid.dart';
import '../../src/views/solana_wallet_content_view.dart';


/// Solana Wallet Account List View
/// ------------------------------------------------------------------------------------------------

/// A list of Solana wallet accounts.
class SolanaWalletAccountListView extends StatelessWidget {
  
  /// Creates a list of Solana wallet accounts.
  const SolanaWalletAccountListView({
    super.key,
    required this.title,
    this.body,
    required this.accounts,
    this.selectedAccount,
    required this.onPressed,
  });

  /// The title.
  final Widget title;

  /// The remaining content.
  final Widget? body;

  /// Wallet accounts.
  final List<Account> accounts;

  /// The account to render selected.
  final Account? selectedAccount;

  /// The selection callback function.
  final void Function(Account info) onPressed;

  /// Creates a [Widget] for [account].
  Widget _builder(final BuildContext context, final Account account) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String address = account.addressBase58;
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
        trailing: selectedAccount == account 
          ? CustomPaint(
            size: const Size.square(SolanaWalletGrid.x2),
            painter: SolanaWalletTickIcon(
              color: Theme.of(context).indicatorColor, 
              strokeWidth: SolanaWalletThickness.x1,
            ),
          )
          : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SolanaWalletContentView(
      title: title,
      message: accounts.isEmpty 
        ? const Text('No connected accounts.')
        : SolanaWalletListView<Account>(
            spacing: SolanaWalletGrid.x1,
            builder: _builder,
            children: accounts,
          ),
      body: body,
    );
  }
}