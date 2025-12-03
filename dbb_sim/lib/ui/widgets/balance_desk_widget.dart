import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/constants/app_constants.dart';
import 'desk_painter.dart';

/// Balance desk widget showing the desk visualization with tilt dot
class BalanceDeskWidget extends StatelessWidget {
  final TiltData tiltData;
  final double maxTiltDeg;
  final BalanceMode mode;
  final double size;
  final void Function(TiltData)? onManualTiltChanged;

  const BalanceDeskWidget({
    super.key,
    required this.tiltData,
    this.maxTiltDeg = TiltAngleRange.defaultValue,
    this.mode = BalanceMode.manual,
    this.size = DeskConstants.defaultDeskSize,
    this.onManualTiltChanged,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size / 2 - DeskConstants.deskBorderWidth;

    return GestureDetector(
      onPanStart: mode == BalanceMode.manual ? _handlePanStart : null,
      onPanUpdate: mode == BalanceMode.manual ? _handlePanUpdate : null,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Desk background with zones and crosshair
            CustomPaint(
              size: Size(size, size),
              painter: DeskPainter(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2D2D2D)
                    : AppTheme.deskBackgroundColor,
                borderColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[600]!
                    : AppTheme.deskBorderColor,
                crosshairColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[500]!
                    : AppTheme.crosshairColor,
                gridLineColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : AppTheme.gridLineColor,
              ),
            ),
            // Tilt dot (patient circle / center of mass marker)
            _TiltDot(
              tiltData: tiltData,
              maxTiltDeg: maxTiltDeg,
              radius: radius,
              centerOffset: Offset(size / 2, size / 2),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    _updateTiltFromPosition(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _updateTiltFromPosition(details.localPosition);
  }

  void _updateTiltFromPosition(Offset position) {
    if (onManualTiltChanged == null) return;

    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - DeskConstants.deskBorderWidth;

    // Calculate offset from center
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    // Clamp to radius
    final distance = math.sqrt(dx * dx + dy * dy);
    double clampedDx = dx;
    double clampedDy = dy;

    if (distance > radius) {
      final scale = radius / distance;
      clampedDx = dx * scale;
      clampedDy = dy * scale;
    }

    // Convert to tilt angles
    // X offset → roll (positive dx = positive roll)
    // Y offset → pitch (positive dy = negative pitch, because Y axis is inverted)
    final roll = (clampedDx / radius) * maxTiltDeg;
    final pitch = -(clampedDy / radius) * maxTiltDeg;

    onManualTiltChanged!(TiltData.now(roll: roll, pitch: pitch));
  }
}

/// Animated tilt dot widget
class _TiltDot extends StatelessWidget {
  final TiltData tiltData;
  final double maxTiltDeg;
  final double radius;
  final Offset centerOffset;

  const _TiltDot({
    required this.tiltData,
    required this.maxTiltDeg,
    required this.radius,
    required this.centerOffset,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate dot position from tilt data
    final x = (tiltData.roll / maxTiltDeg) * radius;
    // Y is inverted: positive pitch = negative Y offset
    final y = -(tiltData.pitch / maxTiltDeg) * radius;

    // Clamp to radius
    final distance = math.sqrt(x * x + y * y);
    double clampedX = x;
    double clampedY = y;

    if (distance > radius) {
      final scale = radius / distance;
      clampedX = x * scale;
      clampedY = y * scale;
    }

    // Get status color
    final magnitude = math.sqrt(tiltData.roll * tiltData.roll + tiltData.pitch * tiltData.pitch);
    final percentage = magnitude / maxTiltDeg;
    final dotColor = _getDotColor(percentage);

    final dotDiameter = DeskConstants.dotRadius * 2;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
      left: centerOffset.dx + clampedX - DeskConstants.dotRadius,
      top: centerOffset.dy + clampedY - DeskConstants.dotRadius,
      child: Container(
        width: dotDiameter,
        height: dotDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dotColor,
          boxShadow: [
            BoxShadow(
              color: dotColor.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
    );
  }

  Color _getDotColor(double percentage) {
    if (percentage < DeskConstants.safeZoneThreshold) {
      return AppTheme.safeColor;
    } else if (percentage < DeskConstants.warningZoneThreshold) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.dangerColor;
    }
  }
}
