/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show immutable;
import 'package:solana_web3/solana_web3.dart' show Signer, Transaction;


/// Transaction with Signers
/// ------------------------------------------------------------------------------------------------

/// Pairs a [transaction] with additional [signers].
@immutable
class TransactionWithSigners {
  
  /// Pairs a [transaction] with additional [signers].
  const TransactionWithSigners({
    required this.transaction,
    this.signers,
  });

  /// The transaction.
  final Transaction transaction;

  /// The [transaction]'s additional signers.
  final List<Signer>? signers;
}