import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Custom painter for the balance desk visualization
class DeskPainter extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;
  final Color safeZoneColor;
  final Color warningZoneColor;
  final Color dangerZoneColor;
  final Color crosshairColor;
  final Color gridLineColor;
  final double borderWidth;
  final double borderRadius;

  DeskPainter({
    this.borderColor = AppTheme.deskBorderColor,
    this.backgroundColor = AppTheme.deskBackgroundColor,
    this.safeZoneColor = AppTheme.safeColor,
    this.warningZoneColor = AppTheme.warningColor,
    this.dangerZoneColor = AppTheme.dangerColor,
    this.crosshairColor = AppTheme.crosshairColor,
    this.gridLineColor = AppTheme.gridLineColor,
    this.borderWidth = DeskConstants.deskBorderWidth,
    this.borderRadius = DeskConstants.deskBorderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - borderWidth;

    // Draw background
    _drawBackground(canvas, size);

    // Draw danger zone (outermost circle, 50-100% of radius)
    _drawZoneCircle(
      canvas,
      center,
      radius,
      dangerZoneColor.withValues(alpha: 0.2),
    );

    // Draw warning zone (middle circle, 25-50% of radius)
    _drawZoneCircle(
      canvas,
      center,
      radius * DeskConstants.warningZoneThreshold,
      warningZoneColor.withValues(alpha: 0.3),
    );

    // Draw safe zone (innermost circle, 0-25% of radius)
    _drawZoneCircle(
      canvas,
      center,
      radius * DeskConstants.safeZoneThreshold,
      safeZoneColor.withValues(alpha: 0.4),
    );

    // Draw concentric circles (grid)
    _drawConcentricCircles(canvas, center, radius);

    // Draw crosshair lines
    _drawCrosshair(canvas, center, radius);

    // Draw border
    _drawBorder(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rect, paint);
  }

  void _drawZoneCircle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  void _drawConcentricCircles(Canvas canvas, Offset center, double maxRadius) {
    final paint = Paint()
      ..color = gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw circles at 25%, 50%, 75%, and 100% of radius
    for (final fraction in [0.25, 0.50, 0.75, 1.0]) {
      canvas.drawCircle(center, maxRadius * fraction, paint);
    }
  }

  void _drawCrosshair(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = crosshairColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
  }

  void _drawBorder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        borderWidth / 2,
        borderWidth / 2,
        size.width - borderWidth,
        size.height - borderWidth,
      ),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant DeskPainter oldDelegate) {
    return borderColor != oldDelegate.borderColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        safeZoneColor != oldDelegate.safeZoneColor ||
        warningZoneColor != oldDelegate.warningZoneColor ||
        dangerZoneColor != oldDelegate.dangerZoneColor;
  }
}
