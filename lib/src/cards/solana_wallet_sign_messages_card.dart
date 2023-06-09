/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show SignMessagesResult, 
  SolanaWalletAdapter;
import '../views/solana_wallet_modal_banner_view.dart';
import '../widgets/adapter_widget.dart';


/// Solana Wallet Sign Messages Card
/// ------------------------------------------------------------------------------------------------

/// The [SolanaWalletSignMessagesCard] widget's state.
typedef SignMessagesAdapterState = AdapterState<SignMessagesResult, SolanaWalletSignMessagesCard>;

/// A modal card for `signMessages` method calls.
class SolanaWalletSignMessagesCard extends AdapterWidget<SignMessagesResult> {

  /// Creates a `signMessages` card.
  const SolanaWalletSignMessagesCard({
    super.key,
    required super.adapter,
    required this.messages,
    required this.addresses,
    required super.completer,
    required super.dismissState,
  });

  /// The `utf-8` encoded messages to sign using the wallet application.
  final List<String> messages;

  /// The `base-64` encoded addresses of the accounts to sign [messages].
  final List<String> addresses;

  @override
  SignMessagesAdapterState createState() => _SolanaWalletSignMessagesCardState();
}


/// Solana Wallet Sign Messages Card State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletSignMessagesCardState extends SignMessagesAdapterState {

  @override
  Future<SignMessagesResult> invokeMethod() {
    final SolanaWalletAdapter adapter = widget.adapter;
    final List<String> encoded = widget.messages.map(adapter.encodeMessage).toList(growable: false);
    return adapter.signMessages(encoded, addresses: widget.addresses);
  }
  
  @override
  Widget? builder(
    final BuildContext context, 
    final AsyncSnapshot<SignMessagesResult> snapshot,
  ) {
    switch (snapshot.connectionState) {      
      case ConnectionState.none:
      case ConnectionState.waiting:
      case ConnectionState.active:
        return null; // Apply defaults.
      case ConnectionState.done:
        final Object? error = snapshot.error;
        return error != null
          ? SolanaWalletModalBannerView.error(
              error: error,
              message: const Text('Message signing error.'),
            )
          : SolanaWalletModalBannerView.success(
              message: const Text('Message signing complete.'),
            );
    }
  }
}