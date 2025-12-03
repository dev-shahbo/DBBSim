import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/models/models.dart';
import '../../core/constants/ble_uuids.dart';
import '../../core/utils/ble_data_parser.dart';

/// BLE Device information
class BleDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final BluetoothDevice device;

  const BleDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
    required this.device,
  });
}

/// BLE Service for managing Bluetooth Low Energy connections
class BleService extends ChangeNotifier {
  BleStatus _status = BleStatus.disconnected;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _tiltSubscription;

  final List<BleDeviceInfo> _discoveredDevices = [];
  int _batteryLevel = 100;
  TiltData _lastTiltData = TiltData.zero();
  String? _lastError;
  bool _isScanning = false;

  // Callbacks
  Function(TiltData)? onTiltDataReceived;

  BleService() {
    _initializeBle();
  }

  // Getters
  BleStatus get status => _status;
  bool get isConnected => _status == BleStatus.connected;
  bool get isScanning => _isScanning;
  List<BleDeviceInfo> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  int get batteryLevel => _batteryLevel;
  TiltData get lastTiltData => _lastTiltData;
  String? get lastError => _lastError;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<void> _initializeBle() async {
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        _lastError = 'Bluetooth not supported on this device';
        notifyListeners();
        return;
      }

      // Listen to adapter state changes
      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        if (state != BluetoothAdapterState.on) {
          _lastError = 'Bluetooth is turned off';
          if (_status == BleStatus.connected) {
            _handleDisconnection();
          }
          notifyListeners();
        } else {
          _lastError = null;
          notifyListeners();
        }
      });
    } catch (e) {
      _lastError = 'Failed to initialize BLE: $e';
      notifyListeners();
    }
  }

  /// Start scanning for BLE devices
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isScanning) return;

    try {
      _discoveredDevices.clear();
      _isScanning = true;
      _lastError = null;
      _status = BleStatus.advertising;
      notifyListeners();

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: [Guid(BleUuids.tiltServiceUuid)],
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final deviceInfo = BleDeviceInfo(
            id: result.device.remoteId.str,
            name: result.device.platformName.isNotEmpty
                ? result.device.platformName
                : 'Unknown Device',
            rssi: result.rssi,
            device: result.device,
          );

          // Add or update device in list
          final existingIndex = _discoveredDevices.indexWhere(
            (d) => d.id == deviceInfo.id,
          );
          if (existingIndex >= 0) {
            _discoveredDevices[existingIndex] = deviceInfo;
          } else {
            _discoveredDevices.add(deviceInfo);
          }
        }
        notifyListeners();
      });

      // When scan completes
      await Future.delayed(timeout);
      await stopScan();
    } catch (e) {
      _lastError = 'Scan failed: $e';
      _isScanning = false;
      _status = BleStatus.disconnected;
      notifyListeners();
    }
  }

  /// Stop scanning for BLE devices
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
    } catch (e) {
      _lastError = 'Failed to stop scan: $e';
    }
    _isScanning = false;
    if (_status == BleStatus.advertising) {
      _status = BleStatus.disconnected;
    }
    notifyListeners();
  }

  /// Connect to a BLE device
  Future<bool> connect(BleDeviceInfo deviceInfo) async {
    if (_status == BleStatus.connected || _status == BleStatus.connecting) {
      return false;
    }

    try {
      _status = BleStatus.connecting;
      _lastError = null;
      notifyListeners();

      // Connect to device
      await deviceInfo.device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevice = deviceInfo.device;

      // Listen for disconnection
      _connectionSubscription = deviceInfo.device.connectionState.listen(
        (BluetoothConnectionState state) {
          if (state == BluetoothConnectionState.disconnected) {
            _handleDisconnection();
          }
        },
      );

      // Discover services and setup notifications
      await _setupServices(deviceInfo.device);

      _status = BleStatus.connected;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'Connection failed: $e';
      _status = BleStatus.disconnected;
      _connectedDevice = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> _setupServices(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();

      for (final service in services) {
        // Find tilt service
        if (service.uuid.str.toLowerCase() == BleUuids.tiltServiceUuid.toLowerCase()) {
          for (final characteristic in service.characteristics) {
            // Subscribe to tilt notifications
            if (characteristic.uuid.str.toLowerCase() ==
                BleUuids.tiltCharacteristicUuid.toLowerCase()) {
              await characteristic.setNotifyValue(true);
              _tiltSubscription = characteristic.lastValueStream.listen(
                _handleTiltNotification,
                onError: (e) {
                  _lastError = 'Tilt notification error: $e';
                  notifyListeners();
                },
              );
            }
          }
        }

        // Find battery service
        if (service.uuid.str.toLowerCase() == BleUuids.batteryServiceUuid.toLowerCase()) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.str.toLowerCase() ==
                BleUuids.batteryLevelCharacteristicUuid.toLowerCase()) {
              // Read battery level
              final value = await characteristic.read();
              final level = BleDataParser.parseBatteryLevel(value);
              if (level != null) {
                _batteryLevel = level;
                notifyListeners();
              }
            }
          }
        }
      }
    } catch (e) {
      _lastError = 'Service discovery failed: $e';
      notifyListeners();
    }
  }

  void _handleTiltNotification(List<int> data) {
    // Try float32 format first
    TiltData? tiltData = BleDataParser.parseTiltData(data);

    // Fallback to int16 format
    tiltData ??= BleDataParser.parseTiltDataInt16(data);

    if (tiltData != null) {
      _lastTiltData = tiltData;
      onTiltDataReceived?.call(tiltData);
      notifyListeners();
    }
  }

  void _handleDisconnection() {
    _status = BleStatus.disconnected;
    _connectedDevice = null;
    _tiltSubscription?.cancel();
    _tiltSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    notifyListeners();
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    try {
      await _tiltSubscription?.cancel();
      _tiltSubscription = null;
      await _connectionSubscription?.cancel();
      _connectionSubscription = null;
      await _connectedDevice?.disconnect();
      _connectedDevice = null;
      _status = BleStatus.disconnected;
      notifyListeners();
    } catch (e) {
      _lastError = 'Disconnect failed: $e';
      notifyListeners();
    }
  }

  /// Read battery level
  Future<int?> readBatteryLevel() async {
    if (_connectedDevice == null) return null;

    try {
      final services = await _connectedDevice!.discoverServices();
      for (final service in services) {
        if (service.uuid.str.toLowerCase() == BleUuids.batteryServiceUuid.toLowerCase()) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.str.toLowerCase() ==
                BleUuids.batteryLevelCharacteristicUuid.toLowerCase()) {
              final value = await characteristic.read();
              final level = BleDataParser.parseBatteryLevel(value);
              if (level != null) {
                _batteryLevel = level;
                notifyListeners();
                return level;
              }
            }
          }
        }
      }
    } catch (e) {
      _lastError = 'Failed to read battery: $e';
      notifyListeners();
    }
    return null;
  }

  /// Set notification period
  Future<bool> setNotificationPeriod(int periodMs) async {
    if (_connectedDevice == null) return false;

    try {
      final services = await _connectedDevice!.discoverServices();
      for (final service in services) {
        if (service.uuid.str.toLowerCase() == BleUuids.tiltServiceUuid.toLowerCase()) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.str.toLowerCase() ==
                BleUuids.notificationPeriodCharacteristicUuid.toLowerCase()) {
              await characteristic.write(
                BleDataParser.encodeNotificationPeriod(periodMs),
                withoutResponse: characteristic.properties.writeWithoutResponse,
              );
              return true;
            }
          }
        }
      }
    } catch (e) {
      _lastError = 'Failed to set notification period: $e';
      notifyListeners();
    }
    return false;
  }

  /// Set max tilt angle
  Future<bool> setMaxTiltAngle(double degrees) async {
    if (_connectedDevice == null) return false;

    try {
      final services = await _connectedDevice!.discoverServices();
      for (final service in services) {
        if (service.uuid.str.toLowerCase() == BleUuids.tiltServiceUuid.toLowerCase()) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.str.toLowerCase() ==
                BleUuids.maxTiltAngleCharacteristicUuid.toLowerCase()) {
              await characteristic.write(
                BleDataParser.encodeMaxTiltAngle(degrees),
                withoutResponse: characteristic.properties.writeWithoutResponse,
              );
              return true;
            }
          }
        }
      }
    } catch (e) {
      _lastError = 'Failed to set max tilt angle: $e';
      notifyListeners();
    }
    return false;
  }

  /// Set battery level (for simulation devices)
  Future<bool> setBatteryLevel(int percent) async {
    if (_connectedDevice == null) return false;

    try {
      final services = await _connectedDevice!.discoverServices();
      for (final service in services) {
        if (service.uuid.str.toLowerCase() == BleUuids.batteryServiceUuid.toLowerCase()) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.str.toLowerCase() ==
                    BleUuids.batteryLevelCharacteristicUuid.toLowerCase() &&
                characteristic.properties.write) {
              await characteristic.write(
                BleDataParser.encodeBatteryLevel(percent),
                withoutResponse: characteristic.properties.writeWithoutResponse,
              );
              _batteryLevel = percent;
              notifyListeners();
              return true;
            }
          }
        }
      }
    } catch (e) {
      _lastError = 'Failed to set battery level: $e';
      notifyListeners();
    }
    return false;
  }

  /// Clear last error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _tiltSubscription?.cancel();
    _connectionSubscription?.cancel();
    _connectedDevice?.disconnect();
    super.dispose();
  }
}
