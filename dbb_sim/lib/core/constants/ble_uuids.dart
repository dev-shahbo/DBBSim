/// BLE Service and Characteristic UUIDs
class BleUuids {
  BleUuids._();

  /// Tilt Service UUID
  static const String tiltServiceUuid = '12345678-1234-5678-1234-56789abcdef0';

  /// Tilt Characteristic UUID (notifications: roll/pitch)
  static const String tiltCharacteristicUuid = '12345678-1234-5678-1234-56789abcdef1';

  /// Battery Service UUID (standard BLE Battery Service)
  static const String batteryServiceUuid = '0000180f-0000-1000-8000-00805f9b34fb';

  /// Battery Level Characteristic UUID (standard BLE Battery Level)
  static const String batteryLevelCharacteristicUuid = '00002a19-0000-1000-8000-00805f9b34fb';

  /// Settings Characteristic UUID (for configuration)
  static const String settingsCharacteristicUuid = '12345678-1234-5678-1234-56789abcdef2';

  /// Notification Period Characteristic UUID
  static const String notificationPeriodCharacteristicUuid = '12345678-1234-5678-1234-56789abcdef3';

  /// Max Tilt Angle Characteristic UUID
  static const String maxTiltAngleCharacteristicUuid = '12345678-1234-5678-1234-56789abcdef4';
}
