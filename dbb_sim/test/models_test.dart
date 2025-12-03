import 'package:flutter_test/flutter_test.dart';
import 'package:dbb_sim/core/models/models.dart';

void main() {
  group('TiltData', () {
    test('should create TiltData with roll and pitch', () {
      final tiltData = TiltData(roll: 5.0, pitch: 10.0);
      expect(tiltData.roll, 5.0);
      expect(tiltData.pitch, 10.0);
    });

    test('should create zero TiltData', () {
      final tiltData = TiltData.zero();
      expect(tiltData.roll, 0.0);
      expect(tiltData.pitch, 0.0);
    });

    test('should copy with updated values', () {
      final original = TiltData(roll: 5.0, pitch: 10.0);
      final copied = original.copyWith(roll: 15.0);
      expect(copied.roll, 15.0);
      expect(copied.pitch, 10.0);
    });
  });

  group('BalanceStatus', () {
    test('should return safe for percentage < 25%', () {
      expect(BalanceStatus.fromTiltPercentage(0.0), BalanceStatus.safe);
      expect(BalanceStatus.fromTiltPercentage(0.24), BalanceStatus.safe);
    });

    test('should return warning for percentage 25-50%', () {
      expect(BalanceStatus.fromTiltPercentage(0.25), BalanceStatus.warning);
      expect(BalanceStatus.fromTiltPercentage(0.49), BalanceStatus.warning);
    });

    test('should return danger for percentage >= 50%', () {
      expect(BalanceStatus.fromTiltPercentage(0.50), BalanceStatus.danger);
      expect(BalanceStatus.fromTiltPercentage(1.0), BalanceStatus.danger);
    });
  });

  group('Settings', () {
    test('should create default settings', () {
      final settings = Settings.defaults();
      expect(settings.notificationPeriodMs, 100);
      expect(settings.maxTiltDeg, 15.0);
      expect(settings.batteryLevelPercent, 100);
    });

    test('should copy with updated values', () {
      final original = Settings.defaults();
      final copied = original.copyWith(notificationPeriodMs: 50);
      expect(copied.notificationPeriodMs, 50);
      expect(copied.maxTiltDeg, 15.0);
    });

    test('should convert to and from JSON', () {
      final original = Settings(
        notificationPeriodMs: 200,
        maxTiltDeg: 20.0,
        batteryLevelPercent: 80,
      );
      final json = original.toJson();
      final restored = Settings.fromJson(json);
      expect(restored.notificationPeriodMs, 200);
      expect(restored.maxTiltDeg, 20.0);
      expect(restored.batteryLevelPercent, 80);
    });
  });

  group('BalanceMode', () {
    test('should have correct display names', () {
      expect(BalanceMode.ble.displayName, 'Live BLE');
      expect(BalanceMode.manual.displayName, 'Manual Simulation');
    });

    test('isBle and isManual should return correct values', () {
      expect(BalanceMode.ble.isBle, true);
      expect(BalanceMode.ble.isManual, false);
      expect(BalanceMode.manual.isBle, false);
      expect(BalanceMode.manual.isManual, true);
    });
  });

  group('BleStatus', () {
    test('should have correct display names', () {
      expect(BleStatus.disconnected.displayName, 'Disconnected');
      expect(BleStatus.advertising.displayName, 'Advertising');
      expect(BleStatus.connecting.displayName, 'Connecting...');
      expect(BleStatus.connected.displayName, 'Connected');
    });

    test('isConnected and isDisconnected should return correct values', () {
      expect(BleStatus.connected.isConnected, true);
      expect(BleStatus.disconnected.isDisconnected, true);
      expect(BleStatus.connecting.isConnected, false);
    });
  });

  group('SessionMetrics', () {
    test('should create a new session', () {
      final metrics = SessionMetrics.start();
      expect(metrics.endTime, isNull);
      expect(metrics.sampleCount, 0);
    });

    test('should calculate zone percentages correctly', () {
      final metrics = SessionMetrics(
        startTime: DateTime.now(),
        timeInSafeZone: const Duration(seconds: 60),
        timeInWarningZone: const Duration(seconds: 30),
        timeInDangerZone: const Duration(seconds: 10),
      );

      expect(metrics.safeZonePercentage, closeTo(0.6, 0.01));
      expect(metrics.warningZonePercentage, closeTo(0.3, 0.01));
      expect(metrics.dangerZonePercentage, closeTo(0.1, 0.01));
    });

    test('should end session', () {
      final metrics = SessionMetrics.start();
      final ended = metrics.end();
      expect(ended.endTime, isNotNull);
    });
  });
}
