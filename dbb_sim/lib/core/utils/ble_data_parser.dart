import 'dart:typed_data';
import '../models/tilt_data.dart';

/// Utility for parsing BLE data
class BleDataParser {
  BleDataParser._();

  /// Parse tilt data from BLE characteristic value
  /// Expected format: 4 bytes for roll (float32 LE) + 4 bytes for pitch (float32 LE)
  static TiltData? parseTiltData(List<int> data) {
    if (data.length < 8) {
      return null;
    }

    try {
      final bytes = Uint8List.fromList(data);
      final byteData = ByteData.sublistView(bytes);

      final roll = byteData.getFloat32(0, Endian.little);
      final pitch = byteData.getFloat32(4, Endian.little);

      // Validate values are reasonable (not NaN or Infinity)
      if (roll.isNaN || roll.isInfinite || pitch.isNaN || pitch.isInfinite) {
        return null;
      }

      return TiltData.now(roll: roll, pitch: pitch);
    } catch (e) {
      return null;
    }
  }

  /// Parse tilt data from int16 scaled format
  /// Expected format: 2 bytes for roll (int16 LE) + 2 bytes for pitch (int16 LE)
  /// Values are scaled by 100 (e.g., 1500 = 15.00 degrees)
  static TiltData? parseTiltDataInt16(List<int> data) {
    if (data.length < 4) {
      return null;
    }

    try {
      final bytes = Uint8List.fromList(data);
      final byteData = ByteData.sublistView(bytes);

      final rollInt = byteData.getInt16(0, Endian.little);
      final pitchInt = byteData.getInt16(2, Endian.little);

      final roll = rollInt / 100.0;
      final pitch = pitchInt / 100.0;

      return TiltData.now(roll: roll, pitch: pitch);
    } catch (e) {
      return null;
    }
  }

  /// Parse battery level from BLE characteristic value
  /// Expected format: 1 byte (0-100)
  static int? parseBatteryLevel(List<int> data) {
    if (data.isEmpty) {
      return null;
    }

    final level = data[0];
    if (level < 0 || level > 100) {
      return null;
    }

    return level;
  }

  /// Encode notification period for BLE write
  /// Returns 2 bytes (int16 LE)
  static Uint8List encodeNotificationPeriod(int periodMs) {
    final bytes = Uint8List(2);
    final byteData = ByteData.sublistView(bytes);
    byteData.setInt16(0, periodMs, Endian.little);
    return bytes;
  }

  /// Encode max tilt angle for BLE write
  /// Returns 4 bytes (float32 LE)
  static Uint8List encodeMaxTiltAngle(double degrees) {
    final bytes = Uint8List(4);
    final byteData = ByteData.sublistView(bytes);
    byteData.setFloat32(0, degrees, Endian.little);
    return bytes;
  }

  /// Encode battery level for BLE write (simulation)
  /// Returns 1 byte
  static Uint8List encodeBatteryLevel(int percent) {
    return Uint8List.fromList([percent.clamp(0, 100)]);
  }
}
