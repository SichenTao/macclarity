import SwiftUI
import MacClarityDomain

@main struct MacClarityApp: App { var body: some Scene { WindowGroup { HomeView() }.windowResizability(.contentSize) } }

struct HomeView: View {
    @State private var selected = "空间诊断"
    let choices = [("externaldrive.fill", "空间诊断", "找出真正占用本地空间的目录"), ("waveform.path.ecg", "性能诊断", "记录五分钟 CPU、内存与 Swap 趋势"), ("checkmark.shield", "综合体检", "把空间和卡顿放进同一条证据链")]
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("MacClarity").font(.system(size: 36, weight: .bold, design: .rounded))
            Text("看见什么占用你的 Mac，理解原因，再安全处理。").foregroundStyle(.secondary)
            HStack(spacing: 14) { ForEach(choices, id: \.1) { choice in Button { selected = choice.1 } label: { VStack(alignment: .leading, spacing: 12) { Image(systemName: choice.0).font(.title); Text(choice.1).font(.headline); Text(choice.2).font(.caption).multilineTextAlignment(.leading).foregroundStyle(.secondary) }.frame(width: 180, height: 120, alignment: .topLeading).padding().background(selected == choice.1 ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.07), in: RoundedRectangle(cornerRadius: 18)) }.buttonStyle(.plain) } }
            HStack { Label("本地分析", systemImage: "lock"); Label("默认只读", systemImage: "eye"); Spacer(); Button("开始\(selected)") {}.buttonStyle(.borderedProminent) }.font(.callout)
        }.padding(32).frame(width: 720)
    }
}
