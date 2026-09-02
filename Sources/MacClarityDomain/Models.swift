import Foundation

public enum EvidenceQuality: String, Codable, Sendable { case measured, estimated, partial, unavailable }
public enum Severity: String, Codable, Sendable { case info, attention, critical }
public enum Risk: String, Codable, Sendable { case low, medium, high }
public enum RunState: String, Codable, Sendable, CaseIterable {
    case idle, preparing, collecting, reduced, paused, completed, cancelled, failed, discarded

    public func canTransition(to next: RunState) -> Bool {
        let allowed: [RunState: Set<RunState>] = [
            .idle: [.preparing], .preparing: [.collecting, .cancelled, .failed],
            .collecting: [.reduced, .paused, .completed, .cancelled, .failed],
            .reduced: [.collecting, .paused, .completed, .cancelled, .failed],
            .paused: [.collecting, .cancelled, .discarded],
            .completed: [.discarded], .cancelled: [.discarded], .failed: [.discarded], .discarded: []
        ]
        return allowed[self, default: []].contains(next)
    }
}

public struct Evidence: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let metric: String
    public let value: Double
    public let unit: String
    public let source: String
    public let quality: EvidenceQuality
    public let timestamp: Date
    public init(id: String, metric: String, value: Double, unit: String, source: String, quality: EvidenceQuality = .measured, timestamp: Date = Date()) {
        self.id = id; self.metric = metric; self.value = value; self.unit = unit; self.source = source; self.quality = quality; self.timestamp = timestamp
    }
}

public struct DiskNode: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let path: String
    public let allocatedBytes: Int64
    public let logicalBytes: Int64
    public let isPartial: Bool
    public let children: [DiskNode]
    public init(id: String, name: String, path: String, allocatedBytes: Int64, logicalBytes: Int64, isPartial: Bool = false, children: [DiskNode] = []) {
        self.id = id; self.name = name; self.path = path; self.allocatedBytes = allocatedBytes; self.logicalBytes = logicalBytes; self.isPartial = isPartial; self.children = children
    }
}

public struct PerformanceSample: Codable, Hashable, Sendable {
    public let timestamp: Date
    public let cpuPercent: Double
    public let memoryPressure: Double
    public let swapBytes: Int64
    public let diskReadBytesPerSecond: Double
    public let diskWriteBytesPerSecond: Double
    public init(timestamp: Date = Date(), cpuPercent: Double, memoryPressure: Double, swapBytes: Int64, diskReadBytesPerSecond: Double = 0, diskWriteBytesPerSecond: Double = 0) {
        self.timestamp = timestamp; self.cpuPercent = cpuPercent; self.memoryPressure = memoryPressure; self.swapBytes = swapBytes; self.diskReadBytesPerSecond = diskReadBytesPerSecond; self.diskWriteBytesPerSecond = diskWriteBytesPerSecond
    }
}

public struct RuleDiagnosis: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let severity: Severity
    public let risk: Risk
    public let evidenceIDs: [String]
    public let expectedBenefitBytes: Int64?
    public init(id: String, title: String, summary: String, severity: Severity, risk: Risk, evidenceIDs: [String], expectedBenefitBytes: Int64? = nil) {
        self.id = id; self.title = title; self.summary = summary; self.severity = severity; self.risk = risk; self.evidenceIDs = evidenceIDs; self.expectedBenefitBytes = expectedBenefitBytes
    }
}

public struct GuidanceNote: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let evidenceIDs: [String]
    public let text: String
    public let uncertainty: String?
    public init(id: String, evidenceIDs: [String], text: String, uncertainty: String? = nil) { self.id = id; self.evidenceIDs = evidenceIDs; self.text = text; self.uncertainty = uncertainty }
}

public struct CleanupTarget: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let canonicalPath: String
    public let allocatedBytes: Int64
    public let fingerprint: String
    public let risk: Risk
}

public struct CleanupManifest: Codable, Hashable, Sendable {
    public let targets: [CleanupTarget]
    public let createdAt: Date
    public init(targets: [CleanupTarget], createdAt: Date = Date()) { self.targets = targets; self.createdAt = createdAt }
}

public struct AuthorizationReceipt: Codable, Hashable, Sendable {
    public let manifestDigest: String
    public let targetIDs: [String]
    public let expiresAt: Date
    public let confirmedAt: Date
}

public struct DiagnosticSnapshot: Codable, Sendable {
    public let schemaVersion: Int
    public let producerVersion: String
    public let runState: RunState
    public let generatedAt: Date
    public let scope: String
    public let disk: DiskNode?
    public let performance: [PerformanceSample]
    public let evidence: [Evidence]
    public let diagnoses: [RuleDiagnosis]
    public let annotations: [GuidanceNote]
    public init(schemaVersion: Int = 1, producerVersion: String = "0.1.0", runState: RunState, generatedAt: Date = Date(), scope: String, disk: DiskNode?, performance: [PerformanceSample], evidence: [Evidence], diagnoses: [RuleDiagnosis], annotations: [GuidanceNote] = []) {
        self.schemaVersion = schemaVersion; self.producerVersion = producerVersion; self.runState = runState; self.generatedAt = generatedAt; self.scope = scope; self.disk = disk; self.performance = performance; self.evidence = evidence; self.diagnoses = diagnoses; self.annotations = annotations
    }
}
