import Foundation
import CryptoKit

public enum ExportProfile: String, Codable, Sendable { case localFull, shareRedacted }

public struct Redactor {
    public init() {}
    public func path(_ path: String, profile: ExportProfile) -> String {
        guard profile == .shareRedacted else { return path }
        let digest = SHA256.hash(data: Data(path.utf8)).prefix(6).map { String(format: "%02x", $0) }.joined()
        return "/Users/person/Item-\(digest)"
    }

    public func snapshot(_ value: DiagnosticSnapshot, profile: ExportProfile) -> DiagnosticSnapshot {
        guard profile == .shareRedacted else { return value }
        func node(_ input: DiskNode) -> DiskNode {
            DiskNode(id: input.id, name: "Item-\(input.id.prefix(8))", path: path(input.path, profile: profile), allocatedBytes: input.allocatedBytes, logicalBytes: input.logicalBytes, isPartial: input.isPartial, children: input.children.map(node))
        }
        return DiagnosticSnapshot(schemaVersion: value.schemaVersion, producerVersion: value.producerVersion, runState: value.runState, generatedAt: value.generatedAt, scope: "redacted-scope", disk: value.disk.map(node), performance: value.performance, evidence: value.evidence, diagnoses: value.diagnoses, annotations: value.annotations)
    }
}
