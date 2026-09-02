import Foundation
import MacClarityDomain
import MacClarityCollectors
import MacClarityRules
import MacClarityReport

@main struct MacClarityCLI {
    static func main() async {
        do {
            let args = Array(CommandLine.arguments.dropFirst())
            if args.contains("--version") { print("macclarity 0.1.0"); return }
            if args.first == "demo" { try writeDemo(output: value(after: "--output", in: args) ?? "report.html"); return }
            if args.first == "diagnose" { try await diagnose(args); return }
            print("""
            MacClarity — local-first Mac diagnostics
              macclarity diagnose [--path PATH] [--duration SECONDS] [--output FILE] [--share-redacted]
              macclarity demo [--output FILE]
              macclarity --version
            """)
        } catch { fputs("MacClarity: \(error)\n", stderr); exit(1) }
    }

    static func diagnose(_ args: [String]) async throws {
        let path = value(after: "--path", in: args) ?? FileManager.default.homeDirectoryForCurrentUser.path
        let duration = Double(value(after: "--duration", in: args) ?? "10") ?? 10
        let output = value(after: "--output", in: args) ?? "macclarity-report.html"
        let disk = try await StorageScanner().scan(path: path)
        let samples = try await PerformanceCollector().session(duration: duration)
        let free = try URL(fileURLWithPath: path).resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage ?? 0
        var evidence = [Evidence(id: "disk-free", metric: "disk.free", value: Double(free) / 1_000_000_000, unit: "GB", source: "volume")]
        for (i, sample) in samples.enumerated() {
            evidence.append(.init(id: "pressure-\(i)", metric: "memory.pressure", value: sample.memoryPressure, unit: "ratio", source: "host_statistics"))
            evidence.append(.init(id: "swap-\(i)", metric: "memory.swap", value: Double(sample.swapBytes), unit: "bytes", source: "sysctl"))
        }
        let diagnoses = RuleEngine().evaluate(evidence: evidence, disk: disk, performance: samples)
        var snapshot = DiagnosticSnapshot(runState: .completed, scope: path, disk: disk, performance: samples, evidence: evidence, diagnoses: diagnoses)
        if args.contains("--share-redacted") { snapshot = Redactor().snapshot(snapshot, profile: .shareRedacted) }
        try HTMLReport().render(snapshot).write(toFile: output, atomically: true, encoding: .utf8)
        try JSONEncoder.macclarity.encode(snapshot).write(to: URL(fileURLWithPath: output).deletingPathExtension().appendingPathExtension("json"))
        print("Report: \(URL(fileURLWithPath: output).standardizedFileURL.path)")
    }

    static func writeDemo(output: String) throws {
        let fixture = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Fixtures/synthetic-stressed-mac-v1.json")
        let snapshot = try JSONDecoder.macclarity.decode(DiagnosticSnapshot.self, from: Data(contentsOf: fixture))
        try HTMLReport().render(snapshot).write(toFile: output, atomically: true, encoding: .utf8)
        print("Demo: \(URL(fileURLWithPath: output).standardizedFileURL.path)")
    }
    static func value(after flag: String, in args: [String]) -> String? { guard let i = args.firstIndex(of: flag), args.indices.contains(i + 1) else { return nil }; return args[i + 1] }
}
