// ─────────────────────────────────────────────────────────────────────────────
// packet_provider.dart
// Riverpod providers for the BLE packet stream
// Valiger — RADIAN Companion App
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ble/ble_manager.dart';
import '../ble/radian_packet.dart';

// ── BLEManager singleton provider ────────────────────────────────────────────

/// Provides the singleton [BLEManager] instance to the widget tree.
final bleManagerProvider = Provider<BLEManager>((ref) {
  final manager = BLEManager();
  ref.onDispose(manager.dispose);
  return manager;
});

// ── BLE State stream ──────────────────────────────────────────────────────────

/// Live stream of [BLEState] — reflects connection lifecycle events.
final bleStateProvider = StreamProvider<BLEState>((ref) {
  final manager = ref.watch(bleManagerProvider);
  return manager.stateStream;
});

// ── Packet stream ─────────────────────────────────────────────────────────────

/// Live stream of [RadianPacket] objects decoded from BLE notify.
/// Screens consume this to drive all visualizers.
final packetStreamProvider = StreamProvider<RadianPacket>((ref) {
  final manager = ref.watch(bleManagerProvider);
  return manager.packetStream;
});

// ── Last packet (StateNotifier) ───────────────────────────────────────────────
//
// Holds the most recently received packet so screens can access a synchronous
// value (e.g., during first paint before the stream emits).
// Updated automatically whenever packetStreamProvider emits.

class _LastPacketNotifier extends StateNotifier<RadianPacket> {
  _LastPacketNotifier() : super(RadianPacket.empty);

  void update(RadianPacket packet) => state = packet;
}

final lastPacketProvider =
    StateNotifierProvider<_LastPacketNotifier, RadianPacket>((ref) {
  final notifier = _LastPacketNotifier();
  // Mirror the stream into the notifier
  ref.listen<AsyncValue<RadianPacket>>(
    packetStreamProvider,
    (_, next) => next.whenData(notifier.update),
  );
  return notifier;
});

// ── Mock packet for UI development ───────────────────────────────────────────
//
// Use this when no hardware is connected. Inject via ProviderScope overrides
// in main.dart during development:
//
//   ProviderScope(
//     overrides: [
//       packetStreamProvider.overrideWithValue(
//         const AsyncData(mockPacket),
//       ),
//     ],
//     child: RadianApp(),
//   )

const mockPacket = RadianPacket(
  mode: 1,
  a1:   47.3,
  a2:   0.0,
  val:  RadianVal(
    rad:      0.825,
    rx:       0.682,
    ry:       0.731,
    rmag:     0.0,
    rang:     0.0,
    snap:     6,
    interior: 120.0,
    exterior: 60.0,
  ),
  ts: 0,
);
