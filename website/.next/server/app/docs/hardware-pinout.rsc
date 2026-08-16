3:I[9275,[],""]
5:I[1343,[],""]
6:I[5849,["231","static/chunks/231-c27e618569e042bc.js","185","static/chunks/app/layout-b05e199ed9449032.js"],"default"]
4:["slug","hardware-pinout","d"]
0:["Yy_L9UDDwSlDhZJtazhJv",[[["",{"children":["docs",{"children":[["slug","hardware-pinout","d"],{"children":["__PAGE__?{\"slug\":\"hardware-pinout\"}",{}]}]}]},"$undefined","$undefined",true],["",{"children":["docs",{"children":[["slug","hardware-pinout","d"],{"children":["__PAGE__",{},[["$L1","$L2"],null],null]},["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children","docs","children","$4","children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":"$undefined","notFoundStyles":"$undefined","styles":null}],null]},["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children","docs","children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":"$undefined","notFoundStyles":"$undefined","styles":null}],null]},[["$","html",null,{"lang":"en","children":["$","body",null,{"children":[["$","$L6",null,{}],["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":[["$","title",null,{"children":"404: This page could not be found."}],["$","div",null,{"style":{"fontFamily":"system-ui,\"Segoe UI\",Roboto,Helvetica,Arial,sans-serif,\"Apple Color Emoji\",\"Segoe UI Emoji\"","height":"100vh","textAlign":"center","display":"flex","flexDirection":"column","alignItems":"center","justifyContent":"center"},"children":["$","div",null,{"children":[["$","style",null,{"dangerouslySetInnerHTML":{"__html":"body{color:#000;background:#fff;margin:0}.next-error-h1{border-right:1px solid rgba(0,0,0,.3)}@media (prefers-color-scheme:dark){body{color:#fff;background:#000}.next-error-h1{border-right:1px solid rgba(255,255,255,.3)}}"}}],["$","h1",null,{"className":"next-error-h1","style":{"display":"inline-block","margin":"0 20px 0 0","padding":"0 23px 0 0","fontSize":24,"fontWeight":500,"verticalAlign":"top","lineHeight":"49px"},"children":"404"}],["$","div",null,{"style":{"display":"inline-block"},"children":["$","h2",null,{"style":{"fontSize":14,"fontWeight":400,"lineHeight":"49px","margin":0},"children":"This page could not be found."}]}]]}]}]],"notFoundStyles":[],"styles":null}]]}]}],null],null],[[["$","link","0",{"rel":"stylesheet","href":"/_next/static/css/0e235972c0e5e5c7.css","precedence":"next","crossOrigin":"$undefined"}]],[null,"$L7"]]]]]
8:I[231,["231","static/chunks/231-c27e618569e042bc.js","121","static/chunks/app/docs/%5Bslug%5D/page-8e13c7886f515bb3.js"],""]
9:T1938,<h1>RADIAN Hardware Pinout</h1>
<blockquote>
<p><strong>Version:</strong> 1.0<br>
<strong>Sikhay and Valiger Collaboration</strong><br>
<strong>Date:</strong> July 17, 2026</p>
</blockquote>
<hr>
<h2>Board — ESP32-WROOM-32 DevKit V1</h2>
<pre><code>                        ┌─────────────────┐
                 3.3V  ─┤ 3V3         GND ├─  GND
                  GND  ─┤ GND          23 ├─  
                   15  ─┤ D15          22 ├─  SCL  ◄── AS5600 (both encoders)
                    2  ─┤ D2           TX ├─  
                    4  ─┤ D4           RX ├─  
                   16  ─┤ RX2          21 ├─  SDA  ◄── AS5600 (both encoders)
                   17  ─┤ TX2          19 ├─  
                    5  ─┤ D5           18 ├─  
                   18  ─┤ D18           5 ├─  
                   19  ─┤ D19          17 ├─  
                   21  ─┤ D21          16 ├─  
                   RX  ─┤ RX0           4 ├─  
                   TX  ─┤ TX0           0 ├─  
                   22  ─┤ D22           2 ├─  
                   23  ─┤ D23          15 ├─  
                        └─────────────────┘
                               │ USB
