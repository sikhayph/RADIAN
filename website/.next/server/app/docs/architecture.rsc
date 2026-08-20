3:I[9275,[],""]
5:I[1343,[],""]
6:I[5849,["231","static/chunks/231-c27e618569e042bc.js","185","static/chunks/app/layout-b05e199ed9449032.js"],"default"]
4:["slug","architecture","d"]
0:["ajbg28fLywErTqloGrB5C",[[["",{"children":["docs",{"children":[["slug","architecture","d"],{"children":["__PAGE__?{\"slug\":\"architecture\"}",{}]}]}]},"$undefined","$undefined",true],["",{"children":["docs",{"children":[["slug","architecture","d"],{"children":["__PAGE__",{},[["$L1","$L2"],null],null]},["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children","docs","children","$4","children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":"$undefined","notFoundStyles":"$undefined","styles":null}],null]},["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children","docs","children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":"$undefined","notFoundStyles":"$undefined","styles":null}],null]},[["$","html",null,{"lang":"en","children":["$","body",null,{"children":[["$","$L6",null,{}],["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":[["$","title",null,{"children":"404: This page could not be found."}],["$","div",null,{"style":{"fontFamily":"system-ui,\"Segoe UI\",Roboto,Helvetica,Arial,sans-serif,\"Apple Color Emoji\",\"Segoe UI Emoji\"","height":"100vh","textAlign":"center","display":"flex","flexDirection":"column","alignItems":"center","justifyContent":"center"},"children":["$","div",null,{"children":[["$","style",null,{"dangerouslySetInnerHTML":{"__html":"body{color:#000;background:#fff;margin:0}.next-error-h1{border-right:1px solid rgba(0,0,0,.3)}@media (prefers-color-scheme:dark){body{color:#fff;background:#000}.next-error-h1{border-right:1px solid rgba(255,255,255,.3)}}"}}],["$","h1",null,{"className":"next-error-h1","style":{"display":"inline-block","margin":"0 20px 0 0","padding":"0 23px 0 0","fontSize":24,"fontWeight":500,"verticalAlign":"top","lineHeight":"49px"},"children":"404"}],["$","div",null,{"style":{"display":"inline-block"},"children":["$","h2",null,{"style":{"fontSize":14,"fontWeight":400,"lineHeight":"49px","margin":0},"children":"This page could not be found."}]}]]}]}]],"notFoundStyles":[],"styles":null}]]}]}],null],null],[[["$","link","0",{"rel":"stylesheet","href":"/_next/static/css/0e235972c0e5e5c7.css","precedence":"next","crossOrigin":"$undefined"}]],[null,"$L7"]]]]]
8:I[231,["231","static/chunks/231-c27e618569e042bc.js","121","static/chunks/app/docs/%5Bslug%5D/page-8e13c7886f515bb3.js"],""]
9:T2957,<h1>RADIAN System Architecture</h1>
<blockquote>
<p><strong>Version:</strong> 1.0<br>
<strong>Sikhay and Valiger Collaboration</strong><br>
<strong>Date:</strong> July 17, 2026</p>
</blockquote>
<hr>
<h2>Table of Contents</h2>
<ol>
<li><a href="#1-system-overview">System Overview</a></li>
<li><a href="#2-firmware-architecture">Firmware Architecture</a></li>
<li><a href="#3-ble-communication-layer">BLE Communication Layer</a></li>
<li><a href="#4-app-architecture">App Architecture</a></li>
<li><a href="#5-data-flow--end-to-end">Data Flow — End to End</a></li>
<li><a href="#6-error-handling">Error Handling</a></li>
</ol>
<hr>
<h2>1. System Overview</h2>
<p>RADIAN is a two-component system: an ESP32-based hardware device and a Flutter mobile companion application. They communicate exclusively over Bluetooth Low Energy (BLE). Neither component depends on the internet, a backend server, or cloud storage — the entire system operates offline, peer-to-peer between the device and the phone.</p>
<pre><code>┌─────────────────────────┐         BLE (GATT)        ┌──────────────────────────┐
│     RADIAN Device       │ ────── notify/read ──────► │   Companion App          │
│     (ESP32-WROOM-32)    │                             │   (Flutter / Android)    │
│                         │                             │                          │
│  AS5600 encoder ──►     │                             │  ble_manager.dart        │
│  ModeManager    ──►     │                             │  radian_packet.dart      │
│  BLEService     ──►     │  JSON payload @ 20Hz        │  Riverpod providers      │
│  OLED display           │                             │  CustomPainter canvas    │
└─────────────────────────┘                             └──────────────────────────┘
</code></pre>
<hr>
<h2>2. Firmware Architecture</h2>
<h3>Layer Model</h3>
<pre><code>┌─────────────────────────────────────┐
│           main.cpp                  │  ← Entry point, 20Hz loop
├─────────────────────────────────────┤
│           ModeManager               │  ← Active mode, payload builder
├────────────┬────────────────────────┤
│ Mode1      │ Mode2   │ Mode3 │ Mode4 │  ← Compute layer (pure math)
├────────────┴────────────────────────┤
│           BLEService                │  ← Radio layer (NimBLE, JSON)
├─────────────────────────────────────┤
│      EncoderA      │   EncoderB     │  ← Sensor layer (I2C, AS5600)
└─────────────────────────────────────┘
</code></pre>
<h3>Loop Execution — 50ms (20Hz)</h3>
<pre><code>loop()
  │
  ├── EncoderA.readAngle()        → float a1 (0.0–359.9°)
  ├── EncoderB.readAngle()        → float a2 (0.0–359.9°, or 0.0 if not connected)
  ├── ModeManager.compute(a1, a2) → ComputedPayload
  └── BLEService.notify(payload)  → JSON string over BLE notify
