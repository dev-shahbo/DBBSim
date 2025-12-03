/// Session metrics for tracking balance performance
class SessionMetrics {
  final DateTime startTime;
  final DateTime? endTime;
  final double maxTiltMagnitude;
  final Duration timeInSafeZone;
  final Duration timeInWarningZone;
  final Duration timeInDangerZone;
  final int sampleCount;

  const SessionMetrics({
    required this.startTime,
    this.endTime,
    this.maxTiltMagnitude = 0.0,
    this.timeInSafeZone = Duration.zero,
    this.timeInWarningZone = Duration.zero,
    this.timeInDangerZone = Duration.zero,
    this.sampleCount = 0,
  });

  /// Create a new session starting now
  factory SessionMetrics.start() {
    return SessionMetrics(startTime: DateTime.now());
  }

  /// Get total session duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get total time tracked in zones
  Duration get totalTrackedTime =>
      timeInSafeZone + timeInWarningZone + timeInDangerZone;

  /// Get percentage of time in safe zone
  double get safeZonePercentage {
    final total = totalTrackedTime.inMilliseconds;
    if (total == 0) return 0.0;
    return timeInSafeZone.inMilliseconds / total;
  }

  /// Get percentage of time in warning zone
  double get warningZonePercentage {
    final total = totalTrackedTime.inMilliseconds;
    if (total == 0) return 0.0;
    return timeInWarningZone.inMilliseconds / total;
  }

  /// Get percentage of time in danger zone
  double get dangerZonePercentage {
    final total = totalTrackedTime.inMilliseconds;
    if (total == 0) return 0.0;
    return timeInDangerZone.inMilliseconds / total;
  }

  /// Copy with updated values
  SessionMetrics copyWith({
    DateTime? startTime,
    DateTime? endTime,
    double? maxTiltMagnitude,
    Duration? timeInSafeZone,
    Duration? timeInWarningZone,
    Duration? timeInDangerZone,
    int? sampleCount,
  }) {
    return SessionMetrics(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxTiltMagnitude: maxTiltMagnitude ?? this.maxTiltMagnitude,
      timeInSafeZone: timeInSafeZone ?? this.timeInSafeZone,
      timeInWarningZone: timeInWarningZone ?? this.timeInWarningZone,
      timeInDangerZone: timeInDangerZone ?? this.timeInDangerZone,
      sampleCount: sampleCount ?? this.sampleCount,
    );
  }

  /// End the session
  SessionMetrics end() {
    return copyWith(endTime: DateTime.now());
  }

  @override
  String toString() =>
      'SessionMetrics(duration: $duration, maxTilt: $maxTiltMagnitude, samples: $sampleCount)';
}
