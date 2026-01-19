import 'package:flutter/material.dart';

/// Custom painter for breathing circle animation
/// Creates a glowing, pulsing circle effect
class BreathingCirclePainter extends CustomPainter {
  /// Animation progress value (0.0 to 1.0)
  final double animationProgress;

  /// Circle color
  final Color color;

  /// Base radius of the circle
  final double baseRadius;

  /// Maximum expansion radius
  final double maxRadius;

  const BreathingCirclePainter({
    required this.animationProgress,
    required this.color,
    this.baseRadius = 80.0,
    this.maxRadius = 150.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate current radius based on animation progress
    // Creates a smooth breathing effect: expand and contract
    final currentRadius = baseRadius + (maxRadius - baseRadius) * animationProgress;

    // Calculate opacity: more transparent when expanded, more opaque when contracted
    final opacityValue = 0.3 + (0.7 * (1.0 - animationProgress));

    // Draw outer glow layer (larger, more transparent)
    _drawGlowLayer(
      canvas,
      center,
      currentRadius * 1.2,
      color.withOpacity( opacityValue * 0.3),
    );

    // Draw middle glow layer
    _drawGlowLayer(
      canvas,
      center,
      currentRadius * 1.1,
      color.withOpacity( opacityValue * 0.5),
    );

    // Draw main circle
    _drawMainCircle(
      canvas,
      center,
      currentRadius,
      color.withOpacity( opacityValue),
    );

    // Draw inner highlight
    _drawHighlight(
      canvas,
      center,
      currentRadius * 0.9,
      color.withOpacity( opacityValue * 0.8),
    );
  }

  /// Draw a glowing layer with blur effect
  void _drawGlowLayer(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  /// Draw the main circle
  void _drawMainCircle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  /// Draw inner highlight circle
  void _drawHighlight(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(BreathingCirclePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.color != color ||
        oldDelegate.baseRadius != baseRadius ||
        oldDelegate.maxRadius != maxRadius;
  }
}
