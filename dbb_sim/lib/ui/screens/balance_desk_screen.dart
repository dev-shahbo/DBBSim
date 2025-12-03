import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../features/balance/balance_provider.dart';
import '../../features/settings/settings_provider.dart';
import '../widgets/widgets.dart';

/// Main screen showing the balance desk visualization
class BalanceDeskScreen extends StatelessWidget {
  const BalanceDeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('DBBSim', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'Balance Desk',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          // BLE Status indicator
          Consumer<BalanceProvider>(
            builder: (context, balanceProvider, _) {
              return BleStatusIndicator(
                status: balanceProvider.bleService.status,
                batteryLevel: balanceProvider.bleService.isConnected
                    ? balanceProvider.bleService.batteryLevel
                    : null,
                onTap: () => Navigator.pushNamed(context, '/devices'),
              );
            },
          ),
          const SizedBox(width: 8),
          // Settings icon
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<BalanceProvider, SettingsProvider>(
          builder: (context, balanceProvider, settingsProvider, _) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Balance Desk Area
                  Center(
                    child: BalanceDeskWidget(
                      tiltData: balanceProvider.calibratedTilt,
                      maxTiltDeg: settingsProvider.maxTiltDeg,
                      mode: balanceProvider.mode,
                      size: MediaQuery.of(context).size.width * 0.85,
                      onManualTiltChanged: balanceProvider.setManualTilt,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Info Panel
                  AngleInfoPanel(
                    tiltData: balanceProvider.calibratedTilt,
                    maxTiltDeg: settingsProvider.maxTiltDeg,
                  ),
                  // Mode Selector & Controls
                  ModeSelector(
                    mode: balanceProvider.mode,
                    bleConnected: balanceProvider.bleService.isConnected,
                    onModeChanged: balanceProvider.setMode,
                    onResetToCenter: balanceProvider.resetToCenter,
                  ),
                  const SizedBox(height: 16),
                  // Session Controls
                  _SessionControls(balanceProvider: balanceProvider),
                  const SizedBox(height: 16),
                  // Debug simulator toggle
                  if (settingsProvider.debugSimulatorEnabled)
                    _SimulatorControls(balanceProvider: balanceProvider),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            Navigator.pushNamed(context, '/devices');
            break;
          case 2:
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Desk',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bluetooth),
          label: 'Devices',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

class _SessionControls extends StatelessWidget {
  final BalanceProvider balanceProvider;

  const _SessionControls({required this.balanceProvider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!balanceProvider.isSessionActive)
              FilledButton.icon(
                onPressed: balanceProvider.startSession,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Session'),
              )
            else ...[
              FilledButton.tonalIcon(
                onPressed: () {
                  balanceProvider.endSession();
                  Navigator.pushNamed(context, '/session-summary');
                },
                icon: const Icon(Icons.stop),
                label: const Text('End Session'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Session: ${_formatDuration(balanceProvider.sessionMetrics?.duration ?? Duration.zero)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _SimulatorControls extends StatelessWidget {
  final BalanceProvider balanceProvider;

  const _SimulatorControls({required this.balanceProvider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.amber.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Debug Simulator',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.amber,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!balanceProvider.isSimulatorRunning)
                  FilledButton.tonalIcon(
                    onPressed: balanceProvider.startSimulator,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Simulator'),
                  )
                else
                  FilledButton.tonalIcon(
                    onPressed: balanceProvider.stopSimulator,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Simulator'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
