/// Application settings model
class Settings {
  final int notificationPeriodMs;
  final double maxTiltDeg;
  final int batteryLevelPercent;
  final bool autoReconnect;
  final bool keepScreenOn;
  final bool debugSimulatorEnabled;

  const Settings({
    this.notificationPeriodMs = 100,
    this.maxTiltDeg = 15.0,
    this.batteryLevelPercent = 100,
    this.autoReconnect = true,
    this.keepScreenOn = true,
    this.debugSimulatorEnabled = false,
  });

  /// Default settings
  factory Settings.defaults() => const Settings();

  /// Copy with optional parameter updates
  Settings copyWith({
    int? notificationPeriodMs,
    double? maxTiltDeg,
    int? batteryLevelPercent,
    bool? autoReconnect,
    bool? keepScreenOn,
    bool? debugSimulatorEnabled,
  }) {
    return Settings(
      notificationPeriodMs: notificationPeriodMs ?? this.notificationPeriodMs,
      maxTiltDeg: maxTiltDeg ?? this.maxTiltDeg,
      batteryLevelPercent: batteryLevelPercent ?? this.batteryLevelPercent,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      debugSimulatorEnabled: debugSimulatorEnabled ?? this.debugSimulatorEnabled,
    );
  }

  /// Convert to Map for persistence
  Map<String, dynamic> toJson() {
    return {
      'notificationPeriodMs': notificationPeriodMs,
      'maxTiltDeg': maxTiltDeg,
      'batteryLevelPercent': batteryLevelPercent,
      'autoReconnect': autoReconnect,
      'keepScreenOn': keepScreenOn,
      'debugSimulatorEnabled': debugSimulatorEnabled,
    };
  }

  /// Create from Map
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      notificationPeriodMs: json['notificationPeriodMs'] as int? ?? 100,
      maxTiltDeg: (json['maxTiltDeg'] as num?)?.toDouble() ?? 15.0,
      batteryLevelPercent: json['batteryLevelPercent'] as int? ?? 100,
      autoReconnect: json['autoReconnect'] as bool? ?? true,
      keepScreenOn: json['keepScreenOn'] as bool? ?? true,
      debugSimulatorEnabled: json['debugSimulatorEnabled'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'Settings(notificationPeriodMs: $notificationPeriodMs, maxTiltDeg: $maxTiltDeg, batteryLevelPercent: $batteryLevelPercent)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.notificationPeriodMs == notificationPeriodMs &&
        other.maxTiltDeg == maxTiltDeg &&
        other.batteryLevelPercent == batteryLevelPercent &&
        other.autoReconnect == autoReconnect &&
        other.keepScreenOn == keepScreenOn &&
        other.debugSimulatorEnabled == debugSimulatorEnabled;
  }

  @override
  int get hashCode =>
      notificationPeriodMs.hashCode ^
      maxTiltDeg.hashCode ^
      batteryLevelPercent.hashCode ^
      autoReconnect.hashCode ^
      keepScreenOn.hashCode ^
      debugSimulatorEnabled.hashCode;
}
