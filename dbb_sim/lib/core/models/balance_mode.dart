/// Represents the balance mode (BLE or Manual)
enum BalanceMode {
  ble,
  manual;

  String get displayName {
    switch (this) {
      case BalanceMode.ble:
        return 'Live BLE';
      case BalanceMode.manual:
        return 'Manual Simulation';
    }
  }

  bool get isBle => this == BalanceMode.ble;
  bool get isManual => this == BalanceMode.manual;
}
