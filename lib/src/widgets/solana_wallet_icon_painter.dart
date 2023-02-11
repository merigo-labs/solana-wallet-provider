/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:math' show max;
import 'package:flutter/material.dart';


/// Solana Wallet Icon Painter
/// ------------------------------------------------------------------------------------------------

/// An icon painter.
abstract class SolanaWalletIconPainter extends CustomPainter {
  
  /// Draws an icon.
  const SolanaWalletIconPainter({
    required this.color,
    required this.strokeWidth,
    this.withBorder = true,
  });

  /// The path stroke color.
  final Color color;

  /// The path stroke width.
  final double strokeWidth;

  /// True if the icon should be drawn with a circle border.
  final bool withBorder;

  /// The icon size relative to the canvas size.
  double get scaleFactor => withBorder ? 0.333333 : 1.0;
  
  /// Returns a [Rect] that defines [inner] centred in [outer].
  Rect center({ required final Size outer, required final Size inner }) {
    assert(outer.width >= inner.width);
    assert(outer.height >= inner.height);
    return Offset((outer.width-inner.width)*0.5, (outer.height-inner.height)*0.5) & inner;
  }

  /// Returns a pre configured [Paint] instance.
  Paint painter() {
    return Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
  }

  /// Draws [path] to [canvas].
  void drawCanvas(
    final Canvas canvas, 
    final Size size, { 
    required final Path path, 
    required final Rect rect,
  }) {
    final Paint paint = painter();
    if (withBorder) {
      canvas.drawCircle(rect.center, size.width*0.5, paint);
      canvas.translate(rect.left, rect.top);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => false;
}


/// Solana Wallet Tick Icon
/// ------------------------------------------------------------------------------------------------

/// A tick (✓) icon painter.
class SolanaWalletTickIcon extends SolanaWalletIconPainter {

  /// Draws a tick (✓) icon.
  const SolanaWalletTickIcon({
    required super.color,
    required super.strokeWidth, 
    super.withBorder,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final Rect rect = center(outer: size, inner: size * scaleFactor);
    final Size headSize = rect.size * 0.2;
    final Offset point0 = Offset(0.0, rect.size.height - headSize.height);
    final Offset point1 = Offset(headSize.width, rect.size.height);
    final Offset point2 = rect.size.topRight(Offset.zero);
    final Path path = Path()
      ..moveTo(point0.dx, point0.dy)
      ..lineTo(point1.dx, point1.dy)
      ..lineTo(point2.dx, point2.dy);
    drawCanvas(canvas, size, path: path, rect: rect);
  }
}


/// Solana Wallet Bang Icon
/// ------------------------------------------------------------------------------------------------

/// A bang (!) icon painter.
class SolanaWalletBangIcon extends SolanaWalletIconPainter {

  /// Draws a bang (!) icon.
  const SolanaWalletBangIcon({
    required super.color,
    required super.strokeWidth, 
    super.withBorder,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final Rect rect = center(outer: size, inner: size * scaleFactor);
    final double markHeight = max(0, rect.size.height - strokeWidth) * 0.1;
    final double lineHeight = max(0, rect.size.height - strokeWidth) * 0.7;
    final Offset line0 = rect.size.topCenter(Offset.zero);
    final Offset line1 = Offset(line0.dx, lineHeight);
    final Offset mark0 = Offset(line0.dx, rect.size.height - markHeight);
    final Offset mark1 = Offset(line0.dx, mark0.dy + markHeight);
    final Path path = Path()
      ..moveTo(line0.dx, line0.dy)
      ..lineTo(line1.dx, line1.dy)
      ..moveTo(mark0.dx, mark0.dy)
      ..lineTo(mark1.dx, mark1.dy);
    drawCanvas(canvas, size, path: path, rect: rect);
  }
}