</code></pre>
<h3>Mode Compute Layer</h3>
<p>Each mode is a stateless class with a single <code>compute()</code> method. No mode holds state — all state lives in <code>ModeManager</code>.</p>
<p>| Class | Input | Output |
|---|---|---|
| <code>Mode1_DegRad</code> | <code>float degrees</code> | radians, cos, sin |
| <code>Mode2_VectorAdd</code> | <code>float a1, a2</code> | resultant magnitude, angle, components |
| <code>Mode3_RotMatrix</code> | <code>float theta, a2</code> | rotation matrix, transformed vector |
| <code>Mode4_PolygonSnap</code> | <code>float degrees, int n</code> | snapped angle, interior, exterior, central |</p>
<h3>ModeManager</h3>
<p>Owns the active mode integer and polygon N. On each tick, routes <code>a1</code> and <code>a2</code> to the correct mode class and packages the result into a <code>ComputedPayload</code> struct that <code>BLEService</code> serializes.</p>
<hr>
<h2>3. BLE Communication Layer</h2>
<h3>Protocol</h3>
<pre><code>Device role:  GATT Server (Peripheral)
App role:     GATT Client (Central)

Service UUID:    4a2b0001-0000-1000-8000-00805f9b34fb
Characteristic:  4a2b0002-0000-1000-8000-00805f9b34fb
Properties:      Notify + Read
Notify interval: 50ms (20Hz)
Payload:         JSON string, UTF-8, ≤ 100 bytes
</code></pre>
<h3>Connection Lifecycle</h3>
<pre><code>Device powers on
  │
  └── BLEService.begin()
        ├── NimBLEDevice::init("RADIAN")
        ├── Create GATT service + characteristic
        └── Start advertising

App opens
  │
  └── BLEManager.startScan()
        ├── Filter by service UUID 4a2b0001...
        ├── Display found devices
        └── User taps connect

Connection established
  │
  ├── Device: onConnect() → _connected = true
  ├── App: onConnected() → subscribe to notify
  └── Data flows at 20Hz until disconnect

Disconnect
  │
  ├── Device: onDisconnect() → restart advertising
  └── App: onDisconnected() → show reconnect UI
</code></pre>
<h3>Payload Structure</h3>
<p>See <code>docs/ble_contract.md</code> for the full field reference. Summary:</p>
<pre><code class="language-json">{
  "mode": 1,
  "a1": 47.3,
  "a2": 0.0,
  "val": { "rad": 0.825, "rx": 0.682, "ry": 0.731 },
  "ts": 1720863600
}
</code></pre>
<hr>
<h2>4. App Architecture</h2>
<h3>Layer Model</h3>
<pre><code>┌─────────────────────────────────────┐
│         Screens (UI layer)          │  ← go_router, screen widgets
├─────────────────────────────────────┤
│      Painters (Canvas layer)        │  ← CustomPainter per mode
├─────────────────────────────────────┤
│      Providers (State layer)        │  ← Riverpod, derived state
├─────────────────────────────────────┤
│      RadianPacket (Model layer)     │  ← Typed BLE payload model
├─────────────────────────────────────┤
│      BLEManager (Data layer)        │  ← flutter_blue_plus, raw stream
└─────────────────────────────────────┘
</code></pre>
<h3>State Flow</h3>
<pre><code>BLEManager
  │  raw BLE notify bytes
  ▼
radian_packet.dart (RadianPacket.fromJson)
  │  typed RadianPacket object
  ▼
Riverpod StreamProvider&#x3C;RadianPacket>
  │  reactive state
  ▼
Screen widgets (ref.watch)
  │  rebuild on change
  ▼
CustomPainter (canvas.drawX)
  │  visual output
  ▼
