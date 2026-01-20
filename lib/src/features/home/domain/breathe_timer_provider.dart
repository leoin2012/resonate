import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_manager.dart';
import '../../../data/models/breathing_session.dart';
import '../../../data/repositories/session_repository.dart';

/// Timer state for breathing session
class TimerState {
  /// Current session duration in seconds
  final int duration;
  
  /// Elapsed time in seconds
  final int elapsed;
  
  /// Whether timer is running
  final bool isRunning;
  
  /// Last tick second (for haptic feedback)
  final int lastTickSecond;
  
  /// Session start time
  final DateTime? sessionStartTime;
  
  /// Cycle count (number of breaths)
  final int cycleCount;

  const TimerState({
    required this.duration,
    this.elapsed = 0,
    this.isRunning = false,
    this.lastTickSecond = 0,
    this.sessionStartTime,
    this.cycleCount = 0,
  });

  TimerState copyWith({
    int? duration,
    int? elapsed,
    bool? isRunning,
    int? lastTickSecond,
    DateTime? sessionStartTime,
    int? cycleCount,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
      lastTickSecond: lastTickSecond ?? this.lastTickSecond,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      cycleCount: cycleCount ?? this.cycleCount,
    );
  }

  /// Get remaining time in seconds
  int get remaining => duration - elapsed;

  /// Get progress percentage (0.0 to 1.0)
  double get progress => elapsed / duration;
}

/// Timer notifier for managing breathing session
class BreathingTimerNotifier extends StateNotifier<TimerState> {
  final HapticManager _hapticManager = HapticManager();
  Timer? _timer;
  int _currentSecond = 0;

  BreathingTimerNotifier() : super(const TimerState(duration: 60));

  /// Start the timer
  Future<void> start() async {
    if (state.isRunning) return;

    // Record session start time if not already set
    final sessionStartTime = state.sessionStartTime ?? DateTime.now();
    
    state = state.copyWith(
      isRunning: true, 
      lastTickSecond: state.elapsed,
      sessionStartTime: sessionStartTime,
    );
    _currentSecond = state.elapsed;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentSecond++;
      
      // Trigger haptic feedback every second (sync call for reliability)
      _hapticManager.breathTick();

      // Update elapsed time
      state = state.copyWith(
        elapsed: _currentSecond,
        lastTickSecond: _currentSecond,
      );

      // Increment cycle count (every 4 seconds = one breath cycle)
      // Heavy haptic at cycle completion
      if (_currentSecond % 4 == 0) {
        state = state.copyWith(cycleCount: state.cycleCount + 1);
        _hapticManager.cycleComplete();
      }

      // Stop if duration reached
      if (_currentSecond >= state.duration) {
        complete();
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
    // Save session if it had data
    if (state.elapsed > 0) {
      await _saveSession();
    }
    
    _timer?.cancel();
    _currentSecond = 0;
    state = const TimerState(duration: 60);
  }

  /// Set duration in seconds
  Future<void> setDuration(int seconds) async {
    // Save session if it had data
    if (state.elapsed > 0) {
      await _saveSession();
    }
    
    _timer?.cancel();
    _currentSecond = 0;
    state = TimerState(duration: seconds);
  }

  /// Complete the session
  Future<void> complete() async {
    pause();
    await _hapticManager.completion();
    
    // Save the completed session
    await _saveSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Save current session to database
  Future<void> _saveSession() async {
    if (state.sessionStartTime == null) return;
    
    final endTime = DateTime.now();

    // Create breathing session record
    final session = BreathingSession(
      startTime: state.sessionStartTime!,
      endTime: endTime,
      duration: state.elapsed,
      targetDuration: state.duration,
      isCompleted: state.elapsed >= state.duration,
      hapticEnabled: true, // Will be updated when we have access to settings
      hapticIntensity: 0.7, // Default, will be updated from settings
      animationSpeed: 1.0, // Default, will be updated from settings
      mode: 'normal',
      cycleCount: state.cycleCount,
    );

    // Save to repository
    try {
      final repository = SessionRepository.instance;
      await repository.saveSession(session);
    } catch (e) {
      // Log error but don't block the UI
      print('Failed to save session: $e');
    }
  }
}

/// Provider for breathing timer
final breathingTimerProvider =
    StateNotifierProvider<BreathingTimerNotifier, TimerState>((ref) {
  return BreathingTimerNotifier();
});
