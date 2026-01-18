import 'dart:convert';

/// Breathing session data model
class BreathingSession {
  /// Unique identifier
  int id;

  /// Session start time
  final DateTime startTime;

  /// Session end time
  final DateTime endTime;

  /// Total duration in seconds
  final int duration;

  /// Target duration in seconds
  final int targetDuration;

  /// Was the session completed (target duration reached)
  final bool isCompleted;

  /// Haptic feedback was enabled
  final bool hapticEnabled;

  /// Haptic intensity (0.0 to 1.0)
  final double hapticIntensity;

  /// Animation speed multiplier
  final double animationSpeed;

  /// Notes or comments (optional)
  final String? notes;

  /// Session mode (normal, box_breathing, etc.)
  final String mode;

  /// Breathing cycle count
  final int cycleCount;

  BreathingSession({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.targetDuration,
    required this.isCompleted,
    required this.hapticEnabled,
    required this.hapticIntensity,
    required this.animationSpeed,
    this.notes,
    this.mode = 'normal',
    this.cycleCount = 0,
    int? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch;

  /// Create from JSON (for SharedPreferences)
  factory BreathingSession.fromJson(Map<String, dynamic> json) {
    return BreathingSession(
      id: json['id'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      duration: json['duration'] as int,
      targetDuration: json['targetDuration'] as int,
      isCompleted: json['isCompleted'] as bool,
      hapticEnabled: json['hapticEnabled'] as bool,
      hapticIntensity: (json['hapticIntensity'] as num).toDouble(),
      animationSpeed: (json['animationSpeed'] as num).toDouble(),
      notes: json['notes'] as String?,
      mode: json['mode'] as String? ?? 'normal',
      cycleCount: json['cycleCount'] as int? ?? 0,
    );
  }

  /// Convert to JSON (for SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
      'targetDuration': targetDuration,
      'isCompleted': isCompleted,
      'hapticEnabled': hapticEnabled,
      'hapticIntensity': hapticIntensity,
      'animationSpeed': animationSpeed,
      'notes': notes,
      'mode': mode,
      'cycleCount': cycleCount,
    };
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (targetDuration == 0) return 0.0;
    return (duration / targetDuration).clamp(0.0, 1.0);
  }

  /// Format duration to human-readable string
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format date for display
  String get formattedDate {
    return '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}';
  }

  /// Format time for display
  String get formattedTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }
}
