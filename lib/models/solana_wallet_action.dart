/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_wallet_adapter/models/account.dart';


/// Actions
/// ------------------------------------------------------------------------------------------------

/// Solana Wallet Action
abstract class SolanaWalletAction<T> {
  const SolanaWalletAction(this.data);
  final T data;
}

/// Authorize Action
class AuthorizeAction extends SolanaWalletAction {
  const AuthorizeAction(): super(null);
}

/// Change Account Action
class ChangeAccountAction extends SolanaWalletAction<Account> {
  const ChangeAccountAction(super.data);
}

/// Connect Remotely Action
class ConnectRemotelyAction extends SolanaWalletAction<String> {
  const ConnectRemotelyAction(super.data);
}

/// Deauthorize Action
class DeauthorizeAction extends SolanaWalletAction {
  const DeauthorizeAction(): super(null);
}

/// Dismiss View Action
class DismissViewAction extends SolanaWalletAction {
  const DismissViewAction(): super(null);
}