/// Represents the status of the balance based on tilt magnitude
enum BalanceStatus {
  safe,
  warning,
  danger;

  String get displayName {
    switch (this) {
      case BalanceStatus.safe:
        return 'Stable';
      case BalanceStatus.warning:
        return 'Slight tilt';
      case BalanceStatus.danger:
        return 'High tilt';
    }
  }

  /// Get status based on tilt magnitude as percentage of max
  static BalanceStatus fromTiltPercentage(double percentage) {
    if (percentage < 0.25) {
      return BalanceStatus.safe;
    } else if (percentage < 0.50) {
      return BalanceStatus.warning;
    } else {
      return BalanceStatus.danger;
    }
  }
}