User sees live visualization
</code></pre>
<h3>Routing — go_router</h3>
<pre><code>/                   → ScanScreen
/connect/:deviceId  → ConnectingScreen
/home               → HomeScreen (mode selector + live readout)
/mode/1             → Mode1Screen (unit circle)
/mode/2             → Mode2Screen (vector addition)
/mode/3             → Mode3Screen (rotation matrix)
/mode/4             → Mode4Screen (polygon snap)
/settings           → SettingsScreen
</code></pre>
<h3>Key Files</h3>
<p>| File | Role |
|---|---|
| <code>lib/main.dart</code> | App entry, MaterialApp, router, theme provider |
| <code>lib/app_theme.dart</code> | Three ThemeData objects + RadianCanvasTheme extension |
| <code>lib/ble/ble_manager.dart</code> | BLE scan, connect, notify stream |
| <code>lib/ble/radian_packet.dart</code> | JSON → typed Dart model |
| <code>lib/providers/</code> | Riverpod providers for packet stream, theme, mode |
| <code>lib/screens/</code> | One file per route |
| <code>lib/widgets/painters/</code> | One CustomPainter per mode |</p>
<hr>
<h2>5. Data Flow — End to End</h2>
<pre><code>Physical rotation of arm
        │
        ▼
AS5600 encoder reads raw 12-bit value (0–4095)
        │
        ▼  (raw / 4096.0) × 360.0
float angle in degrees (0.0–359.9)
        │
        ▼
ModeManager.compute(a1, a2)
        │
        ▼
ComputedPayload struct populated
        │
        ▼
ArduinoJson serializes to JSON string (≤ 100 bytes)
        │
        ▼
NimBLE notify characteristic → BLE radio
        │
        ▼  (over-the-air, ~50ms)
flutter_blue_plus onValueReceived stream
        │
        ▼
RadianPacket.fromJson(jsonString)
        │
        ▼
Riverpod StreamProvider emits new packet
        │
        ▼
Screen widget rebuilds (ref.watch)
        │
        ▼
CustomPainter.paint() called with new data
        │
        ▼
Canvas redraws — student sees live visualization
</code></pre>
<p><strong>Total latency:</strong> encoder read → canvas redraw is approximately 50–80ms under normal BLE conditions. This feels instantaneous to a student.</p>
<hr>
<h2>6. Error Handling</h2>
<p>| Scenario | Firmware Behavior | App Behavior |
|---|---|---|
| Encoder not connected | Returns 0.0°, logs to serial | Shows 0.0° — no crash |
| EncoderB not found | Returns 0.0° for a2 | Single-arm mode, a2 fields ignored |
| BLE client disconnects | Restarts advertising automatically | Shows reconnect UI, retries |
| JSON payload > 100 bytes | Will not occur by design | Packet dropped, previous state held |
| Mode out of range (not 1–4) | Clamped by ModeManager | Ignored, previous mode held |
| Polygon N out of range | Clamped to 3–12 by clampN() | N stepper bounded in UI |</p>
<hr>
<div align="center">
<p><strong>Sikhay Research, Development and Prototyping and Valiger</strong><br>
<em>Internal — Proprietary and Confidential · © 2026 All rights reserved</em></p>
</div>
2:["$","main",null,{"className":"min-h-screen pt-28 pb-24","children":["$","div",null,{"className":"max-w-3xl mx-auto px-6","children":[["$","$L8",null,{"href":"/docs","className":"inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline mb-10 group","children":[["$","span",null,{"className":"group-hover:-translate-x-0.5 transition-transform duration-200","children":"←"}],"All docs"]}],["$","article",null,{"className":"prose prose-invert prose-obsidian max-w-none","dangerouslySetInnerHTML":{"__html":"$9"}}],["$","div",null,{"className":"mt-16 pt-8 border-t border-[var(--border)]","children":["$","$L8",null,{"href":"/docs","className":"inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline group","children":[["$","span",null,{"className":"group-hover:-translate-x-0.5 transition-transform duration-200","children":"←"}],"Back to documentation"]}]}]]}]}]
7:[["$","meta","0",{"name":"viewport","content":"width=device-width, initial-scale=1"}],["$","meta","1",{"charSet":"utf-8"}],["$","title","2",{"children":"RADIAN System Architecture | RADIAN"}],["$","meta","3",{"name":"description","content":"Version: 1.0 | Sikhay and Valiger Collaboration | Date: July 17, 2026"}],["$","meta","4",{"property":"og:title","content":"RADIAN System Architecture | RADIAN"}],["$","meta","5",{"property":"og:description","content":"Version: 1.0 | Sikhay and Valiger Collaboration | Date: July 17, 2026"}],["$","meta","6",{"property":"og:type","content":"article"}],["$","meta","7",{"name":"twitter:card","content":"summary_large_image"}],["$","meta","8",{"name":"twitter:title","content":"RADIAN — Rotary Angular Display with Intuitive Angle Notation"}],["$","meta","9",{"name":"twitter:description","content":"An ESP32-powered educational device that teaches abstract mathematics through physical rotation. A Sikhay and Valiger collaboration."}]]
1:null
