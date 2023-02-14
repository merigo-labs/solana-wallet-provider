/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show Account;
import 'package:solana_web3/solana_web3.dart' show PublicKey;


/// Account PubKey
/// ------------------------------------------------------------------------------------------------

extension AccountPubKey on Account {
  PublicKey toPublicKey() => PublicKey.fromBase64(address);
}