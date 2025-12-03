import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/constants/app_constants.dart';

/// Info panel showing roll, pitch, and status
class AngleInfoPanel extends StatelessWidget {
  final TiltData tiltData;
  final double maxTiltDeg;

  const AngleInfoPanel({
    super.key,
    required this.tiltData,
    this.maxTiltDeg = TiltAngleRange.defaultValue,
  });

  @override
  Widget build(BuildContext context) {
    final magnitude = math.sqrt(
      tiltData.roll * tiltData.roll + tiltData.pitch * tiltData.pitch,
    );
    final percentage = magnitude / maxTiltDeg;
    final status = BalanceStatus.fromTiltPercentage(percentage);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _InfoBox(
              label: 'Roll',
              value: '${tiltData.roll.toStringAsFixed(1)}°',
              color: Theme.of(context).colorScheme.primary,
            ),
            _InfoBox(
              label: 'Pitch',
              value: '${tiltData.pitch.toStringAsFixed(1)}°',
              color: Theme.of(context).colorScheme.secondary,
            ),
            _StatusBox(status: status),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBox extends StatelessWidget {
  final BalanceStatus status;

  const _StatusBox({required this.status});

  Color get _statusColor {
    switch (status) {
      case BalanceStatus.safe:
        return AppTheme.safeColor;
      case BalanceStatus.warning:
        return AppTheme.warningColor;
      case BalanceStatus.danger:
        return AppTheme.dangerColor;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case BalanceStatus.safe:
        return Icons.check_circle;
      case BalanceStatus.warning:
        return Icons.warning;
      case BalanceStatus.danger:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _statusIcon,
                size: 18,
                color: _statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                status.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
