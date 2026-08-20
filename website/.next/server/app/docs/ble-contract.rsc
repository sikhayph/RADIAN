3:I[9275,[],""]
5:I[1343,[],""]
6:I[5849,["231","static/chunks/231-c27e618569e042bc.js","185","static/chunks/app/layout-b05e199ed9449032.js"],"default"]
4:["slug","ble-contract","d"]
0:["ajbg28fLywErTqloGrB5C",[[["",{"children":["docs",{"children":[["slug","ble-contract","d"],{"children":["__PAGE__?{\"slug\":\"ble-contract\"}",{}]}]}]},"$undefined","$undefined",true],["",{"children":["docs",{"children":[["slug","ble-contract","d"],{"children":["__PAGE__",{},[["$L1","$L2"],null],null]},["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children","docs","children","$4","children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":"$undefined","notFoundStyles":"$undefined","styles":null}],null]},["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children","docs","children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":"$undefined","notFoundStyles":"$undefined","styles":null}],null]},[["$","html",null,{"lang":"en","children":["$","body",null,{"children":[["$","$L6",null,{}],["$","$L3",null,{"parallelRouterKey":"children","segmentPath":["children"],"error":"$undefined","errorStyles":"$undefined","errorScripts":"$undefined","template":["$","$L5",null,{}],"templateStyles":"$undefined","templateScripts":"$undefined","notFound":[["$","title",null,{"children":"404: This page could not be found."}],["$","div",null,{"style":{"fontFamily":"system-ui,\"Segoe UI\",Roboto,Helvetica,Arial,sans-serif,\"Apple Color Emoji\",\"Segoe UI Emoji\"","height":"100vh","textAlign":"center","display":"flex","flexDirection":"column","alignItems":"center","justifyContent":"center"},"children":["$","div",null,{"children":[["$","style",null,{"dangerouslySetInnerHTML":{"__html":"body{color:#000;background:#fff;margin:0}.next-error-h1{border-right:1px solid rgba(0,0,0,.3)}@media (prefers-color-scheme:dark){body{color:#fff;background:#000}.next-error-h1{border-right:1px solid rgba(255,255,255,.3)}}"}}],["$","h1",null,{"className":"next-error-h1","style":{"display":"inline-block","margin":"0 20px 0 0","padding":"0 23px 0 0","fontSize":24,"fontWeight":500,"verticalAlign":"top","lineHeight":"49px"},"children":"404"}],["$","div",null,{"style":{"display":"inline-block"},"children":["$","h2",null,{"style":{"fontSize":14,"fontWeight":400,"lineHeight":"49px","margin":0},"children":"This page could not be found."}]}]]}]}]],"notFoundStyles":[],"styles":null}]]}]}],null],null],[[["$","link","0",{"rel":"stylesheet","href":"/_next/static/css/0e235972c0e5e5c7.css","precedence":"next","crossOrigin":"$undefined"}]],[null,"$L7"]]]]]
8:I[231,["231","static/chunks/231-c27e618569e042bc.js","121","static/chunks/app/docs/%5Bslug%5D/page-8e13c7886f515bb3.js"],""]
9:Tb1f,<h1>BLE Contract — RADIAN</h1>
<p><strong>Version:</strong> 1.0 | <strong>Status:</strong> Locked for v1 — changes require dual approval
<strong>Authors:</strong> Henry Gabriel Buban (Sikhay) × Valiger Lead
<strong>Date:</strong> July 13, 2026</p>
<hr>
<h2>Service</h2>
<p>| Property        | Value                               |
|-----------------|-------------------------------------|
| Service UUID    | <code>4A2B-RADIAN-0001</code> (custom 128-bit) |
| Characteristic  | <code>ANGLE_DATA</code>                        |
| Properties      | Notify, Read                        |
| Notify interval | ~50 ms (20 Hz)                      |
| Encoding        | JSON string, UTF-8, ≤ 100 bytes     |</p>
<hr>
<h2>Payload</h2>
<pre><code class="language-json">{
  "mode": 1,
  "a1":   47.3,
  "a2":   112.8,
  "val": {
    "rad":  0.825,
    "rx":   0.682,
    "ry":   0.731,
    "rmag": 1.41,
    "rang": 80.05,
    "snap": 6,
    "int":  120.0,
    "ext":  60.0
  },
  "ts": 1720863600
}
</code></pre>
<hr>
<h2>Field Definitions</h2>
<p>| Field     | Type  | Description                              |
|-----------|-------|------------------------------------------|
| mode      | int   | Active mode (1–4)                        |
| a1        | float | Arm 1 angle, degrees, 0–359.9           |
| a2        | float | Arm 2 angle; 0.0 if single-arm mode     |
| val.rad   | float | Mode 1: radian equivalent of a1         |
| val.rx    | float | Mode 1/3: cos(a1)                       |
| val.ry    | float | Mode 1/3: sin(a1)                       |
| val.rmag  | float | Mode 2: resultant vector magnitude      |
| val.rang  | float | Mode 2: resultant angle, degrees        |
| val.snap  | int   | Mode 4: selected polygon N              |
| val.int   | float | Mode 4: interior angle of N-gon         |
| val.ext   | float | Mode 4: exterior angle of N-gon         |
| ts        | long  | ESP32 millis() at time of reading        |</p>
<hr>
<h2>Change Process</h2>
<ol>
<li>Open a GitHub issue tagged <code>ble-contract</code>.</li>
<li>Both firmware lead and app lead comment approval.</li>
<li>PR updates this file AND <code>app/lib/ble/radian_packet.dart</code> in the same commit.</li>
<li>No merge without both approvals.</li>
</ol>
<hr>
<h2>Sign-Off</h2>
<blockquote>
<p>This contract is locked once both leads sign off below.
To sign off — open a PR from <code>docs/ble-contract</code> → <code>dev</code> and approve it.</p>
</blockquote>
<p>| Role          | Name                         | GitHub Handle       | Sign-off |
|---------------|------------------------------|---------------------|----------|
| Firmware Lead | Henry Gabriel Buban (Sikhay) | @sikhayprs-gif      | ⬜        |
| App Lead      | (Valiger lead)               | @valiger            | ⬜        |</p>
2:["$","main",null,{"className":"min-h-screen pt-28 pb-24","children":["$","div",null,{"className":"max-w-3xl mx-auto px-6","children":[["$","$L8",null,{"href":"/docs","className":"inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline mb-10 group","children":[["$","span",null,{"className":"group-hover:-translate-x-0.5 transition-transform duration-200","children":"←"}],"All docs"]}],["$","article",null,{"className":"prose prose-invert prose-obsidian max-w-none","dangerouslySetInnerHTML":{"__html":"$9"}}],["$","div",null,{"className":"mt-16 pt-8 border-t border-[var(--border)]","children":["$","$L8",null,{"href":"/docs","className":"inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline group","children":[["$","span",null,{"className":"group-hover:-translate-x-0.5 transition-transform duration-200","children":"←"}],"Back to documentation"]}]}]]}]}]
7:[["$","meta","0",{"name":"viewport","content":"width=device-width, initial-scale=1"}],["$","meta","1",{"charSet":"utf-8"}],["$","title","2",{"children":"BLE Contract — RADIAN | RADIAN"}],["$","meta","3",{"name":"description","content":"Version: 1.0 | Status: Locked for v1 — changes require dual approval | Authors: Henry Gabriel Buban (Sikhay) × Valiger Lead | Date: July 13, 2026"}],["$","meta","4",{"property":"og:title","content":"BLE Contract — RADIAN | RADIAN"}],["$","meta","5",{"property":"og:description","content":"Version: 1.0 | Status: Locked for v1 — changes require dual approval | Authors: Henry Gabriel Buban (Sikhay) × Valiger Lead | Date: July 13, 2026"}],["$","meta","6",{"property":"og:type","content":"article"}],["$","meta","7",{"name":"twitter:card","content":"summary_large_image"}],["$","meta","8",{"name":"twitter:title","content":"RADIAN — Rotary Angular Display with Intuitive Angle Notation"}],["$","meta","9",{"name":"twitter:description","content":"An ESP32-powered educational device that teaches abstract mathematics through physical rotation. A Sikhay and Valiger collaboration."}]]
1:null
