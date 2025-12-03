import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/constants/app_constants.dart';
import '../../features/balance/balance_provider.dart';

/// Session summary screen showing metrics from the last session
class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Summary'),
      ),
      body: Consumer<BalanceProvider>(
        builder: (context, balanceProvider, _) {
          final metrics = balanceProvider.sessionMetrics;

          if (metrics == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No session data available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Desk'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Session Info Card
              _InfoCard(
                title: 'Session Info',
                children: [
                  _InfoRow(
                    label: 'Date',
                    value: _formatDate(metrics.startTime),
                  ),
                  _InfoRow(
                    label: 'Duration',
                    value: _formatDuration(metrics.duration),
                  ),
                  _InfoRow(
                    label: 'Samples',
                    value: '${metrics.sampleCount}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Key Metrics Card
              _InfoCard(
                title: 'Key Metrics',
                children: [
                  _InfoRow(
                    label: 'Max Tilt',
                    value: '${metrics.maxTiltMagnitude.toStringAsFixed(1)}°',
                    valueColor: _getTiltColor(
                      metrics.maxTiltMagnitude /
                          context.read<BalanceProvider>().settings.maxTiltDeg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Zone Time Card
              _InfoCard(
                title: 'Time in Zones',
                children: [
                  _ZoneBar(
                    label: 'Safe Zone',
                    duration: metrics.timeInSafeZone,
                    percentage: metrics.safeZonePercentage,
                    color: AppTheme.safeColor,
                  ),
                  const SizedBox(height: 12),
                  _ZoneBar(
                    label: 'Warning Zone',
                    duration: metrics.timeInWarningZone,
                    percentage: metrics.warningZonePercentage,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(height: 12),
                  _ZoneBar(
                    label: 'Danger Zone',
                    duration: metrics.timeInDangerZone,
                    percentage: metrics.dangerZonePercentage,
                    color: AppTheme.dangerColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      balanceProvider.startSession();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('New Session'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes min $seconds sec';
  }

  Color _getTiltColor(double percentage) {
    if (percentage < DeskConstants.safeZoneThreshold) {
      return AppTheme.safeColor;
    } else if (percentage < DeskConstants.warningZoneThreshold) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.dangerColor;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _ZoneBar extends StatelessWidget {
  final String label;
  final Duration duration;
  final double percentage;
  final Color color;

  const _ZoneBar({
    required this.label,
    required this.duration,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}% (${_formatDuration(duration)})',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = duration.inMinutes;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }
}
