import Foundation
import MacClarityDomain

public struct ScanBudget: Sendable {
    public var maxNodes: Int
    public var maxDuration: TimeInterval
    public var maxDepth: Int
    public init(maxNodes: Int = 50_000, maxDuration: TimeInterval = 30, maxDepth: Int = 5) { self.maxNodes = maxNodes; self.maxDuration = maxDuration; self.maxDepth = maxDepth }
}

public actor StorageScanner {
    private var cancelled = false
    public init() {}
    public func cancel() { cancelled = true }

    public func scan(path: String, budget: ScanBudget = .init()) async throws -> DiskNode {
        cancelled = false
        let root = URL(fileURLWithPath: path).standardizedFileURL
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .isSymbolicLinkKey, .fileAllocatedSizeKey, .fileSizeKey, .nameKey, .fileResourceIdentifierKey, .volumeIdentifierKey]
        let rootValues = try root.resourceValues(forKeys: keys)
        let rootVolume = rootValues.volumeIdentifier.map(String.init(describing:))
        var queue: [(URL, Int, String?)] = [(root, 0, nil)]
        var records: [String: (name: String, path: String, allocated: Int64, logical: Int64, partial: Bool, children: [String])] = [:]
        var visited = Set<String>()
        var nodes = 0
        let started = Date()

        while !queue.isEmpty {
            if cancelled { throw CancellationError() }
            let (url, depth, parent) = queue.removeFirst()
            if nodes >= budget.maxNodes || Date().timeIntervalSince(started) >= budget.maxDuration { if let parent { records[parent]?.partial = true }; break }
            let values = try? url.resourceValues(forKeys: keys)
            if values?.isSymbolicLink == true { continue }
            if let rootVolume, values?.volumeIdentifier.map(String.init(describing:)) != rootVolume { continue }
            let identity = values?.fileResourceIdentifier.map(String.init(describing:)) ?? url.path
            if visited.contains(identity) { continue }
            visited.insert(identity); nodes += 1
            let key = url.path
            let allocated = Int64(values?.fileAllocatedSize ?? values?.fileSize ?? 0)
            records[key] = (values?.name ?? url.lastPathComponent, key, allocated, Int64(values?.fileSize ?? 0), false, [])
            if let parent { records[parent]?.children.append(key) }
            guard values?.isDirectory == true else { continue }
            if depth >= budget.maxDepth { records[key]?.partial = true; continue }
            guard let children = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: Array(keys), options: [.skipsHiddenFiles]) else { records[key]?.partial = true; continue }
            for child in children.sorted(by: { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }) { queue.append((child, depth + 1, key)) }
            if nodes % 128 == 0 { await Task.yield() }
        }

        func build(_ key: String) -> DiskNode {
            let record = records[key]!
            let children = record.children.compactMap { records[$0] == nil ? nil : build($0) }
            let allocated = max(record.allocated, children.reduce(0) { $0 + $1.allocatedBytes })
            let logical = max(record.logical, children.reduce(0) { $0 + $1.logicalBytes })
            return DiskNode(id: stableID(key), name: record.name, path: record.path, allocatedBytes: allocated, logicalBytes: logical, isPartial: record.partial, children: children.sorted { $0.allocatedBytes > $1.allocatedBytes })
        }
        return build(root.path)
    }
}

private func stableID(_ value: String) -> String {
    var hash: UInt64 = 1469598103934665603
    for byte in value.utf8 { hash = (hash ^ UInt64(byte)) &* 1099511628211 }
    return String(hash, radix: 16)
}
