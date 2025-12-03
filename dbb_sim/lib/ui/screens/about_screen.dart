import 'package:flutter/material.dart';

/// About screen with app information and help
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About DBBSim'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Logo/Title
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.dashboard,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'DBBSim',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Balance Desk Simulator',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Description
          _SectionCard(
            title: 'Description',
            child: const Text(
              'DBBSim is a Flutter application that visualizes and simulates '
              '2D tilt/position on a square "desk" and communicates that data '
              'over Bluetooth Low Energy (BLE).\n\n'
              'It provides a visual representation of balance data, showing the '
              'center of mass position relative to safe, warning, and danger zones.',
            ),
          ),
          const SizedBox(height: 16),
          // How to Use
          _SectionCard(
            title: 'How to Use',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InstructionItem(
                  number: '1',
                  text: 'Connect to a BLE balance device from the Devices screen',
                ),
                _InstructionItem(
                  number: '2',
                  text: 'Switch to "Live BLE" mode to receive real tilt data',
                ),
                _InstructionItem(
                  number: '3',
                  text: 'Use "Manual" mode to simulate tilt by dragging the dot',
                ),
                _InstructionItem(
                  number: '4',
                  text: 'Start a session to track your balance metrics',
                ),
                _InstructionItem(
                  number: '5',
                  text: 'View session summary to analyze performance',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Modes
          _SectionCard(
            title: 'Modes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ModeItem(
                  icon: Icons.bluetooth,
                  title: 'Live BLE',
                  description:
                      'Receives real-time tilt data from a connected BLE device.',
                ),
                const SizedBox(height: 12),
                _ModeItem(
                  icon: Icons.touch_app,
                  title: 'Manual Simulation',
                  description:
                      'Drag the dot to simulate tilt for testing or demonstration.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Zones
          _SectionCard(
            title: 'Balance Zones',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ZoneItem(
                  color: Colors.green,
                  title: 'Safe Zone (0-25%)',
                  description: 'Stable position with minimal tilt',
                ),
                const SizedBox(height: 8),
                _ZoneItem(
                  color: Colors.yellow.shade700,
                  title: 'Warning Zone (25-50%)',
                  description: 'Slight tilt detected',
                ),
                const SizedBox(height: 8),
                _ZoneItem(
                  color: Colors.red,
                  title: 'Danger Zone (>50%)',
                  description: 'High tilt - balance at risk',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Credits
          Center(
            child: Text(
              '© 2024 DBBSim',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
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
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionItem({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

class _ModeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ModeItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZoneItem extends StatelessWidget {
  final Color color;
  final String title;
  final String description;

  const _ZoneItem({
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
