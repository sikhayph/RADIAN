3:I[9275,[],""]
5:I[1343,[],""]
6:I[5849,["231","static/chunks/231-c27e618569e042bc.js","185","static/chunks/app/layout-b05e199ed9449032.js"],"default"]
4:["slug","ui-spec","d"]
0:["TUFBgXgenAyidn9fKBoJz",[[["",{"children":["docs",{"children":[["slug","ui-spec","d"],{"children":["__PAGE__?{\"slug\":\"ui-spec\"}",{}]}]}]},"$undefined","$undefined",true],["",{"children":["docs",{"children":[["slug","ui-spec","d"],{"children":["__PAGE__",{},[["$L1","$L2"],null],null]},["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children","docs","children","$4","children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":"$undefined","notFoundStyles":"$undefined","styles":null}],null]},["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children","docs","children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":"$undefined","notFoundStyles":"$undefined","styles":null}],null]},[["$","html",null,{"lang":"en","children":["$","body",null,{"children":[["$","$L6",null,{}],["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":[["$","title",null,{"children":"404: This page could not be found."}],["$","div",null,{"style":{"fontFamily":"system-ui,\"Segoe UI\",Roboto,Helvetica,Arial,sans-serif,\"Apple Color Emoji\",\"Segoe UI Emoji\"","height":"100vh","textAlign":"center","display":"flex","flexDirection":"column","alignItems":"center","justifyContent":"center"},"children":["$","div",null,{"children":[["$","style",null,{"dangerouslySetInnerHTML":{"__html":"body{color:#000;background:#fff;margin:0}.next-error-h1{border-right:1px solid rgba(0,0,0,.3)}@media (prefers-color-scheme:dark){body{color:#fff;background:#000}.next-error-h1{border-right:1px solid rgba(255,255,255,.3)}}"}}],["$","h1",null,{"className":"next-error-h1","style":{"display":"inline-block","margin":"0 20px 0 0","padding":"0 23px 0 0","fontSize":24,"fontWeight":500,"verticalAlign":"top","lineHeight":"49px"},"children":"404"}],["$","div",null,{"style":{"display":"inline-block"},"children":["$","h2",null,{"style":{"fontSize":14,"fontWeight":400,"lineHeight":"49px","margin":0},"children":"This page could not be found."}]}]]}]}]],"notFoundStyles":[],"styles":null}]]}]}],null],null],[[["$","link","0",{"rel":"stylesheet","href":"/_next/static/css/c2c3cb9791e56c16.css","precedence":"next","crossOrigin":"$undefined"}]],[null,"$L7"]]]]]
8:I[231,["231","static/chunks/231-c27e618569e042bc.js","121","static/chunks/app/docs/%5Bslug%5D/page-8e13c7886f515bb3.js"],""]
9:T321b,<h1>RADIAN UI/UX Specification</h1>
<blockquote>
<p><strong>Version:</strong> 1.0<br>
<strong>Status:</strong> Locked for v1 — changes require both leads<br>
<strong>Sikhay and Valiger Collaboration</strong><br>
<strong>Date:</strong> July 17, 2026</p>
</blockquote>
<hr>
<h2>Table of Contents</h2>
<ol>
<li><a href="#1-layout-system">Layout System</a></li>
<li><a href="#2-color-themes">Color Themes</a></li>
<li><a href="#3-typography">Typography</a></li>
<li><a href="#4-canvas-design--per-mode">Canvas Design — Per Mode</a></li>
<li><a href="#5-component-guidelines">Component Guidelines</a></li>
<li><a href="#6-accessibility">Accessibility</a></li>
</ol>
<hr>
<h2>1. Layout System</h2>
<p>RADIAN uses a <strong>responsive two-panel layout</strong> that adapts to screen width. The physical device is primarily used in a classroom — on a desk in front of a student (portrait phone) or projected on a display during a teacher demonstration (landscape tablet or widescreen).</p>
<h3>Breakpoints</h3>
<p>| Screen Width | Layout | Use Case |
|---|---|---|
| &#x3C; 600px | Single panel, stacked | Phone portrait — student personal use |
| 600–900px | Side-by-side | Phone landscape / small tablet |
| > 900px | Full two-panel with persistent sidebar | Tablet / widescreen / teacher demo |</p>
<h3>Implementation</h3>
<pre><code class="language-dart">LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 900) {
      return WideLayout();     // persistent sidebar + full canvas
    } else if (constraints.maxWidth > 600) {
      return MediumLayout();   // side-by-side, no persistent sidebar
    } else {
      return NarrowLayout();   // stacked, full-width canvas
    }
  },
)
</code></pre>
<h3>Panel Anatomy — Widescreen (> 900px)</h3>
<pre><code>┌─────────────────────────────────────────────────────────┐
│  AppBar — RADIAN · Mode Name · BLE status badge         │
├──────────────────┬──────────────────────────────────────┤
│  LEFT PANEL      │  RIGHT PANEL                         │
│  (fixed 300px)   │  (flexible)                          │
│                  │                                       │
│  BLE badge       │  ┌─────────────────────────────────┐ │
│  ─────────────   │  │                                 │ │
│  Mode selector   │  │        CANVAS                   │ │
│  [1][2][3][4]    │  │                                 │ │
│  ─────────────   │  │   (unit circle / vector /       │ │
│  Arm 1: 47.3°    │  │    matrix / polygon)            │ │
│  Arm 2: 112.8°   │  │                                 │ │
│  rad: 0.825      │  └─────────────────────────────────┘ │
│  ─────────────   │                                       │
│  cos θ: 0.682    │  Degree readout · Radian readout      │
│  sin θ: 0.731    │                                       │
└──────────────────┴──────────────────────────────────────┘
</code></pre>
<h3>Left Panel Contents (Widescreen)</h3>
<ul>
<li>BLE connection status and signal strength</li>
<li>Mode selector — all four modes always visible as tappable tiles</li>
<li>Live angle readout badges — Arm 1, Arm 2, computed value</li>
<li>Polygon N stepper (Mode 4 only, shown contextually)</li>
</ul>
<h3>Right Panel Contents (Widescreen)</h3>
<ul>
<li>Full visualizer canvas — fills available space</li>
<li>Angle value bar below the canvas (degree and radian, large monospace type)</li>
</ul>
<hr>
<h2>2. Color Themes</h2>
<p>Three themes are defined in <code>app/lib/app_theme.dart</code>. Access canvas-specific colors via:</p>
<pre><code class="language-dart">final canvas = Theme.of(context).extension&#x3C;RadianCanvasTheme>()!;
</code></pre>
<h3>Theme 1 — Obsidian (Default Dark)</h3>
<p>| Role | Color | Hex |
|---|---|---|
| Background | Deep navy-black | <code>#0D1117</code> |
| Surface / panels | Dark slate | <code>#161B22</code> |
| Border / divider | Subtle gray | <code>#30363D</code> |
| Primary accent | Electric blue | <code>#58A6FF</code> |
| Secondary accent | Soft teal | <code>#3DCFB8</code> |
| Arm 1 | Vivid orange | <code>#F78166</code> |
| Arm 2 | Lime green | <code>#7EE787</code> |
| Resultant vector | Gold | <code>#E3B341</code> |
| Text primary | Off-white | <code>#E6EDF3</code> |
| Text muted | Cool gray | <code>#8B949E</code> |</p>
<p><strong>When to use:</strong> Default. Best for extended classroom sessions and low-light environments.</p>
<h3>Theme 2 — Chalk (Light / Classroom)</h3>
<p>| Role | Color | Hex |
|---|---|---|
| Background | Warm white | <code>#FAFAFA</code> |
| Surface / panels | Light gray | <code>#F0F2F5</code> |
| Border / divider | Medium gray | <code>#D0D7DE</code> |
| Primary accent | Deep blue | <code>#0969DA</code> |
| Secondary accent | Dark teal | <code>#1A7F64</code> |
| Arm 1 | Red-orange | <code>#CF222E</code> |
| Arm 2 | Forest green | <code>#116329</code> |
| Resultant vector | Dark gold | <code>#9A6700</code> |
| Text primary | Near-black | <code>#1F2328</code> |
| Text muted | Medium gray | <code>#656D76</code> |</p>
<p><strong>When to use:</strong> Projected displays, bright classrooms, printable screenshots.</p>
<h3>Theme 3 — Sikhay (Branded Dark)</h3>
<p>| Role | Color | Hex |
|---|---|---|
| Background | Rich black | <code>#0A0A0A</code> |
| Surface / panels | Dark charcoal | <code>#141414</code> |
| Border / divider | Dark gray | <code>#2A2A2A</code> |
| Arm 1 | Bright white | <code>#FFFFFF</code> |
| Arm 2 | Light gray | <code>#AAAAAA</code> |
| Resultant vector | Off-white | <code>#E0E0E0</code> |
| Text primary | White | <code>#FFFFFF</code> |
| Text muted | Gray | <code>#888888</code> |</p>
<p><strong>When to use:</strong> Product demos, pitch presentations, investor showcases.</p>
<hr>
<h2>3. Typography</h2>
<p>| Role | Font | Size | Weight | Notes |
|---|---|---|---|---|
| Mode name | Inter | 18px | SemiBold | AppBar and mode tile labels |
| Live angle readout | JetBrains Mono | 32px | Bold | Numbers that update rapidly — fixed-width prevents layout jump |
| Canvas labels | Inter | 12px | Regular | Angle tick labels, axis labels |
| Matrix values | JetBrains Mono | 14px | Medium | 2×2 matrix in Mode 3 |
| Body / settings | Inter | 14px | Regular | All prose, settings labels |
| Section headers | Inter | 16px | Medium | Left panel section dividers |</p>
<h3>Font Loading</h3>
<p>Add to <code>pubspec.yaml</code>:</p>
<pre><code class="language-yaml">flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf   weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf weight: 600
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
        - asset: assets/fonts/JetBrainsMono-Medium.ttf  weight: 500
        - asset: assets/fonts/JetBrainsMono-Bold.ttf    weight: 700
