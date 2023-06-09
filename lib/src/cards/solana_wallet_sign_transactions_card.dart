/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show SignTransactionsResult;
import 'package:solana_web3/solana_web3.dart' show Connection, Transaction;
import '../views/solana_wallet_modal_banner_view.dart';
import '../widgets/sign_transactions_mixin.dart';
import '../widgets/adapter_widget.dart';


/// Solana Wallet Sign Transactions Card
/// ------------------------------------------------------------------------------------------------

/// The [SolanaWalletSignTransactionsCard] widget's state.
typedef SignTransactionsAdapterState 
  = AdapterState<SignTransactionsResult, SolanaWalletSignTransactionsCard>;

/// A modal card for `signTransactions` method calls.
class SolanaWalletSignTransactionsCard 
  extends AdapterWidget<SignTransactionsResult> 
  with SignTransactionsWidget  
{
  /// Creates a `signTransactions` card.
  const SolanaWalletSignTransactionsCard({
    super.key,
    required super.adapter,
    required this.connection,
    required this.transactions,
    required super.completer,
    required super.dismissState,
  });

  @override
  final Connection connection;

  @override
  final List<Transaction> transactions;

  @override
  SignTransactionsAdapterState createState() => _SolanaWalletSignTransactionsCardState();
}


/// Solana Wallet Sign Transactions Card State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletSignTransactionsCardState 
  extends SignTransactionsAdapterState 
  with SignTransactionsState 
{
  @override
  Future<SignTransactionsResult> invokeMethod() => signTransactions();

  @override
  Widget? builder(
    final BuildContext context, 
    final AsyncSnapshot<SignTransactionsResult> snapshot,
  ) {
    switch (snapshot.connectionState) {      
      case ConnectionState.none:
      case ConnectionState.waiting:
      case ConnectionState.active:
        return null; // Apply defaults.
      case ConnectionState.done:
        final Object? error = snapshot.error;
        return error != null
          ? SolanaWalletModalBannerView.error(
              error: error,
              message: const Text('Transaction signing error.'),
            )
          : SolanaWalletModalBannerView.success(
              message: const Text('Transaction signing complete.'),
            );
    }
  }
}