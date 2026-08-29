// ─────────────────────────────────────────────────────────────────────────────
// scan_screen.dart
// BLE device scan and connect screen
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../providers/scan_provider.dart';
import '../ble/ble_manager.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {

  @override
  void initState() {
    super.initState();
    // Auto-scan on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scanNotifierProvider.notifier).startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isScanning  = ref.watch(scanNotifierProvider);
    final bleState    = ref.watch(bleStateProvider);
    final devices     = ref.watch(scanResultsProvider);
    final theme       = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RADIAN'),
        actions: [
          // BLE state badge
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _BleBadge(state: bleState),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──────────────────────────────────────────────────────
            Text(
              'Connect to Device',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure your RADIAN device is powered on and nearby.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // ── Scan button ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isScanning
                    ? () => ref.read(scanNotifierProvider.notifier).stopScan()
                    : () => ref.read(scanNotifierProvider.notifier).startScan(),
                icon: isScanning
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bluetooth_searching),
                label: Text(isScanning ? 'Scanning... Tap to stop' : 'Scan for RADIAN'),
              ),
            ),

            const SizedBox(height: 32),

            // ── Results ──────────────────────────────────────────────────────
            if (devices.isEmpty && !isScanning)
              _EmptyState(bleState: bleState)
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      devices.isEmpty
                          ? 'Searching...'
                          : '${devices.length} device${devices.length == 1 ? '' : 's'} found',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: devices.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return _DeviceTile(
                            device: devices[index],
                            bleState: bleState,
                            onConnect: () => _onConnect(devices[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onConnect(BluetoothDevice device) async {
    await ref.read(scanNotifierProvider.notifier).connect(device);
    if (mounted && BLEManager().isConnected) {
      context.go('/home');
    }
  }
}

// ── Device Tile ───────────────────────────────────────────────────────────────

class _DeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final BLEState        bleState;
  final VoidCallback    onConnect;

  const _DeviceTile({
    required this.device,
    required this.bleState,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final isConnecting = bleState == BLEState.connecting;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Icon(
          Icons.bluetooth,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        device.advName.isNotEmpty ? device.advName : 'RADIAN',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        device.remoteId.str,
        style: theme.textTheme.bodyMedium,
      ),
      trailing: ElevatedButton(
        onPressed: isConnecting ? null : onConnect,
        child: isConnecting
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Connect'),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final BLEState bleState;
  const _EmptyState({required this.bleState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = bleState == BLEState.error;

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isError ? Icons.bluetooth_disabled : Icons.bluetooth_searching,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isError
                  ? 'Bluetooth error\nMake sure Bluetooth is enabled'
                  : 'No devices found\nTap Scan to search again',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ── BLE Badge ─────────────────────────────────────────────────────────────────

class _BleBadge extends StatelessWidget {
  final BLEState state;
  const _BleBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color  color;
    String label;

    switch (state) {
      case BLEState.connected:
        color = Colors.green;
        label = 'Connected';
        break;
      case BLEState.scanning:
        color = theme.colorScheme.primary;
        label = 'Scanning';
        break;
      case BLEState.connecting:
        color = Colors.orange;
        label = 'Connecting';
        break;
      case BLEState.error:
        color = theme.colorScheme.error;
        label = 'Error';
        break;
      default:
        color = theme.colorScheme.outline;
        label = 'Idle';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