</code></pre>
<blockquote>
<p>Download Inter from https://rsms.me/inter and JetBrains Mono from https://www.jetbrains.com/lp/mono — both are open source.</p>
</blockquote>
<hr>
<h2>4. Canvas Design — Per Mode</h2>
<h3>Global Canvas Rules</h3>
<ul>
<li>Canvas fills the right panel on widescreen or the lower 60% on mobile portrait</li>
<li>Origin point always marked with a small filled circle — never implied</li>
<li>All arms rendered as thick rounded lines (<code>strokeWidth: 4.0</code>) with an arrowhead at the tip</li>
<li>Angle arc drawn from 0° to current angle — filled with arm color at 20% opacity</li>
<li>Grid lines at 30° intervals — 10% opacity, never distracting</li>
<li>Labels never overlap the arm — positioned at arc midpoint, offset outward by 16px</li>
<li>All arm movements eased with <code>200ms</code> curve — <code>Curves.easeOut</code></li>
<li>Canvas redraws triggered by BLE notify stream, not a fixed timer</li>
</ul>
<hr>
<h3>Mode 1 — Unit Circle Canvas</h3>
<p><strong>Layout:</strong></p>
<pre><code>         sin θ ↑
                │
   ─────────────O─────────────  cos θ →
               ╱│
         arm  ╱ │
             ╱  │
    (cos θ, sin θ)
