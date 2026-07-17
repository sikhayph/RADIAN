// ─────────────────────────────────────────────────────────────────────────────
// radian_packet.dart
// BLE payload model — mirrors docs/ble_contract.md v1.0
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────
//
// CRITICAL: This file is part of the BLE contract.
// Any change requires approval from both firmware lead (Sikhay)
// and app lead (Valiger). See docs/ble_contract.md for the change process.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

class RadianPacket {
  /// Active teaching mode (1–4)
  final int mode;

  /// Arm 1 angle in degrees (0.0–359.9)
  final double a1;

  /// Arm 2 angle in degrees (0.0 if single-arm mode)
  final double a2;

  /// Mode-specific computed values
  final RadianVal val;

  /// ESP32 millis() at time of reading
  final int ts;

  const RadianPacket({
    required this.mode,
    required this.a1,
    required this.a2,
    required this.val,
    required this.ts,
  });

  // ── Deserialization ────────────────────────────────────────────────────────

  factory RadianPacket.fromJson(Map<String, dynamic> json) {
    return RadianPacket(
      mode: json['mode'] as int,
      a1:   (json['a1'] as num).toDouble(),
      a2:   (json['a2'] as num).toDouble(),
      val:  RadianVal.fromJson(json['val'] as Map<String, dynamic>),
      ts:   json['ts'] as int,
    );
  }

  factory RadianPacket.fromBytes(List<int> bytes) {
    final jsonString = utf8.decode(bytes);
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return RadianPacket.fromJson(map);
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'mode': mode,
    'a1':   a1,
    'a2':   a2,
    'val':  val.toJson(),
    'ts':   ts,
  };

  // ── Convenience getters ───────────────────────────────────────────────────

  /// True if Arm 2 encoder is active
  bool get isDualArm => a2 != 0.0;

  /// Human-readable mode name
  String get modeName {
    switch (mode) {
      case 1: return 'Degree / Radian';
      case 2: return 'Vector Addition';
      case 3: return 'Rotation Matrix';
      case 4: return 'Polygon Snap';
      default: return 'Unknown';
    }
  }

  // ── Empty / fallback packet ───────────────────────────────────────────────

  static const empty = RadianPacket(
    mode: 1,
    a1:   0.0,
    a2:   0.0,
    val:  RadianVal.empty,
    ts:   0,
  );

  // ── Equality ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      other is RadianPacket &&
      other.mode == mode &&
      other.a1 == a1 &&
      other.a2 == a2 &&
      other.ts == ts;

  @override
  int get hashCode => Object.hash(mode, a1, a2, ts);

  @override
  String toString() =>
      'RadianPacket(mode: $mode, a1: $a1°, a2: $a2°, ts: $ts)';
}

// ─────────────────────────────────────────────────────────────────────────────

class RadianVal {
  /// Mode 1: radian equivalent of a1
  final double rad;

  /// Mode 1 / Mode 3: cos(a1) or transformed x component
  final double rx;

  /// Mode 1 / Mode 3: sin(a1) or transformed y component
  final double ry;

  /// Mode 2: resultant vector magnitude
  final double rmag;

  /// Mode 2: resultant vector angle in degrees
  final double rang;

  /// Mode 4: selected polygon N (number of sides)
  final int snap;

  /// Mode 4: interior angle of N-gon in degrees
  final double interior;

  /// Mode 4: exterior angle of N-gon in degrees
  final double exterior;

  const RadianVal({
    required this.rad,
    required this.rx,
    required this.ry,
    required this.rmag,
    required this.rang,
    required this.snap,
    required this.interior,
    required this.exterior,
  });

  factory RadianVal.fromJson(Map<String, dynamic> json) {
    return RadianVal(
      rad:      (json['rad']  as num?)?.toDouble() ?? 0.0,
      rx:       (json['rx']   as num?)?.toDouble() ?? 0.0,
      ry:       (json['ry']   as num?)?.toDouble() ?? 0.0,
      rmag:     (json['rmag'] as num?)?.toDouble() ?? 0.0,
      rang:     (json['rang'] as num?)?.toDouble() ?? 0.0,
      snap:     (json['snap'] as int?)             ?? 6,
      interior: (json['int']  as num?)?.toDouble() ?? 0.0,
      exterior: (json['ext']  as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'rad':  rad,
    'rx':   rx,
    'ry':   ry,
    'rmag': rmag,
    'rang': rang,
    'snap': snap,
    'int':  interior,
    'ext':  exterior,
  };

  static const empty = RadianVal(
    rad: 0.0, rx: 1.0, ry: 0.0,
    rmag: 0.0, rang: 0.0,
    snap: 6, interior: 120.0, exterior: 60.0,
  );

  @override
  String toString() =>
      'RadianVal(rad: $rad, rx: $rx, ry: $ry, rmag: $rmag, snap: $snap)';
}