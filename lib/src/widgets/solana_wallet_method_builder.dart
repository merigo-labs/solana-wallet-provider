/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async' show Completer;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../solana_wallet_provider.dart';
import '../../src/cards/solana_wallet_low_power_mode_card.dart';
import '../../src/widgets/solana_wallet_animated_switcher.dart';


/// Types
/// ------------------------------------------------------------------------------------------------

typedef MethodBuilder<T> = Widget Function(
  BuildContext, 
  AsyncSnapshot<T>, 
  SolanaWalletMethodController,
);


/// Solana Wallet Method Controller
/// ------------------------------------------------------------------------------------------------

mixin SolanaWalletMethodController {

  /// Triggers the method call.
  void call();

  /// The current state of a method call.
  SolanaWalletMethodState get state;
}


/// Solana Wallet Method Builder
/// ------------------------------------------------------------------------------------------------

/// An widget that invokes [method] with [value] and animates state changes.
/// 
/// If [auto] is false the method must be invoked by [SolanaWalletMethodController.call].
class SolanaWalletMethodBuilder<T, U> extends StatefulWidget {
  
  /// Creates a widget that invokes [method] with [value]. The rendered view is provided by 
  /// [builder] for the current state. The widget animates view changes and completes by calling 
  /// [onComplete] or [onCompleteError].
  const SolanaWalletMethodBuilder({
    super.key,
    required this.value,
    required this.method,
    required this.builder,
    this.dismissState,
    this.onComplete,
    this.onCompleteError,
    this.auto = true,
    this.checkLowPowerMode = false,
  });

  /// The value passed to [method].
  final U value;

  /// The method to invoke.
  final Future<T> Function(U value) method;

  /// Builds the widget to display for each state.
  final MethodBuilder<T> builder;

  /// The state in which a call to [SolanaWalletProvider.close] will be made to automatically 
  /// dismiss the action.
  final DismissState? dismissState;

  /// The callback function invoked when [method] completes successfully.
  final void Function(T value)? onComplete;

  /// The callback function invoked when [method] completes with an error.
  final void Function(Object error, [StackTrace? stackTrace])? onCompleteError;

  /// True if the method should be invoked immediately. Otherwise 
  /// [SolanaWalletMethodController.call] must be called to invoke the [method].
  final bool auto;

  /// True if the method should paused and display a `low power mode` warning message.
  final bool checkLowPowerMode;

  @override
  State<SolanaWalletMethodBuilder<T, U>> createState() => _SolanaWalletMethodBuilderState<T, U>();
}


/// Solana Wallet Method Builder State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletMethodBuilderState<T, U> 
  extends State<SolanaWalletMethodBuilder<T, U>> 
    with SolanaWalletMethodController {
  
  /// The [SolanaWalletMethodBuilder.method] call's return value.
  T? _data;

  /// The [SolanaWalletMethodBuilder.method] call's error value.
  Object? _error;

  /// The [SolanaWalletMethodBuilder.method] call's error stack trace.
  StackTrace? _stackTrace;

  /// True if the method has been called;
  bool _invoked = false;

  /// True if the widget should render a `low power mode` card.
  bool _showLowPowerModeCard = false;

  /// The user's `low power mode` warning confirmation.
  Completer<void>? _lowPowerModeConfirmation;

  /// The [SolanaWalletMethodBuilder.method] call's current state.
  SolanaWalletMethodState _state = SolanaWalletMethodState.none;

  @override
  SolanaWalletMethodState get state => _state;

  /// An invalid data exception.
  SolanaWalletProviderException get _invalidException => const SolanaWalletProviderException(
    'Invalid data', 
    code: SolanaWalletProviderExceptionCode.invalid,
  );

  @override
  void initState() {
    super.initState();
    if (widget.auto) {
      _state = SolanaWalletMethodState.progress;
      SchedulerBinding.instance.addPostFrameCallback((_) => call());
    }
  }

  @override
  void call() async {
    if (!_invoked) {
      _invoked = true;
      try {
        await _checkLowPowerMode();
        _setMethodState(SolanaWalletMethodState.progress);
        final T result = _data = await widget.method(widget.value);
        _setMethodState(SolanaWalletMethodState.success);
        widget.onComplete?.call(result);
      } catch (error, stackTrace) {
        _error = error;
        _stackTrace = stackTrace;
        if (!_isDismissedException(error)) {
          _setMethodState(SolanaWalletMethodState.error);
        }
        widget.onCompleteError?.call(error, stackTrace);
      }
    }
  }

  /// Check the device's power mode and await confirmation if 
  /// [SolanaWalletMethodBuilder.checkLowPowerMode] is enabled and the device is in low power mode.
  Future<void> _checkLowPowerMode() async {
    if (widget.checkLowPowerMode) {
      _showLowPowerModeCard = await SolanaWalletAdapterPlatform.instance.isLowPowerMode();
      if (_showLowPowerModeCard) {
        _lowPowerModeConfirmation = Completer.sync();
        if (mounted) setState(() {});
        return _lowPowerModeConfirmation?.future;
      }
    }
  }

  /// Complete low power mode confirmation.
  void _onTapConfirm() {
    _showLowPowerModeCard = false;
    _lowPowerModeConfirmation?.complete();
  }

  /// Returns true if [error] is a `dismissed` or `cancelled` exception.
  bool _isDismissedException(final Object error) {
    return (error is SolanaWalletProviderException
      && error.code == SolanaWalletProviderExceptionCode.dismissed)
      || (error is SolanaWalletAdapterException
        && error.code == SolanaWalletAdapterExceptionCode.cancelled);
  }

  /// Sets [_state] and marks the widget as changed to schedule a call to [build].
  void _setMethodState(final SolanaWalletMethodState state) {
    final DismissState? dismissState = widget.dismissState;
    if (dismissState != null && dismissState.equals(state)) {
      SolanaWalletProvider.close(context);
    } else if (_state != state) {
      _state = state;
      if (mounted) setState(() {});
    }
  }

  /// Creates an [AsyncSnapshot] for the current [_state].
  AsyncSnapshot<T> _snapshot() {
    switch(_state) {
      case SolanaWalletMethodState.none:
        return const AsyncSnapshot.nothing();
      case SolanaWalletMethodState.progress:
        return const AsyncSnapshot.waiting();
      case SolanaWalletMethodState.success:
      case SolanaWalletMethodState.error:
        final T? data = _data;
        return data != null
          ? AsyncSnapshot<T>.withData(
              ConnectionState.done, 
              data,
            )
          : AsyncSnapshot<T>.withError(
              ConnectionState.done, 
              _error ?? _invalidException, 
              _stackTrace ?? StackTrace.current,
            );
    }
  }

  @override
  Widget build(final BuildContext context) {
    final Widget child = _showLowPowerModeCard 
      ? SolanaWalletLowPowerModeCard(
          key: const ValueKey(0),
          onPressedConfirm: _onTapConfirm,
        )
      : widget.builder(context, _snapshot(), this);
    return SolanaWalletAnimatedSwitcher(
      child: child.key != null 
        ? child 
        : KeyedSubtree(
            key: ValueKey(_state), 
            child: child,
          ),
    );
  }
}