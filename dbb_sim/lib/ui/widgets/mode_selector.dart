import 'package:flutter/material.dart';
import '../../core/models/models.dart';

/// Mode selector widget for toggling between BLE and Manual modes
class ModeSelector extends StatelessWidget {
  final BalanceMode mode;
  final void Function(BalanceMode) onModeChanged;
  final VoidCallback onResetToCenter;
  final bool bleConnected;

  const ModeSelector({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onResetToCenter,
    this.bleConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode toggle
            SegmentedButton<BalanceMode>(
              segments: const [
                ButtonSegment<BalanceMode>(
                  value: BalanceMode.ble,
                  label: Text('Live BLE'),
                  icon: Icon(Icons.bluetooth),
                ),
                ButtonSegment<BalanceMode>(
                  value: BalanceMode.manual,
                  label: Text('Manual'),
                  icon: Icon(Icons.touch_app),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (Set<BalanceMode> newSelection) {
                if (newSelection.isNotEmpty) {
                  final selectedMode = newSelection.first;
                  // Show warning if trying to switch to BLE without connection
                  if (selectedMode == BalanceMode.ble && !bleConnected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connect to a BLE device first'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  onModeChanged(selectedMode);
                }
              },
            ),
            const SizedBox(height: 12),
            // Reset button
            FilledButton.tonalIcon(
              onPressed: onResetToCenter,
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Reset to Center'),
            ),
          ],
        ),
      ),
    );
  }
}
