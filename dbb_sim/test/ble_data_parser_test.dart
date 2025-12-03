import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dbb_sim/core/utils/ble_data_parser.dart';

void main() {
  group('BleDataParser', () {
    group('parseTiltData (float32)', () {
      test('should parse valid float32 tilt data', () {
        // Create test data: roll = 10.5, pitch = -5.25
        final bytes = Uint8List(8);
        final byteData = ByteData.sublistView(bytes);
        byteData.setFloat32(0, 10.5, Endian.little);
        byteData.setFloat32(4, -5.25, Endian.little);

        final result = BleDataParser.parseTiltData(bytes);

        expect(result, isNotNull);
        expect(result!.roll, closeTo(10.5, 0.001));
        expect(result.pitch, closeTo(-5.25, 0.001));
      });

      test('should return null for data less than 8 bytes', () {
        final bytes = Uint8List(4);
        final result = BleDataParser.parseTiltData(bytes);
        expect(result, isNull);
      });

      test('should return null for empty data', () {
        final result = BleDataParser.parseTiltData([]);
        expect(result, isNull);
      });
    });

    group('parseTiltDataInt16', () {
      test('should parse valid int16 scaled tilt data', () {
        // Create test data: roll = 15.00° (1500), pitch = -7.50° (-750)
        final bytes = Uint8List(4);
        final byteData = ByteData.sublistView(bytes);
        byteData.setInt16(0, 1500, Endian.little);
        byteData.setInt16(2, -750, Endian.little);

        final result = BleDataParser.parseTiltDataInt16(bytes);

        expect(result, isNotNull);
        expect(result!.roll, closeTo(15.0, 0.001));
        expect(result.pitch, closeTo(-7.5, 0.001));
      });

      test('should return null for data less than 4 bytes', () {
        final bytes = Uint8List(2);
        final result = BleDataParser.parseTiltDataInt16(bytes);
        expect(result, isNull);
      });
    });

    group('parseBatteryLevel', () {
      test('should parse valid battery level', () {
        final result = BleDataParser.parseBatteryLevel([75]);
        expect(result, 75);
      });

      test('should return null for empty data', () {
        final result = BleDataParser.parseBatteryLevel([]);
        expect(result, isNull);
      });

      test('should return null for values over 100', () {
        final result = BleDataParser.parseBatteryLevel([150]);
        expect(result, isNull);
      });
    });

    group('encodeNotificationPeriod', () {
      test('should encode notification period correctly', () {
        final encoded = BleDataParser.encodeNotificationPeriod(100);
        expect(encoded.length, 2);
        
        // Decode and verify
        final byteData = ByteData.sublistView(encoded);
        expect(byteData.getInt16(0, Endian.little), 100);
      });
    });

    group('encodeMaxTiltAngle', () {
      test('should encode max tilt angle correctly', () {
        final encoded = BleDataParser.encodeMaxTiltAngle(15.0);
        expect(encoded.length, 4);
        
        // Decode and verify
        final byteData = ByteData.sublistView(encoded);
        expect(byteData.getFloat32(0, Endian.little), closeTo(15.0, 0.001));
      });
    });

    group('encodeBatteryLevel', () {
      test('should encode battery level correctly', () {
        final encoded = BleDataParser.encodeBatteryLevel(85);
        expect(encoded.length, 1);
        expect(encoded[0], 85);
      });

      test('should clamp battery level to 0-100', () {
        expect(BleDataParser.encodeBatteryLevel(-10)[0], 0);
        expect(BleDataParser.encodeBatteryLevel(150)[0], 100);
      });
    });
  });
}
