/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';


/// Solana Wallet Countdown
/// ------------------------------------------------------------------------------------------------

/// A widget that display a countdown timer in the format 'mm:ss'.
class SolanaWalletCountdown extends StatefulWidget {

  /// Creates a widget that display a countdown timer in the format 'mm:ss'.
  SolanaWalletCountdown({
    super.key,
    required this.duration,
    this.onTimeout,
  }): assert(duration.inSeconds > 0);

  /// The countdown duration.
  final Duration duration;

  /// Called when [duration] elapses.
  final VoidCallback? onTimeout;

  @override
  State<SolanaWalletCountdown> createState() => _SolanaWalletCountdownState();
}


/// Solana Wallet Countdown State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletCountdownState extends State<SolanaWalletCountdown> {

  /// The periodic timer.
  late final Timer _timer;

  /// The time remaining.
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    _remaining = widget.duration - const Duration(seconds: 1);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Updates [_remaining] and marks the widget as changed to schedule a call to [build] if 
  /// [widget.duration] has not elapsed.
  void _onTick(final Timer timer) {
    _remaining -= const Duration(seconds: 1);
    if (_remaining > Duration.zero) {
      if (mounted) setState(() {});
    } else {
      timer.cancel();
      widget.onTimeout?.call();
    }
  }

  /// Formats [duration] as "mm:ss".
  String _format(final Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        _format(_remaining > Duration.zero ? _remaining : Duration.zero), 
        key: const ValueKey(0),
      ),
    );
  }
}