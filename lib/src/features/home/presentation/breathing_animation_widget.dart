import 'dart:async';
import 'package:flutter/material.dart';
import 'breathing_circle_painter.dart';

/// Breathing animation widget
/// Manages the breathing circle animation with smooth transitions
class BreathingAnimationWidget extends StatefulWidget {
  /// Circle color
  final Color color;

  /// Base radius of the circle
  final double baseRadius;

  /// Maximum expansion radius
  final double maxRadius;

  /// Animation duration in seconds
  final Duration duration;

  /// Whether to sync with breathing timer (4-7-8 pattern)
  final bool syncWithTimer;

  const BreathingAnimationWidget({
    super.key,
    required this.color,
    this.baseRadius = 80.0,
    this.maxRadius = 150.0,
    this.duration = const Duration(seconds: 4),
    this.syncWithTimer = false,
  });

  @override
  State<BreathingAnimationWidget> createState() => _BreathingAnimationWidgetState();
}

class _BreathingAnimationWidgetState extends State<BreathingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  /// Initialize the breathing animation
  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Create smooth sine wave animation for breathing effect
    // This creates a natural, rhythmic expansion and contraction
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth acceleration and deceleration
      ),
    );

    // Start animation loop
    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(BreathingAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animation duration if changed
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: BreathingCirclePainter(
            animationProgress: _animation.value,
            color: widget.color,
            baseRadius: widget.baseRadius,
            maxRadius: widget.maxRadius,
          ),
        );
      },
    );
  }
}
