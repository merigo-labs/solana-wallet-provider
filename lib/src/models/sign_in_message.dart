/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:solana_web3/solana_web3.dart' show PublicKey;


/// Sign In Message
/// ------------------------------------------------------------------------------------------------

class SignInMessage {

  /// A sign in message.
  /// 
  /// [CAIP blockchain sign in specification](https://github.com/ChainAgnostic/CAIPs/blob/master/CAIPs/caip-122.md#abstract-data-model)
  const SignInMessage({
    required this.domain,
    this.address,
    this.statement,
    this.uri,
    this.version,
    this.chainId,
    this.nonce,
    this.issuedAt,
    this.expirationTime,
    this.notBefore,
    this.requestId,
    this.resources,
  });

  /// The authority requesting the signing.
  final String domain;

  /// The blockchain address performing the signing.
  final PublicKey? address;

  /// A human-readable ASCII assertion that the user will sign. It MUST NOT contain `\n`.
  final String? statement;

  /// A URI referring to the resource that is the subject of the signing (i.e. the subject of the 
  /// claim).
  final Uri? uri;

  /// The current version of the message.
  final int? version;

  /// The Chain ID to which the session is bound, and the network where Contract Accounts MUST be 
  /// resolved.
  final String? chainId;
  
  /// A randomized token to prevent signature replay attacks.
  final String? nonce;
  
  /// The issuance time.
  final DateTime? issuedAt;
  
  /// The time at which the signed authentication message is no longer valid.
  final DateTime? expirationTime;
  
  /// The time at which the signed authentication message starts being valid.
  final DateTime? notBefore;
  
  /// A system-specific identifier used to uniquely refer to the authentication request.
  final String? requestId;

  /// A list of uris the user wishes to have resolved as part of the authentication by the relying 
  /// party.
  final List<String>? resources;
}