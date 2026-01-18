import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App settings state
class SettingsState {
  /// Enable haptic feedback
  final bool hapticEnabled;
  
  /// Haptic feedback intensity (0.0 to 1.0)
  final double hapticIntensity;
  
  /// Default breathing duration in seconds
  final int defaultDuration;
  
  /// Enable sound effects
  final bool soundEnabled;
  
  /// Animation speed multiplier (0.5 to 2.0)
  final double animationSpeed;

  const SettingsState({
    this.hapticEnabled = true,
    this.hapticIntensity = 0.7,
    this.defaultDuration = 60,
    this.soundEnabled = false,
    this.animationSpeed = 1.0,
  });

  SettingsState copyWith({
    bool? hapticEnabled,
    double? hapticIntensity,
    int? defaultDuration,
    bool? soundEnabled,
    double? animationSpeed,
  }) {
    return SettingsState(
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      animationSpeed: animationSpeed ?? this.animationSpeed,
    );
  }
}

/// Settings notifier for managing app settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  /// Toggle haptic feedback
  void toggleHaptic() {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
  }

  /// Update haptic intensity
  void updateHapticIntensity(double intensity) {
    state = state.copyWith(hapticIntensity: intensity);
  }

  /// Update default duration
  void updateDefaultDuration(int duration) {
    state = state.copyWith(defaultDuration: duration);
  }

  /// Toggle sound effects
  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  /// Update animation speed
  void updateAnimationSpeed(double speed) {
    state = state.copyWith(animationSpeed: speed);
  }

  /// Reset all settings to default
  void resetToDefaults() {
    state = const SettingsState();
  }
}

/// Provider for settings state
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
