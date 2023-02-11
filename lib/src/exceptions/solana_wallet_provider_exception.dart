/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show immutable;
import 'package:solana_web3/solana_web3.dart' show SolanaException;
import '../../src/exceptions/solana_wallet_provider_exception_code.dart';


/// Solana Wallet Provider Exception
/// ------------------------------------------------------------------------------------------------

/// An exception thrown by the provider.
@immutable
class SolanaWalletProviderException extends SolanaException<SolanaWalletProviderExceptionCode> {
  
  /// Creates an exception for an error caused by the provider.
  const SolanaWalletProviderException(
    super.message, {
    required SolanaWalletProviderExceptionCode super.code,
  });
}