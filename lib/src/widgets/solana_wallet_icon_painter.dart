/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:math' show max;
import 'package:flutter/material.dart';


/// Solana Wallet Icon Painter
/// ------------------------------------------------------------------------------------------------

/// An icon painter.
@immutable
abstract class SolanaWalletIconPainter extends CustomPainter {
  
  /// Draws an icon.
  const SolanaWalletIconPainter({
    required this.color,
    this.strokeWidth = 3.0,
  });

  /// The icon color.
  final Color color;

  /// The path stroke width.
  final double strokeWidth;

  /// The icon size relative to the canvas size.
  double get scaleFactor => 0.25;
  
  /// Returns a [Rect] of size [inner] centred in [outer].
  Rect center({ required final Size outer, required final Size inner }) {
    assert(outer.width >= inner.width);
    assert(outer.height >= inner.height);
    return Offset((outer.width-inner.width)*0.5, (outer.height-inner.height)*0.5) & inner;
  }

  /// Creates an [RRect] from [rect].
  RRect roundedRect(final Size size, final double radiusFactor) {
    final Rect rect = Offset.zero & size;
    return RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide * radiusFactor));
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

  /// Draws an [rRect] background with a [path] foreground.
  void drawCanvas(
    final Canvas canvas, 
    final Size size, { 
    required final Path path, 
    required final Rect fgRect,
    required final RRect bgRRect,
  }) {
    final Paint paint = painter();
    canvas.saveLayer(Offset.zero & size, paint);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(bgRRect, paint);
    paint.style = PaintingStyle.stroke;
    paint.blendMode = BlendMode.srcOut;
    canvas.drawPath(path, paint);
    paint.blendMode = BlendMode.srcOver;
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => false;
}


/// Solana Wallet Tick Icon
/// ------------------------------------------------------------------------------------------------

/// A tick (✓) icon painter.
@immutable
class SolanaWalletTickIcon extends SolanaWalletIconPainter {

  /// Draws a tick (✓) icon.
  const SolanaWalletTickIcon({
    required super.color,
    super.strokeWidth, 
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final Rect rect = center(outer: size, inner: size * scaleFactor);
    final Size headSize = rect.size * 0.25;
    final Offset point0 = rect.topLeft + Offset(0.0, rect.size.height - headSize.height);
    final Offset point1 = rect.topLeft + Offset(headSize.width, rect.size.height);
    final Offset point2 = rect.topLeft + rect.size.topRight(Offset.zero);
    final Path path = Path()
      ..moveTo(point0.dx, point0.dy)
      ..lineTo(point1.dx, point1.dy)
      ..lineTo(point2.dx, point2.dy);
    drawCanvas(canvas, size, path: path, fgRect: rect, bgRRect: roundedRect(size, 0.5));
  }
}


/// Solana Wallet Bang Icon
/// ------------------------------------------------------------------------------------------------

/// A bang (!) icon painter.
@immutable
class SolanaWalletBangIcon extends SolanaWalletIconPainter {

  /// Draws a bang (!) icon.
  const SolanaWalletBangIcon({
    required super.color,
    super.strokeWidth, 
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final Rect rect = center(outer: size, inner: size * scaleFactor);
    final double markHeight = max(0, rect.height - strokeWidth) * 0.1;
    final double lineHeight = max(0, rect.height - strokeWidth) * 0.7;
    final Offset line0 = rect.topCenter;
    final Offset line1 = Offset(line0.dx, line0.dy + lineHeight);
    final Offset mark0 = Offset(line0.dx, rect.bottom - markHeight);
    final Offset mark1 = Offset(line0.dx, mark0.dy + markHeight);
    final Path path = Path()
      ..moveTo(line0.dx, line0.dy)
      ..lineTo(line1.dx, line1.dy)
      ..moveTo(mark0.dx, mark0.dy)
      ..lineTo(mark1.dx, mark1.dy);
    drawCanvas(canvas, size, path: path, fgRect: rect, bgRRect: roundedRect(size, 0.5));
  }
}


/// Solana Wallet Icon
/// ------------------------------------------------------------------------------------------------

/// A wallet ([ :]) icon painter.
@immutable
class SolanaWalletIcon extends SolanaWalletIconPainter {

  /// Draws a wallet ([ :]) icon.
  const SolanaWalletIcon({
    required super.color,
    super.strokeWidth, 
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final Rect rect = center(outer: size, inner: size * scaleFactor);
    final Offset point0 = Offset(rect.right, rect.top);
    final Offset point1 = Offset(rect.right, rect.bottom);
    final Path path = Path()
      ..moveTo(point0.dx, point0.dy)
      ..lineTo(point1.dx, point1.dy);
    drawCanvas(canvas, size, path: path, fgRect: rect, bgRRect: roundedRect(size, 0.25));
  }
}