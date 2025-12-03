import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../core/models/models.dart';
import '../ble/ble_service.dart';

/// Balance state provider for managing tilt data and mode
class BalanceProvider extends ChangeNotifier {
  final BleService _bleService;

  BalanceMode _mode = BalanceMode.manual;
  TiltData _currentTilt = TiltData.zero();
  Settings _settings = Settings.defaults();
  SessionMetrics? _sessionMetrics;

  // Calibration offsets
  double _rollOffset = 0.0;
  double _pitchOffset = 0.0;

  // Simulator
  Timer? _simulatorTimer;
  double _simulatorPhase = 0.0;

  BalanceProvider(this._bleService) {
    _bleService.onTiltDataReceived = _onBleTiltReceived;
    _bleService.addListener(_onBleServiceChanged);
  }

  // Getters
  BalanceMode get mode => _mode;
  TiltData get currentTilt => _currentTilt;
  Settings get settings => _settings;
  SessionMetrics? get sessionMetrics => _sessionMetrics;
  bool get isSessionActive => _sessionMetrics != null && _sessionMetrics!.endTime == null;
  BleService get bleService => _bleService;

  /// Get calibrated tilt data
  TiltData get calibratedTilt {
    return TiltData.now(
      roll: _currentTilt.roll - _rollOffset,
      pitch: _currentTilt.pitch - _pitchOffset,
    );
  }

  /// Get balance status based on current tilt
  BalanceStatus get balanceStatus {
    final magnitude = _calculateMagnitude(calibratedTilt);
    final percentage = magnitude / _settings.maxTiltDeg;
    return BalanceStatus.fromTiltPercentage(percentage);
  }

  /// Set balance mode
  void setMode(BalanceMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;

    if (_mode == BalanceMode.manual) {
      // Reset to center when switching to manual
      _currentTilt = TiltData.zero();
    }

    notifyListeners();
  }

  /// Update tilt from manual drag
  void setManualTilt(TiltData tilt) {
    if (_mode != BalanceMode.manual) return;
    _currentTilt = tilt;
    _updateSessionMetrics();
    notifyListeners();
  }

  /// Reset tilt to center (0, 0)
  void resetToCenter() {
    _currentTilt = TiltData.zero();
    notifyListeners();
  }

  /// Update settings
  void updateSettings(Settings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  /// Calibrate: set current position as zero
  void calibrate() {
    _rollOffset = _currentTilt.roll;
    _pitchOffset = _currentTilt.pitch;
    notifyListeners();
  }

  /// Clear calibration offsets
  void clearCalibration() {
    _rollOffset = 0.0;
    _pitchOffset = 0.0;
    notifyListeners();
  }

  /// Start a new session
  void startSession() {
    _sessionMetrics = SessionMetrics.start();
    notifyListeners();
  }

  /// End the current session
  void endSession() {
    if (_sessionMetrics != null) {
      _sessionMetrics = _sessionMetrics!.end();
      notifyListeners();
    }
  }

  /// Start debug simulator
  void startSimulator() {
    if (_simulatorTimer != null) return;

    _simulatorTimer = Timer.periodic(
      Duration(milliseconds: _settings.notificationPeriodMs),
      _simulatorTick,
    );
    notifyListeners();
  }

  /// Stop debug simulator
  void stopSimulator() {
    _simulatorTimer?.cancel();
    _simulatorTimer = null;
    notifyListeners();
  }

  bool get isSimulatorRunning => _simulatorTimer != null;

  void _simulatorTick(Timer timer) {
    _simulatorPhase += 0.05;

    // Generate smooth random-ish tilt using sine waves
    final roll = math.sin(_simulatorPhase) * _settings.maxTiltDeg * 0.6 +
        math.sin(_simulatorPhase * 2.3) * _settings.maxTiltDeg * 0.2;
    final pitch = math.cos(_simulatorPhase * 0.8) * _settings.maxTiltDeg * 0.5 +
        math.cos(_simulatorPhase * 1.7) * _settings.maxTiltDeg * 0.3;

    _currentTilt = TiltData.now(roll: roll, pitch: pitch);
    _updateSessionMetrics();
    notifyListeners();
  }

  void _onBleTiltReceived(TiltData tilt) {
    if (_mode != BalanceMode.ble) return;
    _currentTilt = tilt;
    _updateSessionMetrics();
    notifyListeners();
  }

  void _onBleServiceChanged() {
    // Notify listeners when BLE service changes (status, battery, etc.)
    notifyListeners();
  }

  void _updateSessionMetrics() {
    if (_sessionMetrics == null || _sessionMetrics!.endTime != null) return;

    final magnitude = _calculateMagnitude(calibratedTilt);
    final percentage = magnitude / _settings.maxTiltDeg;
    final status = BalanceStatus.fromTiltPercentage(percentage);

    final updateDuration = Duration(milliseconds: _settings.notificationPeriodMs);

    _sessionMetrics = _sessionMetrics!.copyWith(
      maxTiltMagnitude: math.max(_sessionMetrics!.maxTiltMagnitude, magnitude),
      sampleCount: _sessionMetrics!.sampleCount + 1,
      timeInSafeZone: status == BalanceStatus.safe
          ? _sessionMetrics!.timeInSafeZone + updateDuration
          : _sessionMetrics!.timeInSafeZone,
      timeInWarningZone: status == BalanceStatus.warning
          ? _sessionMetrics!.timeInWarningZone + updateDuration
          : _sessionMetrics!.timeInWarningZone,
      timeInDangerZone: status == BalanceStatus.danger
          ? _sessionMetrics!.timeInDangerZone + updateDuration
          : _sessionMetrics!.timeInDangerZone,
    );
  }

  double _calculateMagnitude(TiltData tilt) {
    return math.sqrt(tilt.roll * tilt.roll + tilt.pitch * tilt.pitch);
  }

  @override
  void dispose() {
    _simulatorTimer?.cancel();
    _bleService.removeListener(_onBleServiceChanged);
    super.dispose();
  }
}
