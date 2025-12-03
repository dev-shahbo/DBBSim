import 'package:flutter/material.dart';

/// Application theme constants
class AppTheme {
  AppTheme._();

  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);

  // Status colors
  static const Color safeColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFEB3B);
  static const Color dangerColor = Color(0xFFF44336);

  // BLE Status colors
  static const Color disconnectedColor = Color(0xFF9E9E9E);
  static const Color advertisingColor = Color(0xFF2196F3);
  static const Color connectingColor = Color(0xFFFF9800);
  static const Color connectedColor = Color(0xFF4CAF50);

  // Desk visualization colors
  static const Color deskBorderColor = Color(0xFF424242);
  static const Color deskBackgroundColor = Color(0xFFF5F5F5);
  static const Color crosshairColor = Color(0xFFBDBDBD);
  static const Color gridLineColor = Color(0xFFE0E0E0);

  /// Get light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  /// Get dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}

/// Desk visualization constants
class DeskConstants {
  DeskConstants._();

  /// Safe zone percentage (0-25% of max tilt)
  static const double safeZoneThreshold = 0.25;

  /// Warning zone percentage (25-50% of max tilt)
  static const double warningZoneThreshold = 0.50;

  /// Default desk size
  static const double defaultDeskSize = 300.0;

  /// Dot radius
  static const double dotRadius = 15.0;

  /// Border radius for desk
  static const double deskBorderRadius = 16.0;

  /// Border width for desk
  static const double deskBorderWidth = 3.0;
}

/// Notification period options (in milliseconds)
class NotificationPeriods {
  NotificationPeriods._();

  static const List<int> options = [20, 50, 100, 200, 500];

  static int defaultPeriod = 100;
}

/// Max tilt angle range
class TiltAngleRange {
  TiltAngleRange._();

  static const double min = 5.0;
  static const double max = 30.0;
  static const double defaultValue = 15.0;
}
