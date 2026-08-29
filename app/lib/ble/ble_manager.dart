// ─────────────────────────────────────────────────────────────────────────────
// ble_manager.dart
// BLE scan, connect, and notify stream manager
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'radian_packet.dart';

// ── BLE UUIDs — must match firmware/include/config.h ─────────────────────────
const String kServiceUUID = '4a2b0001-0000-1000-8000-00805f9b34fb';
const String kCharUUID    = '4a2b0002-0000-1000-8000-00805f9b34fb';
const String kDeviceName  = 'RADIAN';

// ── Connection State ──────────────────────────────────────────────────────────
enum BLEState { idle, scanning, connecting, connected, disconnected, error }

class BLEManager {

  // ── Singleton ──────────────────────────────────────────────────────────────
  static final BLEManager _instance = BLEManager._internal();
  factory BLEManager() => _instance;
  BLEManager._internal();

  // ── State ──────────────────────────────────────────────────────────────────
  BluetoothDevice?        _device;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription?     _notifySubscription;
  StreamSubscription?     _connectionSubscription;

  final _stateController  = StreamController<BLEState>.broadcast();
  final _packetController = StreamController<RadianPacket>.broadcast();

  BLEState _currentState = BLEState.idle;

  // ── Public Streams ─────────────────────────────────────────────────────────

  /// Stream of BLE connection state changes
  Stream<BLEState> get stateStream => _stateController.stream;

  /// Stream of parsed RadianPacket objects from BLE notify
  Stream<RadianPacket> get packetStream => _packetController.stream;

  /// Current connection state
  BLEState get state => _currentState;

  /// True if currently connected to a RADIAN device
  bool get isConnected => _currentState == BLEState.connected;

  // ── Scan ───────────────────────────────────────────────────────────────────

  /// Scan for RADIAN devices — returns list of found devices
  Future<List<BluetoothDevice>> scan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _emit(BLEState.scanning);
    final found = <BluetoothDevice>[];

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(kServiceUUID)],
        timeout: timeout,
      );

      await for (final result in FlutterBluePlus.scanResults) {
        for (final r in result) {
          if (r.device.advName == kDeviceName && !found.contains(r.device)) {
            found.add(r.device);
          }
        }
      }
    } catch (e) {
      _emit(BLEState.error);
      rethrow;
    }

    if (_currentState == BLEState.scanning) {
      _emit(BLEState.idle);
    }

    return found;
  }

  /// Stop an active scan
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    if (_currentState == BLEState.scanning) {
      _emit(BLEState.idle);
    }
  }

  // ── Connect ────────────────────────────────────────────────────────────────

  /// Connect to a RADIAN device and subscribe to notify
  Future<void> connect(BluetoothDevice device) async {
    if (_currentState == BLEState.connected) await disconnect();
    _emit(BLEState.connecting);

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _device = device;

      // Monitor connection state
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDisconnected();
        }
      });

      // Discover services
      final services = await device.discoverServices();
      final service  = services.firstWhere(
        (s) => s.serviceUuid == Guid(kServiceUUID),
        orElse: () => throw Exception('RADIAN service not found'),
      );

      _characteristic = service.characteristics.firstWhere(
        (c) => c.characteristicUuid == Guid(kCharUUID),
        orElse: () => throw Exception('RADIAN characteristic not found'),
      );

      // Subscribe to notify
      await _characteristic!.setNotifyValue(true);
      _notifySubscription = _characteristic!.onValueReceived.listen(_onNotify);

      _emit(BLEState.connected);

    } catch (e) {
      _emit(BLEState.error);
      await disconnect();
      rethrow;
    }
  }

  // ── Disconnect ─────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    await _notifySubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _device?.disconnect();
    _device = null;
    _characteristic = null;
    _emit(BLEState.disconnected);
  }

  // ── Notify Handler ─────────────────────────────────────────────────────────

  void _onNotify(List<int> bytes) {
    try {
      final packet = RadianPacket.fromBytes(bytes);
      _packetController.add(packet);
    } catch (e) {
      // Malformed packet — skip silently, hold previous state
      debugPrint('[BLEManager] Malformed packet: $e');
    }
  }

  void _onDisconnected() {
    _notifySubscription?.cancel();
    _connectionSubscription?.cancel();
    _device = null;
    _characteristic = null;
    _emit(BLEState.disconnected);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _emit(BLEState state) {
    _currentState = state;
    _stateController.add(state);
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
    await _packetController.close();
  }
}