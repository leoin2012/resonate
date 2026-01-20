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

  /// Provide light haptic feedback for each breath tick
  Future<void> breathTick() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback may not be available on all platforms
      // Silently fail to avoid breaking the app
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

  /// Provide heavy haptic feedback for completion
  Future<void> completion() async {
    try {
      await HapticFeedback.heavyImpact();
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
