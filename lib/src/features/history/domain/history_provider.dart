import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/breathing_session.dart';
import '../../../data/repositories/session_repository.dart';

/// History state
class HistoryState {
  /// List of sessions
  final List<BreathingSession> sessions;
  
  /// Loading state
  final bool isLoading;
  
  /// Error message
  final String? error;
  
  /// Statistics for the selected period
  final SessionStats? stats;
  
  /// Daily statistics
  final List<DailyStats> dailyStats;

  const HistoryState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.stats,
    this.dailyStats = const [],
  });

  HistoryState copyWith({
    List<BreathingSession>? sessions,
    bool? isLoading,
    String? error,
    SessionStats? stats,
    List<DailyStats>? dailyStats,
  }) {
    return HistoryState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      dailyStats: dailyStats ?? this.dailyStats,
    );
  }
}

/// History notifier for managing history state
class HistoryNotifier extends StateNotifier<HistoryState> {
  final SessionRepository _repository;

  HistoryNotifier(this._repository) : super(const HistoryState());

  /// Load all sessions
  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final sessions = await _repository.getAllSessions();
      state = state.copyWith(
        sessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load sessions from the last N days
  Future<void> loadRecentSessions(int days) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final sessions = await _repository.getSessionsFromLastDays(days);
      state = state.copyWith(
        sessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load today's sessions
  Future<void> loadTodaySessions() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final sessions = await _repository.getTodaySessions();
      state = state.copyWith(
        sessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load statistics
  Future<void> loadStats({int days = 7}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stats = await _repository.getStats(days: days);
      state = state.copyWith(
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load daily statistics
  Future<void> loadDailyStats({int days = 7}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final dailyStats = await _repository.getDailyStats(days);
      state = state.copyWith(
        dailyStats: dailyStats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load all data at once
  Future<void> loadAll({int days = 7}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final results = await Future.wait([
        _repository.getSessionsFromLastDays(days),
        _repository.getStats(days: days),
        _repository.getDailyStats(days),
      ]);

      state = state.copyWith(
        sessions: results[0] as List<BreathingSession>,
        stats: results[1] as SessionStats,
        dailyStats: results[2] as List<DailyStats>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Delete a session
  Future<void> deleteSession(int id) async {
    try {
      await _repository.deleteSession(id);
      // Refresh sessions list
      await loadSessions();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete all sessions
  Future<void> deleteAllSessions() async {
    try {
      await _repository.clearAllSessions();
      state = state.copyWith(sessions: [], stats: SessionStats.zero());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for history state
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final repository = SessionRepository.instance;
  return HistoryNotifier(repository);
});
