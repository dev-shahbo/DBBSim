/// Represents the BLE connection status
enum BleStatus {
  disconnected,
  advertising,
  connecting,
  connected;

  String get displayName {
    switch (this) {
      case BleStatus.disconnected:
        return 'Disconnected';
      case BleStatus.advertising:
        return 'Advertising';
      case BleStatus.connecting:
        return 'Connecting...';
      case BleStatus.connected:
        return 'Connected';
    }
  }

  bool get isConnected => this == BleStatus.connected;
  bool get isDisconnected => this == BleStatus.disconnected;
}