</code></pre>
<hr>
<h2>Pin Assignments</h2>
<p>| GPIO | Label | Connected To | Notes |
|---|---|---|---|
| 21 | SDA | AS5600 SDA (both encoders) | I2C data line |
| 22 | SCL | AS5600 SCL (both encoders) | I2C clock line |
| 3.3V | Power | AS5600 VCC, OLED VCC | 3.3V rail — do not use 5V |
| GND | Ground | AS5600 GND, OLED GND, Battery GND | Common ground |
| USB | Power in | TP4056 output | 5V via USB-C charging module |</p>
<hr>
<h2>I2C Devices</h2>
<p>Both AS5600 encoders share the same I2C bus (SDA: GPIO21, SCL: GPIO22). They are differentiated by address:</p>
<p>| Device | I2C Address | Notes |
|---|---|---|
| EncoderA (Arm 1) | <code>0x36</code> | Default AS5600 address |
| EncoderB (Arm 2) | <code>0x37</code> | Requires TCA9548A I2C mux or address bridge resistor |
| OLED Display | <code>0x3C</code> | SSD1306 / SH1106 — standard address |</p>
<blockquote>
<p>⚠️ <strong>Address conflict:</strong> The AS5600 only has one hardware address (<code>0x36</code>). To use two encoders on the same bus, use a <strong>TCA9548A I2C multiplexer</strong> — select channel 0 for EncoderA and channel 1 for EncoderB before each read.</p>
</blockquote>
<hr>
<h2>Power</h2>
<p>| Component | Voltage | Source |
|---|---|---|
| ESP32 | 3.3V (internal regulator) | USB 5V or battery via regulator |
| AS5600 encoder | 3.3V | ESP32 3.3V pin |
| OLED display | 3.3V | ESP32 3.3V pin |
| TP4056 charger | 5V in, 4.2V out | USB-C port |
| 18650 cell | 3.7V nominal | TP4056 output |
| MT3608 boost | 5V out | 18650 cell input |</p>
<hr>
<h2>AS5600 Wiring (Per Encoder)</h2>
<pre><code>AS5600 Pin    →    ESP32 Pin
──────────────────────────────
VCC           →    3.3V
GND           →    GND
SDA           →    GPIO 21
SCL           →    GPIO 22
DIR           →    GND (clockwise positive)
</code></pre>
<blockquote>
<p>The <code>DIR</code> pin sets rotation direction. Tie to GND for clockwise = increasing angle. Tie to 3.3V for counter-clockwise = increasing angle.</p>
</blockquote>
<hr>
<h2>OLED Wiring (SSD1306 / SH1106 — 0.96")</h2>
<pre><code>OLED Pin    →    ESP32 Pin
────────────────────────────
VCC         →    3.3V
GND         →    GND
SDA         →    GPIO 21
SCL         →    GPIO 22
</code></pre>
<hr>
<h2>TCA9548A I2C Multiplexer (for dual encoder)</h2>
<pre><code>TCA9548A Pin    →    Connection
────────────────────────────────────────
VCC             →    3.3V
GND             →    GND
SDA             →    GPIO 21 (ESP32)
SCL             →    GPIO 22 (ESP32)
A0, A1, A2      →    GND (sets mux address to 0x70)
SD0, SC0        →    EncoderA SDA/SCL (channel 0)
SD1, SC1        →    EncoderB SDA/SCL (channel 1)
</code></pre>
<p>To select a channel before reading:</p>
<pre><code class="language-cpp">// Select channel 0 (EncoderA)
Wire.beginTransmission(0x70);
Wire.write(1 &#x3C;&#x3C; 0);
Wire.endTransmission();

// Select channel 1 (EncoderB)
Wire.beginTransmission(0x70);
Wire.write(1 &#x3C;&#x3C; 1);
Wire.endTransmission();
</code></pre>
<hr>
<h2>Power Wiring Diagram</h2>
<pre><code>USB-C port
    │
    ▼
TP4056 module
    │ (charge management + protection)
    ▼
18650 Li-ion cell
    │
    ▼
MT3608 boost converter
    │ (3.7V → 5V regulated)
    ▼
ESP32 VIN pin (5V in)
    │
    └── ESP32 onboard 3.3V regulator
              │
              ├── AS5600 EncoderA VCC
              ├── AS5600 EncoderB VCC (via TCA9548A)
              └── OLED VCC
</code></pre>
<hr>
<h2>config.h Reference</h2>
<p>All pin definitions and I2C addresses are centralized in <code>firmware/include/config.h</code>:</p>
<pre><code class="language-cpp">#define I2C_SDA         21
#define I2C_SCL         22
#define ENCODER_A_ADDR  0x36
#define ENCODER_B_ADDR  0x37
#define RAW_ANGLE_H     0x0C
#define RAW_ANGLE_L     0x0D
</code></pre>
<blockquote>
<p>Never hardcode pin numbers or addresses in <code>.cpp</code> files — always use the <code>config.h</code> constants.</p>
</blockquote>
<hr>
<h2>Hardware Checklist (Before First Flash)</h2>
<ul>
<li>[ ] ESP32 recognized by OS — check Device Manager (Windows) for COM port</li>
<li>[ ] USB driver installed — CP210x or CH340 depending on board variant</li>
<li>[ ] AS5600 encoder wired to GPIO 21 (SDA) and GPIO 22 (SCL)</li>
<li>[ ] 3.3V and GND connected to encoder VCC and GND</li>
<li>[ ] Magnet seated on encoder shaft — AS5600 requires a diametric magnet on the rotating axis</li>
<li>[ ] <code>pio run --target upload</code> completes without error</li>
<li>[ ] Serial monitor at 115200 baud shows <code>[EncoderA] Connected at 0x36</code></li>
</ul>
<hr>
<div align="center">
<p><strong>Sikhay Research, Development and Prototyping and Valiger</strong><br>
<em>Internal — Proprietary and Confidential · © 2026 All rights reserved</em></p>
</div>
2:["$","main",null,{"className":"min-h-screen pt-28 pb-24","children":["$","div",null,{"className":"max-w-3xl mx-auto px-6","children":[["$","$L8",null,{"href":"/docs","className":"inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline mb-10 group","children":[["$","span",null,{"className":"group-hover:-translate-x-0.5 transition-transform duration-200","children":"←"}],"All docs"]}],["$","article",null,{"className":"prose prose-invert prose-obsidian max-w-none","dangerouslySetInnerHTML":{"__html":"$9"}}],["$","div",null,{"className":"mt-16 pt-8 border-t border-[var(--border)]","children":["$","$L8",null,{"href":"/docs","className":"inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline group","children":[["$","span",null,{"className":"group-hover:-translate-x-0.5 transition-transform duration-200","children":"←"}],"Back to documentation"]}]}]]}]}]
7:[["$","meta","0",{"name":"viewport","content":"width=device-width, initial-scale=1"}],["$","meta","1",{"charSet":"utf-8"}],["$","title","2",{"children":"RADIAN Hardware Pinout | RADIAN"}],["$","meta","3",{"name":"description","content":"Version: 1.0 | Sikhay and Valiger Collaboration | Date: July 17, 2026"}],["$","meta","4",{"property":"og:title","content":"RADIAN Hardware Pinout | RADIAN"}],["$","meta","5",{"property":"og:description","content":"Version: 1.0 | Sikhay and Valiger Collaboration | Date: July 17, 2026"}],["$","meta","6",{"property":"og:type","content":"article"}],["$","meta","7",{"name":"twitter:card","content":"summary"}],["$","meta","8",{"name":"twitter:title","content":"RADIAN Hardware Pinout | RADIAN"}],["$","meta","9",{"name":"twitter:description","content":"Version: 1.0 | Sikhay and Valiger Collaboration | Date: July 17, 2026"}]]
1:null
