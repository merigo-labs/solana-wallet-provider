/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart' show immutable;
import 'package:solana_web3/solana_web3.dart' show PublicKey;


/// Messages and Addresses
/// ------------------------------------------------------------------------------------------------

/// Pairs [messages] with the [addresses] required to sign [messages].
@immutable
class MessagesAndAddresses {
  
  /// Pairs [messages] with the [addresses] required to sign [messages].
  const MessagesAndAddresses({
    required this.messages,
    this.addresses = const [],
  });

  /// The base-64 (android/ios) or utf8 (browser extension) messages to sign.
  final List<String> messages;

  /// The authorized addresses required to sign [messages].
  final List<PublicKey> addresses;
}