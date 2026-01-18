import 'package:haptic_feedback/haptic_feedback.dart';

/// Haptic feedback manager
/// Provides abstraction for haptic feedback operations
class HapticManager {
  /// Singleton instance
  static final HapticManager _instance = HapticManager._internal();
  factory HapticManager() => _instance;
  HapticManager._internal();

  /// Check if haptic feedback is supported
  Future<bool> get hasHapticSupport async {
    return await Haptics.canVibrate();
  }

  /// Provide light haptic feedback for each breath tick
  Future<void> breathTick() async {
    try {
      await Haptics.vibrate(HapticsType.light);
    } catch (e) {
      // Haptic feedback may not be available on all platforms
      // Silently fail to avoid breaking the app
    }
  }

  /// Provide medium haptic feedback for important events
  Future<void> eventTap() async {
    try {
      await Haptics.vibrate(HapticsType.medium);
    } catch (e) {
      // Silently fail
    }
  }

  /// Provide heavy haptic feedback for completion
  Future<void> completion() async {
    try {
      await Haptics.vibrate(HapticsType.heavy);
    } catch (e) {
      // Silently fail
    }
  }

  /// Provide success haptic feedback
  Future<void> success() async {
    try {
      await Haptics.vibrate(HapticsType.success);
    } catch (e) {
      // Silently fail
    }
  }

  /// Provide warning haptic feedback
  Future<void> warning() async {
    try {
      await Haptics.vibrate(HapticsType.warning);
    } catch (e) {
      // Silently fail
    }
  }

  /// Provide error haptic feedback
  Future<void> error() async {
    try {
      await Haptics.vibrate(HapticsType.error);
    } catch (e) {
      // Silently fail
    }
  }
}
