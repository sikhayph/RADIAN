// ─────────────────────────────────────────────────────────────────────────────
// scan_provider.dart
// Riverpod providers for BLE scan state
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../ble/ble_manager.dart';

// ── Scan Results ──────────────────────────────────────────────────────────────

/// List of RADIAN devices found during scan
final scanResultsProvider = StateProvider<List<BluetoothDevice>>(
  (ref) => [],
);

// ── BLE State ─────────────────────────────────────────────────────────────────

/// Current BLE connection/scan state
final bleStateProvider = StateProvider<BLEState>(
  (ref) => BLEState.idle,
);

// ── Scan Notifier ─────────────────────────────────────────────────────────────

class ScanNotifier extends StateNotifier<bool> {
  final Ref _ref;

  ScanNotifier(this._ref) : super(false);

  /// Start scanning for RADIAN devices
  Future<void> startScan() async {
    if (state) return; // already scanning
    state = true;

    _ref.read(bleStateProvider.notifier).state = BLEState.scanning;
    _ref.read(scanResultsProvider.notifier).state = [];

    try {
      final devices = await BLEManager().scan(
        timeout: const Duration(seconds: 10),
      );
      _ref.read(scanResultsProvider.notifier).state = devices;
      _ref.read(bleStateProvider.notifier).state = BLEState.idle;
    } catch (e) {
      _ref.read(bleStateProvider.notifier).state = BLEState.error;
    } finally {
      state = false;
    }
  }

  /// Stop an active scan
  Future<void> stopScan() async {
    await BLEManager().stopScan();
    _ref.read(bleStateProvider.notifier).state = BLEState.idle;
    state = false;
  }

  /// Connect to a selected device
  Future<void> connect(BluetoothDevice device) async {
    _ref.read(bleStateProvider.notifier).state = BLEState.connecting;
    try {
      await BLEManager().connect(device);
      _ref.read(bleStateProvider.notifier).state = BLEState.connected;
    } catch (e) {
      _ref.read(bleStateProvider.notifier).state = BLEState.error;
    }
  }
}

final scanNotifierProvider =
    StateNotifierProvider<ScanNotifier, bool>(
  (ref) => ScanNotifier(ref),
);
