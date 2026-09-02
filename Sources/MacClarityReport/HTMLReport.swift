import Foundation
import MacClarityDomain

public struct HTMLReport {
    public init() {}
    public func render(_ snapshot: DiagnosticSnapshot, locale: String = "zh") throws -> String {
        let data = try JSONEncoder.macclarity.encode(snapshot)
        let json = String(decoding: data, as: UTF8.self).replacingOccurrences(of: "</", with: "<\\/")
        let title = locale == "ja" ? "MacClarity 診断" : locale == "en" ? "MacClarity Diagnostics" : "MacClarity 诊断"
        return """
        <!doctype html><html lang="\(locale)"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>\(title)</title><style>
        :root{color-scheme:light dark;--bg:#f7f8fa;--card:#fff;--ink:#15202b;--muted:#667085;--line:#d8dee8;--blue:#3478d4;--green:#36c88a;--orange:#e49b2f;--purple:#8c45d8}
        @media(prefers-color-scheme:dark){:root{--bg:#11151b;--card:#191f27;--ink:#f4f7fb;--muted:#a8b2c2;--line:#303846}}
        *{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.55 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}main{max-width:1100px;margin:auto;padding:28px}.hero{display:flex;justify-content:space-between;gap:16px;align-items:end}.tag{color:var(--blue);font-weight:700}.grid{display:grid;grid-template-columns:minmax(340px,1fr) minmax(300px,.9fr);gap:20px}.card{background:var(--card);border:1px solid var(--line);border-radius:18px;padding:20px;margin:18px 0;box-shadow:0 8px 28px #0000000b}h1,h2{letter-spacing:-.025em}h2{font-size:20px}.metrics{display:flex;gap:22px;flex-wrap:wrap}.metric b{display:block;font-size:24px}.muted{color:var(--muted)}#rose{width:100%;aspect-ratio:1;max-height:560px}.wedge{stroke:var(--card);stroke-width:2;cursor:pointer;transition:opacity .15s,transform .15s;transform-origin:center}.wedge:hover,.wedge:focus{opacity:.72;outline:none}.tooltip{position:fixed;pointer-events:none;max-width:330px;padding:12px 14px;border:1px solid #ffffff80;background:color-mix(in srgb,var(--card) 50%,transparent);backdrop-filter:blur(16px);border-radius:14px;box-shadow:0 10px 34px #0003;opacity:0;transition:opacity .1s}.diagnosis{border-left:4px solid var(--orange);padding:2px 0 2px 14px;margin:14px 0}.path{font:12px ui-monospace,SFMono-Regular,monospace;color:var(--muted);overflow-wrap:anywhere}.bars{display:flex;height:100px;align-items:end;gap:3px}.bar{flex:1;background:linear-gradient(var(--purple),var(--blue));border-radius:4px 4px 0 0;min-height:2px}.legend li{margin:9px 0}.dot{display:inline-block;width:10px;height:10px;border-radius:50%;margin-right:8px}@media(max-width:760px){main{padding:18px}.grid{grid-template-columns:1fr}.hero{display:block}}
        </style></head><body><main>
        <div class="hero"><div><div class="tag">LOCAL-FIRST · READ-ONLY</div><h1>\(title)</h1><p class="muted">先理解占用与卡顿，再决定是否处理。</p></div><div class="muted">\(snapshot.generatedAt.formatted())</div></div>
        <section class="card"><h2>建议处理顺序</h2><div id="diagnoses"></div></section>
        <div class="grid"><section class="card"><h2>磁盘花盘</h2><svg id="rose" viewBox="0 0 600 600" role="img" aria-label="目录空间层级图"></svg></section><section class="card"><h2>空间结构</h2><ul id="legend" class="legend"></ul></section></div>
        <section class="card"><h2>性能趋势</h2><div class="metrics" id="metrics"></div><div class="bars" id="bars"></div><p class="muted">CPU 为系统负载的保守近似；五分钟会话能提供更可靠的趋势判断。</p></section>
        <section class="card"><h2>证据边界</h2><p>测量事实、规则判断、个性化建议和用户授权分别保存。此报告不会授予删除权限。</p><p class="path">范围：\(escape(snapshot.scope))</p></section>
        </main><div class="tooltip" id="tip"></div><script>const DATA=\(json);</script><script>
        const colors=['#3478d4','#38c98a','#d49335','#8c45d8','#8da2b8','#a68d85','#e05a67'];const fmt=b=>b>=1073741824?(b/1073741824).toFixed(2)+' GiB':b>=1048576?(b/1048576).toFixed(1)+' MiB':b+' B';
        const diagnoses=document.querySelector('#diagnoses');DATA.diagnoses.forEach((d,i)=>diagnoses.insertAdjacentHTML('beforeend',`<div class="diagnosis"><b>${i+1}. ${d.title}</b><div>${d.summary}</div><small class="muted">风险：${d.risk} · 严重性：${d.severity}</small></div>`));
        const svg=document.querySelector('#rose'),tip=document.querySelector('#tip'),legend=document.querySelector('#legend');function polar(r,a){return[300+r*Math.cos(a),300+r*Math.sin(a)]}function arc(r0,r1,a0,a1){const p0=polar(r1,a0),p1=polar(r1,a1),p2=polar(r0,a1),p3=polar(r0,a0),big=a1-a0>Math.PI?1:0;return`M${p0}A${r1},${r1} 0 ${big} 1 ${p1}L${p2}A${r0},${r0} 0 ${big} 0 ${p3}Z`}function draw(node,a0,a1,depth,color,path){if(depth>4)return;const r0=72+depth*58,r1=r0+54;if(depth>0){const p=document.createElementNS('http://www.w3.org/2000/svg','path');p.setAttribute('d',arc(r0,r1,a0,a1));p.setAttribute('fill',color);p.setAttribute('class','wedge');p.setAttribute('tabindex','0');p.setAttribute('aria-label',`${node.name}, ${fmt(node.allocatedBytes)}`);const show=e=>{tip.innerHTML=`<b>${node.name}</b><br>${fmt(node.allocatedBytes)}<br><span class="muted">${path}</span>`;tip.style.left=Math.min(innerWidth-350,e.clientX+14)+'px';tip.style.top=Math.min(innerHeight-130,e.clientY+14)+'px';tip.style.opacity=1};p.onmousemove=show;p.onfocus=e=>show({clientX:innerWidth/2,clientY:innerHeight/2});p.onmouseleave=p.onblur=()=>tip.style.opacity=0;svg.appendChild(p)}const total=Math.max(1,node.children.reduce((s,c)=>s+c.allocatedBytes,0));let cursor=a0;node.children.forEach((c,i)=>{const end=cursor+(a1-a0)*c.allocatedBytes/total;draw(c,cursor,end,depth+1,depth?color:colors[i%colors.length],path+'/'+c.name);cursor=end})}if(DATA.disk){draw(DATA.disk,-Math.PI/2,Math.PI*1.5,0,colors[0],DATA.disk.name);DATA.disk.children.slice(0,9).forEach((n,i)=>legend.insertAdjacentHTML('beforeend',`<li><span class="dot" style="background:${colors[i%colors.length]}"></span>${n.name}<b style="float:right">${fmt(n.allocatedBytes)}</b></li>`))}else svg.insertAdjacentHTML('beforeend','<text x="300" y="300" text-anchor="middle" fill="currentColor">No storage scan</text>');
        const samples=DATA.performance,max=Math.max(1,...samples.map(s=>s.cpuPercent));samples.forEach(s=>document.querySelector('#bars').insertAdjacentHTML('beforeend',`<i class="bar" style="height:${Math.max(2,s.cpuPercent/max*100)}%" title="CPU ${s.cpuPercent.toFixed(1)}%"></i>`));if(samples.length){const last=samples.at(-1);document.querySelector('#metrics').innerHTML=`<div class="metric"><b>${last.cpuPercent.toFixed(1)}%</b>CPU 近似负载</div><div class="metric"><b>${(last.memoryPressure*100).toFixed(0)}%</b>内存占用压力</div><div class="metric"><b>${fmt(last.swapBytes)}</b>Swap</div>`}else document.querySelector('#metrics').textContent='本次未采集性能趋势。';
        </script></body></html>
        """
    }
    private func escape(_ value: String) -> String { value.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;") }
}

public extension JSONEncoder {
    static var macclarity: JSONEncoder { let e = JSONEncoder(); e.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]; e.dateEncodingStrategy = .iso8601; return e }
}
public extension JSONDecoder {
    static var macclarity: JSONDecoder { let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601; return d }
}
