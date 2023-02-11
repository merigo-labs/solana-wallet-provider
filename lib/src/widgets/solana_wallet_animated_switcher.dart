/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../src/solana_wallet_constants.dart';


/// Solana Wallet Animated Switcher
/// ------------------------------------------------------------------------------------------------

/// An [AnimatedSwitcher] with a size and fade transition.
class SolanaWalletAnimatedSwitcher extends AnimatedSwitcher {

  /// Creates an [AnimatedSwitcher] with a size and fade transition.
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