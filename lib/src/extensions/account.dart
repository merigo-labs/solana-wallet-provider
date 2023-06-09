/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show Account;
import 'package:solana_web3/solana_web3.dart' show Pubkey;


/// Account PubKey
/// ------------------------------------------------------------------------------------------------

extension AccountPubKey on Account {

  /// Creates a [Pubkey] from the account's [address].
  Pubkey toPubkey() => Pubkey.fromBase64(address);
}