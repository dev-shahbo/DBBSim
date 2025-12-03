import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../features/ble/ble_service.dart';

/// Screen for scanning and connecting to BLE devices
class BleDevicesScreen extends StatefulWidget {
  const BleDevicesScreen({super.key});

  @override
  State<BleDevicesScreen> createState() => _BleDevicesScreenState();
}

class _BleDevicesScreenState extends State<BleDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Devices'),
        actions: [
          Consumer<BleService>(
            builder: (context, bleService, _) {
              if (bleService.isScanning) {
                return TextButton.icon(
                  onPressed: bleService.stopScan,
                  icon: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  label: const Text('Stop'),
                );
              }
              return TextButton.icon(
                onPressed: bleService.startScan,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan'),
              );
            },
          ),
        ],
      ),
      body: Consumer<BleService>(
        builder: (context, bleService, _) {
          return Column(
            children: [
              // Connection status card
              _ConnectionStatusCard(bleService: bleService),
              // Error message if any
              if (bleService.lastError != null)
                _ErrorCard(
                  error: bleService.lastError!,
                  onDismiss: bleService.clearError,
                ),
              // Device list
              Expanded(
                child: _DeviceList(bleService: bleService),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  final BleService bleService;

  const _ConnectionStatusCard({required this.bleService});

  @override
  Widget build(BuildContext context) {
    final status = bleService.status;
    final isConnected = status == BleStatus.connected;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(status),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${status.displayName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (isConnected && bleService.connectedDevice != null) ...[
              const SizedBox(height: 8),
              Text(
                'Device: ${bleService.connectedDevice!.platformName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Battery: ${bleService.batteryLevel}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: bleService.disconnect,
                icon: const Icon(Icons.bluetooth_disabled),
                label: const Text('Disconnect'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BleStatus status) {
    switch (status) {
      case BleStatus.disconnected:
        return Colors.grey;
      case BleStatus.advertising:
        return Colors.blue;
      case BleStatus.connecting:
        return Colors.orange;
      case BleStatus.connected:
        return Colors.green;
    }
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ErrorCard({
    required this.error,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  final BleService bleService;

  const _DeviceList({required this.bleService});

  @override
  Widget build(BuildContext context) {
    final devices = bleService.discoveredDevices;

    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              bleService.isScanning
                  ? Icons.bluetooth_searching
                  : Icons.bluetooth_disabled,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              bleService.isScanning
                  ? 'Scanning for devices...'
                  : 'No devices found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            if (!bleService.isScanning) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: bleService.startScan,
                icon: const Icon(Icons.refresh),
                label: const Text('Start Scan'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _DeviceListItem(
          device: device,
          onConnect: () => _connectToDevice(context, device),
        );
      },
    );
  }

  Future<void> _connectToDevice(BuildContext context, BleDeviceInfo device) async {
    final success = await bleService.connect(device);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.name}')),
      );
    }
  }
}

class _DeviceListItem extends StatelessWidget {
  final BleDeviceInfo device;
  final VoidCallback onConnect;

  const _DeviceListItem({
    required this.device,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bluetooth),
        title: Text(device.name),
        subtitle: Text(
          'ID: ${device.id}\nRSSI: ${device.rssi} dBm',
        ),
        isThreeLine: true,
        trailing: FilledButton(
          onPressed: onConnect,
          child: const Text('Connect'),
        ),
      ),
    );
  }
}
