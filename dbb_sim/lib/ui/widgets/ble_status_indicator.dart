import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/constants/app_constants.dart';

/// BLE status indicator chip for the app bar
class BleStatusIndicator extends StatelessWidget {
  final BleStatus status;
  final int? batteryLevel;
  final VoidCallback? onTap;

  const BleStatusIndicator({
    super.key,
    required this.status,
    this.batteryLevel,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case BleStatus.disconnected:
        return AppTheme.disconnectedColor;
      case BleStatus.advertising:
        return AppTheme.advertisingColor;
      case BleStatus.connecting:
        return AppTheme.connectingColor;
      case BleStatus.connected:
        return AppTheme.connectedColor;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case BleStatus.disconnected:
        return Icons.bluetooth_disabled;
      case BleStatus.advertising:
        return Icons.bluetooth_searching;
      case BleStatus.connecting:
        return Icons.bluetooth_connected;
      case BleStatus.connected:
        return Icons.bluetooth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        avatar: status == BleStatus.connecting
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _statusColor,
                ),
              )
            : Icon(
                _statusIcon,
                size: 18,
                color: _statusColor,
              ),
        label: Text(
          _buildLabel(),
          style: TextStyle(
            fontSize: 12,
            color: _statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: _statusColor.withValues(alpha: 0.1),
        side: BorderSide(color: _statusColor.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _buildLabel() {
    final statusText = status.displayName;
    if (status == BleStatus.connected && batteryLevel != null) {
      return '$statusText • $batteryLevel%';
    }
    return statusText;
  }
}
