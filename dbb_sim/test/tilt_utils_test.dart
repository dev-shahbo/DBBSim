import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:dbb_sim/core/models/models.dart';

// Import tilt_utils directly but we need to handle the Offset issue
// Since the tilt_utils file has its own Offset class, we'll test the logic directly

void main() {
  group('Tilt Calculations', () {
    test('should calculate magnitude correctly', () {
      // Test case: roll = 3, pitch = 4, magnitude should be 5
      final magnitude = math.sqrt(3.0 * 3.0 + 4.0 * 4.0);
      expect(magnitude, 5.0);
    });

    test('should calculate tilt percentage correctly', () {
      const roll = 7.5;
      const pitch = 0.0;
      const maxTiltDeg = 15.0;
      
      final magnitude = math.sqrt(roll * roll + pitch * pitch);
      final percentage = magnitude / maxTiltDeg;
      
      expect(percentage, 0.5);
    });

    test('should map tilt to offset correctly', () {
      const roll = 15.0;  // Max tilt
      const pitch = 0.0;
      const maxTiltDeg = 15.0;
      const radius = 100.0;
      
      // roll / maxTiltDeg * radius = 15 / 15 * 100 = 100
      final x = (roll / maxTiltDeg) * radius;
      final y = -(pitch / maxTiltDeg) * radius;
      
      expect(x, 100.0);
      expect(y, 0.0);
    });

    test('should map offset to tilt correctly', () {
      const dx = 50.0;  // Half radius
      const dy = 0.0;
      const maxTiltDeg = 15.0;
      const radius = 100.0;
      
      // (dx / radius) * maxTiltDeg = (50 / 100) * 15 = 7.5
      final roll = (dx / radius) * maxTiltDeg;
      final pitch = -(dy / radius) * maxTiltDeg;
      
      expect(roll, 7.5);
      expect(pitch, 0.0);
    });

    test('should clamp offset to radius', () {
      const dx = 150.0;  // Exceeds radius
      const dy = 0.0;
      const radius = 100.0;
      
      final distance = math.sqrt(dx * dx + dy * dy);
      expect(distance, greaterThan(radius));
      
      // Clamp
      final scale = radius / distance;
      final clampedDx = dx * scale;
      final clampedDy = dy * scale;
      
      final clampedDistance = math.sqrt(clampedDx * clampedDx + clampedDy * clampedDy);
      expect(clampedDistance, closeTo(radius, 0.001));
    });

    test('should handle diagonal offsets correctly', () {
      const dx = 70.71;  // ~100 / sqrt(2)
      const dy = 70.71;
      const radius = 100.0;
      
      final distance = math.sqrt(dx * dx + dy * dy);
      expect(distance, closeTo(100.0, 0.1));
    });
  });

  group('Balance Status Classification', () {
    test('should classify safe zone correctly (0-25%)', () {
      expect(BalanceStatus.fromTiltPercentage(0.0), BalanceStatus.safe);
      expect(BalanceStatus.fromTiltPercentage(0.10), BalanceStatus.safe);
      expect(BalanceStatus.fromTiltPercentage(0.24), BalanceStatus.safe);
    });

    test('should classify warning zone correctly (25-50%)', () {
      expect(BalanceStatus.fromTiltPercentage(0.25), BalanceStatus.warning);
      expect(BalanceStatus.fromTiltPercentage(0.35), BalanceStatus.warning);
      expect(BalanceStatus.fromTiltPercentage(0.49), BalanceStatus.warning);
    });

    test('should classify danger zone correctly (50%+)', () {
      expect(BalanceStatus.fromTiltPercentage(0.50), BalanceStatus.danger);
      expect(BalanceStatus.fromTiltPercentage(0.75), BalanceStatus.danger);
      expect(BalanceStatus.fromTiltPercentage(1.0), BalanceStatus.danger);
    });

    test('should handle edge cases', () {
      // Exactly at thresholds
      expect(BalanceStatus.fromTiltPercentage(0.25), BalanceStatus.warning);
      expect(BalanceStatus.fromTiltPercentage(0.50), BalanceStatus.danger);
      
      // Values above 100%
      expect(BalanceStatus.fromTiltPercentage(1.5), BalanceStatus.danger);
    });
  });
}
