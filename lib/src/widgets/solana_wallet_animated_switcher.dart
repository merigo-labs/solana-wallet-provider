/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../utils/constants.dart';


/// Solana Wallet Animated Switcher
/// ------------------------------------------------------------------------------------------------

/// An [AnimatedSwitcher] with size and fade transitions.
class SolanaWalletAnimatedSwitcher extends AnimatedSwitcher {

  /// Creates an [AnimatedSwitcher] with size and fade transitions.
  const SolanaWalletAnimatedSwitcher({
    super.key,
    final Duration? duration,
    super.child,
  }): super(
    duration: duration ?? transitionDuration,
    transitionBuilder: _transitionBuilder,
  );
  
  /// Creates a size and fade transition.
  static Widget _transitionBuilder(
    final Widget child, 
    final Animation<double> animation,
  ) => SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
}