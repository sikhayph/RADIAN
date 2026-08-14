// ─────────────────────────────────────────────────────────────────────────────
// packet_provider.dart
// Riverpod providers for the BLE packet stream
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ble/ble_manager.dart';
import '../ble/radian_packet.dart';

// ── Packet stream ─────────────────────────────────────────────────────────────

/// Live stream of [RadianPacket] objects decoded from BLE notify.
/// Screens consume this to drive all visualizers.
final packetStreamProvider = StreamProvider<RadianPacket>((ref) {
  return BLEManager().packetStream;
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
