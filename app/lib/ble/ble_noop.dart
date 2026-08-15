// ─────────────────────────────────────────────────────────────────────────────
// ble_noop.dart
// Stub types for flutter_blue_plus — used only on web via conditional import.
// All methods are no-ops; the real BLE code is guarded by kIsWeb checks.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

// Stub Guid
class Guid {
  final String value;
  const Guid(this.value);
}

// Stub connection state enum
enum BluetoothConnectionState { connected, disconnected }

// Stub characteristic
class BluetoothCharacteristic {
  final Guid characteristicUuid;
  BluetoothCharacteristic(this.characteristicUuid);

  Stream<List<int>> get onValueReceived => const Stream.empty();
  Future<void> setNotifyValue(bool notify) async {}
}

// Stub service
class BluetoothService {
  final Guid serviceUuid;
  final List<BluetoothCharacteristic> characteristics;
  BluetoothService(this.serviceUuid, this.characteristics);
}

// Stub scan result
class ScanResult {
  final BluetoothDevice device;
  ScanResult(this.device);
}

// Stub device
class BluetoothDevice {
  final String advName;
  BluetoothDevice(this.advName);

  Stream<BluetoothConnectionState> get connectionState => const Stream.empty();
  Future<void> connect({Duration? timeout}) async {}
  Future<void> disconnect() async {}
  Future<List<BluetoothService>> discoverServices() async => [];
}

// Stub FlutterBluePlus static API
class FlutterBluePlus {
  static Stream<List<ScanResult>> get scanResults => const Stream.empty();

  static Future<void> startScan({
    List<Guid>? withServices,
    Duration? timeout,
  }) async {}

  static Future<void> stopScan() async {}
}
