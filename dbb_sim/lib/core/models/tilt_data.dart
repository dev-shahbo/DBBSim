import 'dart:math' as math;

/// Represents tilt data from the balance device
class TiltData {
  final double roll;
  final double pitch;
  final DateTime timestamp;

  TiltData({
    required this.roll,
    required this.pitch,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates TiltData with current timestamp
  factory TiltData.now({required double roll, required double pitch}) {
    return TiltData(
      roll: roll,
      pitch: pitch,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a zero/centered TiltData
  factory TiltData.zero() {
    return TiltData.now(roll: 0.0, pitch: 0.0);
  }

  /// Copy with optional parameter updates
  TiltData copyWith({
    double? roll,
    double? pitch,
    DateTime? timestamp,
  }) {
    return TiltData(
      roll: roll ?? this.roll,
      pitch: pitch ?? this.pitch,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Calculate the magnitude of the tilt (combined roll and pitch)
  double get magnitude {
    return math.sqrt(roll * roll + pitch * pitch);
  }

  @override
  String toString() => 'TiltData(roll: $roll, pitch: $pitch)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TiltData && other.roll == roll && other.pitch == pitch;
  }

  @override
  int get hashCode => roll.hashCode ^ pitch.hashCode;
}