</code></pre>
<p><strong>Elements:</strong></p>
<ul>
<li>Full unit circle at radius = 80% of min(width, height) / 2</li>
<li>Cardinal labels outside the ring: <code>0</code>, <code>π/2</code>, <code>π</code>, <code>3π/2</code></li>
<li>Tick marks at 30°, 45°, 60° and their radian equivalents</li>
<li>Arm from origin to (cos θ, sin θ) — color: Arm 1</li>
<li>Dotted projection lines from arm tip to x-axis (cos) and y-axis (sin)</li>
<li>Coordinate labels at projection endpoints — <code>cos θ = 0.682</code>, <code>sin θ = 0.731</code></li>
<li>Bottom bar: <code>47.3°</code> and <code>0.825 rad</code> in large JetBrains Mono type</li>
</ul>
<hr>
<h3>Mode 2 — Vector Addition Canvas</h3>
<p><strong>Elements:</strong></p>
<ul>
<li>Arm 1 from origin — color: Arm 1</li>
<li>Arm 2 from origin — color: Arm 2</li>
<li>Resultant vector drawn tail-to-tip (arm 1 tip → arm 2 tip) — color: Resultant</li>
<li>Dashed component lines projected to x and y axes for each arm</li>
<li>Faint parallelogram outline connecting all four tips</li>
<li>Bottom bar: <code>|R| = 1.41   ∠ = 80.05°</code></li>
</ul>
<hr>
<h3>Mode 3 — Rotation Matrix Canvas</h3>
<p><strong>Elements:</strong></p>
<ul>
<li>2×2 rotation matrix displayed top-left in JetBrains Mono, values updating live:
<pre><code>R(θ) = [ cos θ  -sin θ ]
        [ sin θ   cos θ ]
