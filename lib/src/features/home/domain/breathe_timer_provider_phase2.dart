import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_manager.dart';

/// Timer state for breathing session (Phase 2: No persistence)
class TimerState {
  /// Current session duration in seconds
  final int duration;
  
  /// Elapsed time in seconds
  final int elapsed;
  
  /// Whether timer is running
  final bool isRunning;
  
  /// Last tick second (for haptic feedback)
  final int lastTickSecond;
  
  /// Cycle count (number of breaths)
  final int cycleCount;

  const TimerState({
    required this.duration,
    this.elapsed = 0,
    this.isRunning = false,
    this.lastTickSecond = 0,
    this.cycleCount = 0,
  });

  TimerState copyWith({
    int? duration,
    int? elapsed,
    bool? isRunning,
    int? lastTickSecond,
    int? cycleCount,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
      lastTickSecond: lastTickSecond ?? this.lastTickSecond,
      cycleCount: cycleCount ?? this.cycleCount,
    );
  }

  /// Get remaining time in seconds
  int get remaining => duration - elapsed;

  /// Get progress percentage (0.0 to 1.0)
  double get progress => elapsed / duration;
}

/// Timer notifier for managing breathing session (Phase 2: No persistence)
class BreathingTimerNotifier extends StateNotifier<TimerState> {
  final HapticManager _hapticManager = HapticManager();
  Timer? _timer;
  int _currentSecond = 0;

  BreathingTimerNotifier() : super(const TimerState(duration: 60));

  /// Start the timer
  Future<void> start() async {
    if (state.isRunning) return;

    state = state.copyWith(
      isRunning: true, 
      lastTickSecond: state.elapsed,
    );
    _currentSecond = state.elapsed;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _currentSecond++;
      
      // Trigger haptic feedback every second
      await _hapticManager.breathTick();

      // Update elapsed time
      state = state.copyWith(
        elapsed: _currentSecond,
        lastTickSecond: _currentSecond,
      );

      // Increment cycle count (every 4 seconds = one breath cycle)
      if (_currentSecond % 4 == 0) {
        state = state.copyWith(cycleCount: state.cycleCount + 1);
      }

      // Stop if duration reached
      if (_currentSecond >= state.duration) {
        await complete();
      }
    });
  }

  /// Pause the timer
  void pause() {
    if (!state.isRunning) return;

    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  /// Resume the timer
  Future<void> resume() async {
    if (state.isRunning) return;
    await start();
  }

  /// Reset the timer
  Future<void> reset() async {
    _timer?.cancel();
    _currentSecond = 0;
    state = const TimerState(duration: 60);
  }

  /// Set duration in seconds
  Future<void> setDuration(int seconds) async {
    _timer?.cancel();
    _currentSecond = 0;
    state = TimerState(duration: seconds);
  }

  /// Complete the session
  Future<void> complete() async {
    pause();
    await _hapticManager.completion();
    // Phase 2: No session saving, just haptic feedback
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider for breathing timer
final breathingTimerProvider =
    StateNotifierProvider<BreathingTimerNotifier, TimerState>((ref) {
  return BreathingTimerNotifier();
});
