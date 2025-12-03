import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../features/settings/settings_provider.dart';
import '../../features/balance/balance_provider.dart';

/// Settings screen for configuring app options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<SettingsProvider>().resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Consumer2<SettingsProvider, BalanceProvider>(
        builder: (context, settingsProvider, balanceProvider, _) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Notification Period
              _SettingsCard(
                title: 'Notification Period',
                subtitle: 'How often tilt data is updated',
                child: Column(
                  children: [
                    Text(
                      '${settingsProvider.notificationPeriodMs} ms',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: NotificationPeriods.options.map((period) {
                        final isSelected =
                            settingsProvider.notificationPeriodMs == period;
                        return ChoiceChip(
                          label: Text('$period ms'),
                          selected: isSelected,
                          onSelected: (_) =>
                              settingsProvider.setNotificationPeriod(period),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Max Tilt Angle
              _SettingsCard(
                title: 'Max Tilt Angle',
                subtitle: 'Maximum tilt angle for full deflection',
                child: Column(
                  children: [
                    Text(
                      '${settingsProvider.maxTiltDeg.toStringAsFixed(0)}°',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Slider(
                      value: settingsProvider.maxTiltDeg,
                      min: TiltAngleRange.min,
                      max: TiltAngleRange.max,
                      divisions: 25,
                      label: '${settingsProvider.maxTiltDeg.toStringAsFixed(0)}°',
                      onChanged: settingsProvider.setMaxTiltDeg,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${TiltAngleRange.min.toInt()}°'),
                        Text('${TiltAngleRange.max.toInt()}°'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Battery Level (Simulation)
              _SettingsCard(
                title: 'Battery Level (Simulation)',
                subtitle: 'Simulated battery level for testing',
                child: Column(
                  children: [
                    Text(
                      '${settingsProvider.batteryLevelPercent}%',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Slider(
                      value: settingsProvider.batteryLevelPercent.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${settingsProvider.batteryLevelPercent}%',
                      onChanged: (value) =>
                          settingsProvider.setBatteryLevelPercent(value.toInt()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('0%'),
                        Text('100%'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Calibration
              _SettingsCard(
                title: 'Calibration',
                subtitle: 'Set current position as zero reference',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.icon(
                      onPressed: balanceProvider.calibrate,
                      icon: const Icon(Icons.adjust),
                      label: const Text('Calibrate'),
                    ),
                    OutlinedButton.icon(
                      onPressed: balanceProvider.clearCalibration,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Toggle Options
              _SettingsCard(
                title: 'Options',
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Auto Reconnect'),
                      subtitle: const Text('Automatically reconnect to last device'),
                      value: settingsProvider.autoReconnect,
                      onChanged: settingsProvider.setAutoReconnect,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Keep Screen On'),
                      subtitle: const Text('Prevent screen from turning off'),
                      value: settingsProvider.keepScreenOn,
                      onChanged: settingsProvider.setKeepScreenOn,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Debug Simulator'),
                      subtitle: const Text('Enable fake tilt data simulator'),
                      value: settingsProvider.debugSimulatorEnabled,
                      onChanged: settingsProvider.setDebugSimulatorEnabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // About button
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/about'),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('About DBBSim'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SettingsCard({
    required this.title,
    this.subtitle,
    required this.child,
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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
