import Foundation
import Darwin
import MacClarityDomain

public actor PerformanceCollector {
    public init() {}
    public func sample() -> PerformanceSample {
        var vm = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let host = mach_host_self()
        let result = withUnsafeMutablePointer(to: &vm) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { host_statistics64(host, HOST_VM_INFO64, $0, &count) }
        }
        let page = Int64(getpagesize())
        let active = Int64(vm.active_count + vm.wire_count + vm.compressor_page_count) * page
        let total = ProcessInfo.processInfo.physicalMemory
        let pressure = result == KERN_SUCCESS && total > 0 ? min(1, Double(active) / Double(total)) : 0
        var swap = xsw_usage()
        var size = MemoryLayout<xsw_usage>.size
        sysctlbyname("vm.swapusage", &swap, &size, nil, 0)
        var load = [Double](repeating: 0, count: 3)
        getloadavg(&load, 3)
        let cores = max(1, ProcessInfo.processInfo.activeProcessorCount)
        let cpu = min(100, load[0] / Double(cores) * 100)
        return PerformanceSample(cpuPercent: cpu, memoryPressure: pressure, swapBytes: Int64(swap.xsu_used))
    }

    public func session(duration: TimeInterval, interval: TimeInterval = 2) async throws -> [PerformanceSample] {
        var result: [PerformanceSample] = []
        let end = Date().addingTimeInterval(duration)
        while Date() < end {
            try Task.checkCancellation(); result.append(sample())
            try await Task.sleep(for: .seconds(interval))
        }
        return result
    }
}
