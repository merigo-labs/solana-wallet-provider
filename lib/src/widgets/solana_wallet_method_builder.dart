/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' show SolanaWalletAdapterException, 
  SolanaWalletAdapterExceptionCode;
import '../../solana_wallet_provider.dart' show SolanaWalletProvider;
import '../constants.dart';
import '../models/dismiss_state.dart';
import '../views/solana_wallet_modal_banner_view.dart';


/// Solana Wallet Method Builder
/// ------------------------------------------------------------------------------------------------

/// A widget that builds its view based on the current state of [future]. The widget animates view 
/// changes between states.
/// 
/// Provide [builder] to define custom UIs for each state.
class SolanaWalletMethodBuilder<T> extends StatefulWidget {

  /// Creates a widget to display the state of a method call.
  const SolanaWalletMethodBuilder({
    super.key, 
    required this.future,
    required this.completer,
    required this.dismissState,
    this.builder,
  });

  /// {@template solana_wallet_provider.SolanaWalletMethodBuilder.future}
  /// The future to observe the state of. This can only be set to a non-null value once.
  /// {@endtemplate}
  final Future<T>? future;

  /// {@template solana_wallet_provider.SolanaWalletMethodBuilder.completer}
  /// The handler invoked with the result of [future] when it completes.
  /// {@endtemplate}
  final Completer<T>? completer;

  /// {@template solana_wallet_provider.SolanaWalletMethodBuilder.dismissState}
  /// The completion state in which to automatically close the [SolanaWalletProvider] modal.
  /// 
  /// For example, providing a value of [DismissState.success] tells the widget to ignore drawing 
  /// the `success` state and call [SolanaWalletProvider.close] instead.
  /// {@endtemplate}
  final DismissState? dismissState;

  /// {@template solana_wallet_provider.SolanaWalletMethodBuilder.builder}
  /// Builds the widget for the current [AsyncSnapshot.connectionState].
  /// 
  /// To trigger state change animations you may need to set the returned widget's [Key] property.
  /// {@endtemplate}
  final Widget? Function(BuildContext context, AsyncSnapshot<T> snapshot)? builder;

  @override
  State<SolanaWalletMethodBuilder<T>> createState() => _SolanaWalletMethodBuilderState<T>();
}


/// Solana Wallet Method Builder State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletMethodBuilderState<T> extends State<SolanaWalletMethodBuilder<T>> {

  /// The current state of [_future].
  late AsyncSnapshot<T> _snapshot;

  /// The pending method call.
  Future<T>? _future;

  @override
  void initState() {
    super.initState();
    _initSnapshot();
    _initFuture();
  }

  @override
  void didUpdateWidget(covariant final SolanaWalletMethodBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future != widget.future) {
      _initFuture();
    }
  }

  /// Sets [_snapshot] based on the current value of [SolanaWalletMethodBuilder.future].
  void _initSnapshot() {
    _snapshot = widget.future != null 
      ? AsyncSnapshot<T>.waiting() 
      : AsyncSnapshot<T>.nothing();
  }

  /// Sets [_future] and subsequently triggers a call to [_handler]. The [_future] is set the first 
  /// time a non-null value is provided by [SolanaWalletMethodBuilder.future].
  void _initFuture() {
    final Future<T>? future = widget.future;
    if (_future == null && future != null) {
      _future = future;
      _handler(future);
    }
  }

  /// Returns true if [error] is a [SolanaWalletAdapterExceptionCode.cancelled] exception.
  bool _isCancelledException(final Object error) {
    return error is SolanaWalletAdapterException
      && error.code == SolanaWalletAdapterExceptionCode.cancelled;
  }

  /// Returns true if [snapshot] is equivalent to the provided 
  /// [SolanaWalletMethodBuilder.dismissState].
  bool _isDismissState(final AsyncSnapshot snapshot) {
    final DismissState? dismissState = widget.dismissState;
    if (dismissState == null || snapshot.connectionState != ConnectionState.done) {
      return false;
    }
    switch (dismissState) {
      case DismissState.success:
        return !snapshot.hasError;
      case DismissState.error:
        return snapshot.hasError;
      case DismissState.done:
        return true;
    }
  }

  /// Sets [_snapshot] to [snapshot] if the [AsyncSnapshot.connectionState] has changed and is not 
  /// an equivalent [DismissState].
  void _setSnapshot(final AsyncSnapshot<T> snapshot) {
    if (mounted && _snapshot.connectionState != snapshot.connectionState) {
      if (!_isDismissState(snapshot)) {
        setState(() => _snapshot = snapshot);
      } else {
        SolanaWalletProvider.close(context);
      }
    }
  } 

  /// Resolves [SolanaWalletMethodBuilder.completer] with [data].
  void _complete(final T data) {
    final Completer<T>? completer = widget.completer;
    if (completer != null && !completer.isCompleted) {
      completer.complete(data);
    }
  }

  /// Resolves [SolanaWalletMethodBuilder.completer] with [error].
  void _completeError(final Object error, [final StackTrace? stackTrace]) {
    final Completer<T>? completer = widget.completer;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }

  /// Waits for the result of [future] and sets the state accordingly.
  Future<void> _handler(final Future<T> future) async {
    try {
      _setSnapshot(AsyncSnapshot<T>.waiting());
      final T data = await future;
      _setSnapshot(AsyncSnapshot<T>.withData(ConnectionState.done, data));
      _complete(data);
    } catch (error, stackTrace) {
      // Ignore `cancelled` exceptions, the modal should have already been poped by 
      // [SolanaWalletProvider].
      if (!_isCancelledException(error)) { 
        _setSnapshot(AsyncSnapshot<T>.withError(ConnectionState.done, error, stackTrace));
      }
      _completeError(error, stackTrace);
    }
  }

  /// Builds a view for the current [AsyncSnapshot.connectionState].
  Widget _builder(
    final BuildContext context, 
    final AsyncSnapshot<T> snapshot,
  ) {
    final Widget? child = widget.builder?.call(context, _snapshot);
    if (child != null) {
      return child;
    }
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
      case ConnectionState.active:
        return SolanaWalletModalBannerView.opening();
      case ConnectionState.done:
        final Object? error = snapshot.error;
        if (error != null) {
          return SolanaWalletModalBannerView.error(
            title: const Text('Error'),
            error: error,
            message: const Text('Something went wrong.'),
          );
        } else {
          return SolanaWalletModalBannerView.success(
            title: const Text('Success'),
            message: const Text('Task complete.'),
          );
        }
    }
  }

  @override
  Widget build(
    final BuildContext context,
  ) => AnimatedSize(
      duration: kTransitionDuration,
      child: AnimatedSwitcher(
        duration: kTransitionDuration,
        child: _builder(context, _snapshot),
      ),
    );
}