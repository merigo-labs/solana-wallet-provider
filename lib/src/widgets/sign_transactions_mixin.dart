/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart' show State, Widget;
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show SignTransactionsResult, 
  SolanaWalletAdapter;
import 'package:solana_web3/solana_web3.dart' show Connection, Transaction;
import 'adapter_widget.dart';


/// Sign Transactions [Widget] Mixin
/// ------------------------------------------------------------------------------------------------

/// An [AdapterWidget] mixin for `sign transactions` methods.
mixin SignTransactionsWidget<R> on AdapterWidget<R> {

  /// {@macro solana_web3.Connection}
  Connection get connection;

  /// The transactions to sign using the wallet application.
  List<Transaction> get transactions;
}


/// Sign Transactions [State] Mixin
/// ------------------------------------------------------------------------------------------------

/// An [AdapterState] mixin for `sign transactions` methods.
mixin SignTransactionsState<R, S extends SignTransactionsWidget<R>> on AdapterState<R, S> {

  /// Serializes [SignTransactionsWidget.transactions] with [adapter].
  Future<List<String>> _encodeTransactions(final SolanaWalletAdapter adapter) async {
    final List<Transaction> transactions = widget.transactions;
    final List<String> encodedTransactions = [];
    for (final Transaction transaction in transactions) {
      encodedTransactions.add(adapter.encodeTransaction(transaction));
    }
    return encodedTransactions;
  }

  /// Signs [SignTransactionsWidget.transactions] with the wallet application and 
  /// [SignTransactionsWidget.signersList].
  Future<SignTransactionsResult> signTransactions() async {
    final SolanaWalletAdapter adapter = widget.adapter;
    final List<String> transactions = await _encodeTransactions(adapter);
    return adapter.signTransactions(transactions);
  }
}