import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/breathing_session.dart';

/// Session repository using SharedPreferences for cross-platform support
class SessionRepository {
  /// Get singleton instance
  static SessionRepository get instance => _instance;
  static final SessionRepository _instance = SessionRepository._internal();

  /// Internal constructor
  SessionRepository._internal();

  /// Storage key for sessions
  static const String _sessionsKey = 'breathing_sessions';

  /// Check if repository is available
  bool get isAvailable => true;

  /// Save a breathing session
  Future<void> saveSession(BreathingSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await _loadSessions(prefs);
    sessions.add(session);
    await _saveSessions(prefs, sessions);
  }

  /// Get all sessions
  Future<List<BreathingSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await _loadSessions(prefs);
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  /// Get sessions by date range
  Future<List<BreathingSession>> getSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final sessions = await getAllSessions();
    return sessions.where((s) {
      return (s.startTime.isAfter(start) || s.startTime.isAtSameMomentAs(start)) &&
             (s.startTime.isBefore(end) || s.startTime.isAtSameMomentAs(end));
    }).toList();
  }

  /// Get sessions from today
  Future<List<BreathingSession>> getTodaySessions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await getSessionsByDateRange(startOfDay, endOfDay);
  }

  /// Get sessions from the last N days
  Future<List<BreathingSession>> getSessionsFromLastDays(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    return await getSessionsByDateRange(startDate, now);
  }

  /// Delete a session by id
  Future<void> deleteSession(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await _loadSessions(prefs);
    sessions.removeWhere((s) => s.id == id);
    await _saveSessions(prefs, sessions);
  }

  /// Clear all sessions
  Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final sessions = await getAllSessions();
    if (sessions.isEmpty) {
      return {
        'totalCount': 0,
        'completedCount': 0,
        'totalDuration': 0,
        'averageDuration': 0,
        'completionRate': 0.0,
      };
    }

    final totalCount = sessions.length;
    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    final completedCount = completedSessions.length;
    final totalDuration = sessions.fold<int>(0, (sum, s) => sum + s.duration);
    final averageDuration = totalDuration / totalCount;
    final completionRate = completedCount / totalCount;

    return {
      'totalCount': totalCount,
      'completedCount': completedCount,
      'totalDuration': totalDuration,
      'averageDuration': averageDuration,
      'completionRate': completionRate,
    };
  }

  /// Get session statistics
  Future<SessionStats> getStats({int days = 7}) async {
    final sessions = await getSessionsFromLastDays(days);
    
    if (sessions.isEmpty) {
      return SessionStats.zero();
    }

    final totalDuration = sessions.fold<int>(
      0,
      (sum, session) => sum + session.duration,
    );

    final completedSessions = sessions
        .where((session) => session.isCompleted)
        .length;

    final avgDuration = totalDuration / sessions.length;
    
    final avgCompletion = sessions.isEmpty
        ? 0.0
        : sessions.fold<double>(
            0.0,
            (sum, session) => sum + session.completionPercentage,
          ) / sessions.length;

    return SessionStats(
      totalSessions: sessions.length,
      completedSessions: completedSessions,
      totalDuration: totalDuration,
      averageDuration: avgDuration,
      averageCompletion: avgCompletion,
    );
  }

  /// Get daily statistics
  Future<List<DailyStats>> getDailyStats(int days) async {
    final now = DateTime.now();
    final stats = <DailyStats>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: i),
      );
      final nextDay = date.add(const Duration(days: 1));
      
      final sessions = await getSessionsByDateRange(date, nextDay);
      
      final totalDuration = sessions.fold<int>(
        0,
        (sum, session) => sum + session.duration,
      );

      final completed = sessions
          .where((session) => session.isCompleted)
          .length;

      stats.add(DailyStats(
        date: date,
        sessionCount: sessions.length,
        totalDuration: totalDuration,
        completedSessions: completed,
      ));
    }

    return stats;
  }

  /// Load sessions from SharedPreferences
  Future<List<BreathingSession>> _loadSessions(SharedPreferences prefs) async {
    final jsonString = prefs.getString(_sessionsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => BreathingSession.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save sessions to SharedPreferences
  Future<void> _saveSessions(
    SharedPreferences prefs,
    List<BreathingSession> sessions,
  ) async {
    final jsonString = json.encode(
      sessions.map((s) => s.toJson()).toList(),
    );
    await prefs.setString(_sessionsKey, jsonString);
  }
}

/// Session statistics data class
class SessionStats {
  final int totalSessions;
  final int completedSessions;
  final int totalDuration;
  final double averageDuration;
  final double averageCompletion;

  const SessionStats({
    required this.totalSessions,
    required this.completedSessions,
    required this.totalDuration,
    required this.averageDuration,
    required this.averageCompletion,
  });

  /// Completion rate (0.0 to 1.0)
  double get completionRate {
    if (totalSessions == 0) return 0.0;
    return completedSessions / totalSessions;
  }

  /// Format total duration as hours and minutes
  String get formattedTotalDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Zero stats
  factory SessionStats.zero() {
    return const SessionStats(
      totalSessions: 0,
      completedSessions: 0,
      totalDuration: 0,
      averageDuration: 0.0,
      averageCompletion: 0.0,
    );
  }
}

/// Daily statistics for charts
class DailyStats {
  final DateTime date;
  final int sessionCount;
  final int totalDuration;
  final int completedSessions;

  const DailyStats({
    required this.date,
    required this.sessionCount,
    required this.totalDuration,
    required this.completedSessions,
  });

  /// Average session duration for this day
  double get averageDuration {
    if (sessionCount == 0) return 0.0;
    return totalDuration / sessionCount;
  }

  /// Completion rate for this day
  double get completionRate {
    if (sessionCount == 0) return 0.0;
    return completedSessions / sessionCount;
  }
}
