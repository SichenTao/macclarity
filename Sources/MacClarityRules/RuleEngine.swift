import Foundation
import MacClarityDomain

public struct RuleEngine {
    public init() {}
    public func evaluate(evidence: [Evidence], disk: DiskNode?, performance: [PerformanceSample]) -> [RuleDiagnosis] {
        var output: [RuleDiagnosis] = []
        if let free = evidence.first(where: { $0.metric == "disk.free" }) {
            if free.value < 10 {
                output.append(.init(id: "low-free-space", title: "可用空间严重不足", summary: "可用空间低于 10 GB，优先检查可恢复的大文件与缓存。", severity: .critical, risk: .low, evidenceIDs: [free.id]))
            } else if free.value < 25 {
                output.append(.init(id: "limited-free-space", title: "可用空间偏低", summary: "建议逐步恢复到 25 GB 以上。", severity: .attention, risk: .low, evidenceIDs: [free.id]))
            }
        }
        if let maxPressure = performance.map(\.memoryPressure).max(), maxPressure > 0.80 {
            let ids = evidence.filter { $0.metric == "memory.pressure" }.map(\.id)
            output.append(.init(id: "memory-pressure", title: "内存压力持续偏高", summary: "高内存压力会触发压缩与交换，常见表现是窗口切换和输入变慢。", severity: .attention, risk: .low, evidenceIDs: ids))
        }
        if let maxSwap = performance.map(\.swapBytes).max(), maxSwap > 4 * 1024 * 1024 * 1024 {
            let ids = evidence.filter { $0.metric == "memory.swap" }.map(\.id)
            output.append(.init(id: "active-swap", title: "交换空间占用较高", summary: "交换空间由 macOS 自动管理；工作期间不建议手动删除或为此重启。", severity: .attention, risk: .high, evidenceIDs: ids))
        }
        if output.isEmpty { output.append(.init(id: "healthy-baseline", title: "当前未发现紧急问题", summary: "可以继续检查目录结构和五分钟性能趋势。", severity: .info, risk: .low, evidenceIDs: evidence.map(\.id))) }
        return output
    }
}
