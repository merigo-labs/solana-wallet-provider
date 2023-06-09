/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../constants.dart';


/// Solana Wallet Icon Painter
/// ------------------------------------------------------------------------------------------------

/// An icon widget.
class SolanaWalletIconPaint extends StatelessWidget {

  /// Creates an icon widget from [painter].
  const SolanaWalletIconPaint({
    super.key,
    required this.painter,
    this.size = kBannerHeight,
  });

  /// The icon painter's constructor.
  final CustomPainter painter;

  /// The icon's width and height.
  final double size;

  @override
  Widget build(final BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: painter,
    );
  }
}