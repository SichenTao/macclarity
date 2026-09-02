import XCTest
import Foundation
@testable import MacClarityDomain
@testable import MacClarityCollectors
@testable import MacClarityRules
@testable import MacClarityReport

final class MacClarityTests: XCTestCase {
    func testRunStateTransitions() { XCTAssertTrue(RunState.idle.canTransition(to: .preparing)); XCTAssertFalse(RunState.completed.canTransition(to: .collecting)) }
    func testStableRedaction() {
        let r = Redactor(); let source = "/Users/private/秘密/file.txt"
        XCTAssertEqual(r.path(source, profile: .shareRedacted), r.path(source, profile: .shareRedacted)); XCTAssertFalse(r.path(source, profile: .shareRedacted).contains("private"))
    }
    func testFixtureRoundTripAndReport() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let data = try Data(contentsOf: root.appendingPathComponent("Fixtures/synthetic-stressed-mac-v1.json"))
        let snapshot = try JSONDecoder.macclarity.decode(DiagnosticSnapshot.self, from: data)
        XCTAssertEqual(snapshot.schemaVersion, 1); XCTAssertTrue(try HTMLReport().render(snapshot).contains("磁盘花盘"))
    }
    func testRuleLowSpace() {
        let e = Evidence(id: "free", metric: "disk.free", value: 3, unit: "GB", source: "test")
        XCTAssertEqual(RuleEngine().evaluate(evidence: [e], disk: nil, performance: []).first?.severity, .critical)
    }
    func testBoundedScanner() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try Data("x".utf8).write(to: root.appendingPathComponent("example.txt"))
        let node = try await StorageScanner().scan(path: root.path, budget: .init(maxNodes: 10, maxDuration: 2, maxDepth: 2))
        XCTAssertEqual(node.children.count, 1)
    }
    func testReceiptRejectsDriftAndBroadRoots() throws {
        let validator = ManifestValidator()
        let forbidden = CleanupManifest(targets: [.init(id: "root", canonicalPath: "/", allocatedBytes: 1, fingerprint: "x", risk: .high)])
        XCTAssertThrowsError(try validator.validate(forbidden))
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("safe".utf8).write(to: root); defer { try? FileManager.default.removeItem(at: root) }
        let target = CleanupTarget(id: "one", canonicalPath: root.path, allocatedBytes: 4, fingerprint: validator.fingerprint(root), risk: .low)
        let manifest = CleanupManifest(targets: [target]); let receipt = try validator.receipt(for: manifest)
        try Data("changed".utf8).write(to: root)
        XCTAssertThrowsError(try validator.validate(receipt, for: manifest))
    }
}
