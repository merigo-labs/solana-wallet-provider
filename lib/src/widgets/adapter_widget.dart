/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show SolanaWalletAdapter;
import '../cards/solana_wallet_modal_card.dart';
import '../models/dismiss_state.dart';
import 'solana_wallet_method_builder.dart';


/// Adapter Widget
/// ------------------------------------------------------------------------------------------------

/// A widget that invokes an [adapter] method.
abstract class AdapterWidget<R> extends StatefulWidget {

  /// Creates a [StatefulWidget] to invoke an [adapter] method.
  const AdapterWidget({
    super.key,
    required this.adapter,
    required this.completer,
    required this.dismissState,
  });

  /// {@macro solana_wallet_adapter}
  final SolanaWalletAdapter adapter;
  
  /// {@macro solana_wallet_provider.SolanaWalletMethodBuilder.completer}
  final Completer<R>? completer;

  /// {@macro solana_wallet_provider.SolanaWalletMethodBuilder.dismissState}
  final DismissState? dismissState;

  @override
  AdapterState<R, AdapterWidget<R>> createState();
}


/// Adapter State
/// ------------------------------------------------------------------------------------------------

/// The [State] of an [AdapterWidget].
abstract class AdapterState<R, S extends AdapterWidget<R>> extends State<S> {

  /// The invoked method.
  Future<R>? _future;
  
  /// Calls [invokeMethod].
  @override
  void initState() {
    super.initState();
    _future = invokeMethod();
  }

  /// Invokes an adapter method and returns the result.
  Future<R> invokeMethod();

  /// Builds a view for the current [AsyncSnapshot.connectionState].
  Widget? builder(
    final BuildContext context, 
    final AsyncSnapshot<R> snapshot,
  ) => null; // Apply defaults.

  @override
  Widget build(final BuildContext context) {
    return SolanaWalletModalCard(
      child: SolanaWalletMethodBuilder<R>(
        future: _future,
        completer: widget.completer,
        dismissState: widget.dismissState,
        builder: builder,
      ), 
    );
  }
}