/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_wallet_provider/src/models/solana_wallet_method_state.dart';


/// Dismiss State
/// ------------------------------------------------------------------------------------------------

enum DismissState {

  /// Automatically dismiss the modal bottom sheet when the request completes successfully 
  /// ([SolanaWalletMethodState.success]).
  success,

  /// Automatically dismiss the modal bottom sheet when the request completes with an error 
  /// ([SolanaWalletMethodState.error]).
  error,

  /// Automatically dismiss the modal bottom sheet when the request completes (success or error).
  done,
  ;

  /// Returns true if `this` is equal to [state].
  bool equals(final SolanaWalletMethodState state) {
    switch (this) {
      case DismissState.success:
        return state == SolanaWalletMethodState.success;
      case DismissState.error:
        return state == SolanaWalletMethodState.error;
      case DismissState.done:
        return state == SolanaWalletMethodState.success
            || state == SolanaWalletMethodState.error;
    }
  }
}
