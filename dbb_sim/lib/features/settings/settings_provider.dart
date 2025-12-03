import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/models.dart';
import '../ble/ble_service.dart';

/// Settings provider for managing app configuration
class SettingsProvider extends ChangeNotifier {
  static const String _settingsKey = 'app_settings';

  final BleService? _bleService;
  Settings _settings = Settings.defaults();
  bool _isLoading = true;

  SettingsProvider({BleService? bleService}) : _bleService = bleService {
    _loadSettings();
  }

  // Getters
  Settings get settings => _settings;
  bool get isLoading => _isLoading;

  int get notificationPeriodMs => _settings.notificationPeriodMs;
  double get maxTiltDeg => _settings.maxTiltDeg;
  int get batteryLevelPercent => _settings.batteryLevelPercent;
  bool get autoReconnect => _settings.autoReconnect;
  bool get keepScreenOn => _settings.keepScreenOn;
  bool get debugSimulatorEnabled => _settings.debugSimulatorEnabled;

  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final map = json.decode(settingsJson) as Map<String, dynamic>;
        _settings = Settings.fromJson(map);
      }
    } catch (e) {
      // Use defaults if loading fails
      _settings = Settings.defaults();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Save settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Update all settings
  Future<void> updateSettings(Settings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    await _applySettingsToBle();
    notifyListeners();
  }

  /// Update notification period
  Future<void> setNotificationPeriod(int periodMs) async {
    _settings = _settings.copyWith(notificationPeriodMs: periodMs);
    await _saveSettings();
    await _bleService?.setNotificationPeriod(periodMs);
    notifyListeners();
  }

  /// Update max tilt angle
  Future<void> setMaxTiltDeg(double degrees) async {
    _settings = _settings.copyWith(maxTiltDeg: degrees);
    await _saveSettings();
    await _bleService?.setMaxTiltAngle(degrees);
    notifyListeners();
  }

  /// Update battery level (simulation)
  Future<void> setBatteryLevelPercent(int percent) async {
    _settings = _settings.copyWith(batteryLevelPercent: percent);
    await _saveSettings();
    await _bleService?.setBatteryLevel(percent);
    notifyListeners();
  }

  /// Toggle auto reconnect
  Future<void> setAutoReconnect(bool enabled) async {
    _settings = _settings.copyWith(autoReconnect: enabled);
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle keep screen on
  Future<void> setKeepScreenOn(bool enabled) async {
    _settings = _settings.copyWith(keepScreenOn: enabled);
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle debug simulator
  Future<void> setDebugSimulatorEnabled(bool enabled) async {
    _settings = _settings.copyWith(debugSimulatorEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    _settings = Settings.defaults();
    await _saveSettings();
    await _applySettingsToBle();
    notifyListeners();
  }

  Future<void> _applySettingsToBle() async {
    if (_bleService == null || !_bleService!.isConnected) return;

    await _bleService!.setNotificationPeriod(_settings.notificationPeriodMs);
    await _bleService!.setMaxTiltAngle(_settings.maxTiltDeg);
  }
}
