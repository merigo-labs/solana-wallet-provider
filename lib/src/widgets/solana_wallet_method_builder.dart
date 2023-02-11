/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../models/solana_wallet_method_state.dart';
import '../../src/widgets/solana_wallet_animated_switcher.dart';


/// Types
/// ------------------------------------------------------------------------------------------------

typedef MethodBuilder<T, U> = Widget Function(
  BuildContext, 
  AsyncSnapshot<T>, 
  SolanaWalletMethodController<U>,
);


/// Solana Wallet Method Controller
/// ------------------------------------------------------------------------------------------------

mixin SolanaWalletMethodController<U> {

  /// Triggers the method call.
  void call();

  /// The current state of a method call.
  SolanaWalletMethodState get state;
}


/// Solana Wallet Method Builder
/// ------------------------------------------------------------------------------------------------

/// An animated [FutureBuilder] that invokes [method] with [value].
/// 
/// If [auto] is false the method must be invoked by [SolanaWalletMethodController.call].
class SolanaWalletMethodBuilder<T, U> extends StatefulWidget {
  
  /// Creates an animated [FutureBuilder] that invokes [method] with [value] and calls [onComplete] 
  /// or [onCompleteError] once finished.
  const SolanaWalletMethodBuilder({
    super.key,
    required this.value,
    required this.method,
    required this.builder,
    this.onComplete,
    this.onCompleteError,
    this.auto = true,
  });

  /// The value passed to [method].
  final U value;

  /// The method to invoke.
  final Future<T> Function(U value) method;

  /// Builds the widget to display for each state.
  final MethodBuilder<T, U> builder;

  /// The callback function invoked when [method] completes successfully.
  final void Function(T value)? onComplete;

  /// The callback function invoked when [method] completes with an error.
  final void Function(Object error, [StackTrace? stackTrace])? onCompleteError;

  /// True if the method should be invoked immediately. Otherwise 
  /// [SolanaWalletMethodController.call] is required to invoke the [method].
  final bool auto;

  @override
  State<SolanaWalletMethodBuilder<T, U>> createState() => _SolanaWalletMethodBuilderState<T, U>();
}


/// Solana Wallet Method Builder State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletMethodBuilderState<T, U> 
  extends State<SolanaWalletMethodBuilder<T, U>> 
    with SolanaWalletMethodController<U> {
  
  /// The [widget.method]'s result.
  Future<T>? _future;

  /// The current state of the [widget.method] call.
  SolanaWalletMethodState _state = SolanaWalletMethodState.none;

  @override
  SolanaWalletMethodState get state => _state;

  @override
  void initState() {
    super.initState();
    if (widget.auto) {
      call();
    }
  }

  @override
  void call() {
    if (_future == null) {
      _future ??= widget.method(widget.value)
        .catchError(_onCompleteError)
        .then(_onComplete);
      _setMethodState(SolanaWalletMethodState.progress);
    }
  }

  /// Updates [_state] and calls [widget.onComplete] with [value].
  Future<T> _onComplete(final T value) {
    _setMethodState(SolanaWalletMethodState.success);
    widget.onComplete?.call(value);
    return Future.value(value);
  }

  /// Updates [_state] and calls [widget.onCompleteError] with [error].
  Future<T> _onCompleteError(final Object error, [final StackTrace? stackTrace]) {
    _setMethodState(SolanaWalletMethodState.error);
    widget.onCompleteError?.call(error, stackTrace);
    return Future.error(error, stackTrace);
  }

  /// Sets [_state] and marks the widget as changed to schedule a call to [build].
  void _setMethodState(final SolanaWalletMethodState state) {
    _state = state;
    if (mounted) setState(() {});
  }

  /// Wraps [widget.builder] is an [AnimatedSwitcher] to animate changes in [state].
  Widget _futureBuilder(final BuildContext context, final AsyncSnapshot<T> snapshot) {
    final Widget child = widget.builder(context, snapshot, this);
    return SolanaWalletAnimatedSwitcher(
      child: child.key != null 
        ? child 
        : KeyedSubtree(
            key: ValueKey(_state), 
            child: child,
          ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: _futureBuilder,
    );
  }
}