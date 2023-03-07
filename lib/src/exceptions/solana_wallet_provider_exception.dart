/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show immutable;
import 'package:solana_common/exceptions/solana_exception.dart';


/// Solana Wallet Provider Exception Codes
/// ------------------------------------------------------------------------------------------------

enum SolanaWalletProviderExceptionCode {
  dismissed,
  format,
  invalid,
}


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