import 'dart:math' as math;
import 'dart:ui' show Offset;
import '../models/tilt_data.dart';
import '../models/balance_status.dart';

/// Utility functions for tilt calculations
class TiltUtils {
  TiltUtils._();

  /// Calculate the magnitude of tilt from roll and pitch
  static double calculateMagnitude(double roll, double pitch) {
    return math.sqrt(roll * roll + pitch * pitch);
  }

  /// Get the percentage of tilt relative to max tilt
  static double getTiltPercentage(TiltData tiltData, double maxTiltDeg) {
    final magnitude = calculateMagnitude(tiltData.roll, tiltData.pitch);
    return (magnitude / maxTiltDeg).clamp(0.0, 1.0);
  }

  /// Get balance status from tilt data
  static BalanceStatus getBalanceStatus(TiltData tiltData, double maxTiltDeg) {
    final percentage = getTiltPercentage(tiltData, maxTiltDeg);
    return BalanceStatus.fromTiltPercentage(percentage);
  }

  /// Convert roll/pitch to offset inside the desk
  /// Center = (0,0), Edge ≈ ±maxTiltDeg
  static Offset tiltToOffset(TiltData tiltData, double maxTiltDeg, double radius) {
    final x = (tiltData.roll / maxTiltDeg) * radius;
    // Y is inverted: positive pitch tilts forward (up on screen = negative Y)
    final y = -(tiltData.pitch / maxTiltDeg) * radius;

    // Clamp to desk radius
    final distance = math.sqrt(x * x + y * y);
    if (distance > radius) {
      final scale = radius / distance;
      return Offset(x * scale, y * scale);
    }
    return Offset(x, y);
  }

  /// Convert drag offset to tilt data
  /// Used in manual mode to convert user drag to roll/pitch values
  static TiltData offsetToTilt(Offset offset, double maxTiltDeg, double radius) {
    // Clamp offset to radius first
    final distance = math.sqrt(offset.dx * offset.dx + offset.dy * offset.dy);
    Offset clampedOffset = offset;
    if (distance > radius) {
      final scale = radius / distance;
      clampedOffset = Offset(offset.dx * scale, offset.dy * scale);
    }

    final roll = (clampedOffset.dx / radius) * maxTiltDeg;
    // Invert Y axis: dragging up (negative dy) = positive pitch
    final pitch = -(clampedOffset.dy / radius) * maxTiltDeg;

    return TiltData.now(roll: roll, pitch: pitch);
  }

  /// Clamp offset to desk radius
  static Offset clampToRadius(Offset offset, double radius) {
    final distance = math.sqrt(offset.dx * offset.dx + offset.dy * offset.dy);
    if (distance > radius) {
      final scale = radius / distance;
      return Offset(offset.dx * scale, offset.dy * scale);
    }
    return offset;
  }
}
