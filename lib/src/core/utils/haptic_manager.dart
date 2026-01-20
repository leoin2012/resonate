import 'package:flutter/services.dart';

/// Haptic feedback manager
/// Provides abstraction for haptic feedback operations using Flutter's built-in HapticFeedback
class HapticManager {
  /// Singleton instance
  static final HapticManager _instance = HapticManager._internal();
  factory HapticManager() => _instance;
  HapticManager._internal();

  /// Check if haptic feedback is supported
  Future<bool> get hasHapticSupport async {
    // HapticFeedback is always available on iOS
    return true;
  }

  /// Provide haptic feedback for each breath tick
  /// Uses mediumImpact for more noticeable feedback on iPhone
  Future<void> breathTick() async {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback may not be available on all platforms
      // Silently fail to avoid breaking the app
    }
  }

  /// Provide heavy haptic feedback for cycle completion (every 4 seconds)
  Future<void> cycleComplete() async {
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Provide medium haptic feedback for important events
  Future<void> eventTap() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Provide heavy haptic feedback for completion (triple tap)
  Future<void> completion() async {
    try {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Provide success haptic feedback
  Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Provide warning haptic feedback
  Future<void> warning() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently fail
    }
  }

  /// Provide error haptic feedback
  Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently fail
    }
  }
}
