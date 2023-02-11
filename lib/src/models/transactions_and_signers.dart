/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show immutable;
import 'package:solana_web3/solana_web3.dart' show Signer, Transaction;


/// Transactions and Signers
/// ------------------------------------------------------------------------------------------------

/// Pairs [transactions] with additional signers.
@immutable
class TransactionsAndSigners {

  /// Pairs [transactions] with additional signers.
  /// 
  /// ```
  /// TransactionsAndSigners(
  ///   transactions: [
  ///     Transaction(...),           // Tx0
  ///     Transaction(...),           // Tx1
  ///     Transaction(...),           // Tx2
  ///   ],
  ///   signersList: [
  ///     [Signer(...), Signer(...)], // Signers for Tx0
  ///     [Signer(...)],              // Signers for Tx1
  ///     null,                       // Signers for Tx2
  ///   ],
  /// );
  /// ```
  const TransactionsAndSigners({
    required this.transactions,
    required this.signersList,
  }): assert(transactions.length == signersList.length);

  /// The transactions.
  final List<Transaction> transactions;

  /// The [transactions]' additional signers.
  final List<List<Signer>?> signersList;
}