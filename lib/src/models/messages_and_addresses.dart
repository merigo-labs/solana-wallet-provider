/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show immutable;
import 'package:solana_web3/solana_web3.dart' show Message, PublicKey;


/// Messages and Addresses
/// ------------------------------------------------------------------------------------------------

/// Pairs [messages] with [addresses] required to sign [messages].
@immutable
class MessagesAndAddresses {
  
  /// Pairs [messages] with [addresses] required to sign [messages].
  const MessagesAndAddresses({
    required this.messages,
    required this.addresses,
  });

  /// The messages.
  final List<Message> messages;

  /// The authorized addresses required to sign [messages].
  final List<PublicKey> addresses;
}