</code></pre>
</li>
<li>Original arm 2 vector in muted color</li>
<li>Transformed arm 2 vector in bright color</li>
<li>Arc drawn between original and transformed showing rotation angle θ</li>
<li>Optional ghost trail (last 5 positions at decreasing opacity) — toggled in Settings</li>
</ul>
<hr>
<h3>Mode 4 — Polygon / Central Angle Canvas</h3>
<p><strong>Elements:</strong></p>
<ul>
<li>Regular N-gon centered on canvas, inscribed in a faint circle</li>
<li>Current vertex highlighted with filled dot + subtle glow</li>
<li>All interior angles shown as small arcs at each vertex</li>
<li>Central angle arc drawn from center to current vertex</li>
<li>N stepper (+/−) in top-right corner of canvas</li>
<li>Bottom bar three-column layout:
<pre><code>Interior: 120°    Exterior: 60°    Central: 60°
</code></pre>
</li>
<li>Polygon label centered above canvas: <code>Regular Hexagon (N = 6)</code></li>
</ul>
<hr>
<h2>5. Component Guidelines</h2>
<h3>BLE Status Badge</h3>
<ul>
<li>Connected: filled green dot + device name</li>
<li>Scanning: pulsing gray dot + "Scanning..."</li>
<li>Disconnected: empty red dot + "Not connected"</li>
<li>Always visible in AppBar trailing position</li>
</ul>
<h3>Mode Selector Tiles</h3>
<ul>
<li>Four tiles always visible on widescreen left panel</li>
<li>On mobile: bottom navigation bar with four icons</li>
<li>Active mode: filled background using primary color</li>
<li>Inactive: surface color with muted label</li>
</ul>
<h3>Angle Readout Badge</h3>
<ul>
<li>Large JetBrains Mono type — 32px bold</li>
<li>Degree and radian shown simultaneously, separated by a divider</li>
<li>Updates at 20Hz — smooth, no flicker</li>
</ul>
<h3>Settings Screen</h3>
<ul>
<li>Theme selector: three preview tiles (Obsidian / Chalk / Sikhay)</li>
<li>Unit preference toggle: Degrees / Radians</li>
<li>Ghost trail toggle (Mode 3 only)</li>
<li>Device nickname field</li>
<li>Disconnect button</li>
</ul>
<hr>
<h2>6. Accessibility</h2>
<ul>
<li>All color pairs meet WCAG AA contrast ratio (4.5:1 minimum for text)</li>
<li>Arm colors are distinct under deuteranopia — Arm 1 (orange/red) and Arm 2 (blue/green) are distinguishable</li>
<li>Buzzer and haptic feedback serve as non-visual angle confirmation</li>
<li>Canvas labels use minimum 12px — never smaller</li>
<li>Touch targets minimum 48×48dp on all interactive elements</li>
</ul>
<hr>
<div align="center">
<p><strong>Sikhay Research, Development and Prototyping and Valiger</strong><br>
<em>Internal — Proprietary and Confidential · © 2026 All rights reserved</em></p>
</div>
2:["$","main",null,{"className":"min-h-screen pt-28 pb-24","children":["$","div",null,{"className":"max-w-3xl mx-auto px-6","children":[["$","$L8",null,{"href":"/docs","className":"inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline mb-10 group","children":[["$","span",null,{"className":"group-hover:-translate-x-0.5 transition-transform duration-200","children":"←"}],"All docs"]}],["$","article",null,{"className":"prose prose-invert prose-obsidian max-w-none","dangerouslySetInnerHTML":{"__html":"$9"}}],["$","div",null,{"className":"mt-16 pt-8 border-t border-[var(--border)]","children":["$","$L8",null,{"href":"/docs","className":"inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline group","children":[["$","span",null,{"className":"group-hover:-translate-x-0.5 transition-transform duration-200","children":"←"}],"Back to documentation"]}]}]]}]}]
7:[["$","meta","0",{"name":"viewport","content":"width=device-width, initial-scale=1"}],["$","meta","1",{"charSet":"utf-8"}],["$","title","2",{"children":"RADIAN UI/UX Specification | RADIAN"}],["$","meta","3",{"name":"description","content":"Version: 1.0 | Status: Locked for v1 — changes require both leads | Sikhay and Valiger Collaboration"}],["$","meta","4",{"property":"og:title","content":"RADIAN UI/UX Specification | RADIAN"}],["$","meta","5",{"property":"og:description","content":"Version: 1.0 | Status: Locked for v1 — changes require both leads | Sikhay and Valiger Collaboration"}],["$","meta","6",{"property":"og:type","content":"article"}],["$","meta","7",{"name":"twitter:card","content":"summary"}],["$","meta","8",{"name":"twitter:title","content":"RADIAN UI/UX Specification | RADIAN"}],["$","meta","9",{"name":"twitter:description","content":"Version: 1.0 | Status: Locked for v1 — changes require both leads | Sikhay and Valiger Collaboration"}]]
1:null
